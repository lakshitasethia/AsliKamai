import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../l10n/strings.dart';
import '../models/parsed_order.dart';
import '../models/platform.dart';
import '../services/gemini_vision_service.dart';
import '../services/image_hash.dart';
import '../services/screenshot_store.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../widgets/empty_state.dart';
import '../widgets/error_state.dart';
import '../widgets/screen_title.dart';
import 'import_review_screen.dart';

/// Weekly Screenshot Import tab (mockup screen 1): pick this week's
/// screenshots, parse each with Gemini, then hand off to the review screen.
class ImportScreen extends StatefulWidget {
  const ImportScreen({super.key});

  @override
  State<ImportScreen> createState() => _ImportScreenState();
}

enum _ImportStatus { idle, parsing, error }

class _ImportScreenState extends State<ImportScreen> {
  final _picker = ImagePicker();
  final _gemini = GeminiVisionService();

  _ImportStatus _status = _ImportStatus.idle;
  String? _errorMessage;
  int _parsedCount = 0;
  int _totalCount = 0;
  DateTime? _lastImportAt;
  int? _lastImportOrderCount;

  Future<void> _pickAndImport() async {
    List<XFile> files;
    try {
      files = await _picker.pickMultiImage(imageQuality: 85);
    } catch (e) {
      setState(() {
        _status = _ImportStatus.error;
        _errorMessage = S(context).couldntOpenGallery;
      });
      return;
    }
    if (files.isEmpty) return;

    setState(() {
      _status = _ImportStatus.parsing;
      _totalCount = files.length;
      _parsedCount = 0;
      _errorMessage = null;
    });

    final results = <ParsedOrder>[];
    for (final file in files) {
      try {
        final bytes = await File(file.path).readAsBytes();
        final hash = hashImageBytes(bytes);
        final screenshotPath = await saveScreenshot(bytes: bytes, hash: hash);
        final parsed = await _gemini.parseScreenshot(
          imageBytes: bytes,
          screenshotHash: hash,
        );
        parsed.screenshotPath = screenshotPath;
        results.add(parsed);
      } on GeminiNotConfiguredException {
        if (!mounted) return;
        setState(() {
          _status = _ImportStatus.error;
          _errorMessage = S(context).screenshotReadingNotSetUp;
        });
        return;
      } catch (e) {
        debugPrint('AsliKamai: screenshot parse failed: $e');
        results.add(ParsedOrder(
          platform: GigPlatform.other,
          timestamp: DateTime.now(),
          basePay: 0,
          parseFailed: true,
        ));
      }
      if (!mounted) return;
      setState(() => _parsedCount++);
    }

    if (!mounted) return;
    setState(() => _status = _ImportStatus.idle);

    final savedCount = await Navigator.of(context).push<int>(
      MaterialPageRoute(
        builder: (_) => ImportReviewScreen(parsedOrders: results),
      ),
    );

    if (savedCount != null && mounted) {
      setState(() {
        _lastImportAt = DateTime.now();
        _lastImportOrderCount = savedCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S(context).savedOrders(savedCount))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(S(context).importScreenTitle)),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    final s = S(context);
    if (_status == _ImportStatus.parsing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryGreen),
              const SizedBox(height: AppSpacing.md),
              Text(
                s.readingScreenshotOf(
                  (_parsedCount + 1).clamp(1, _totalCount),
                  _totalCount,
                ),
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      );
    }

    if (_status == _ImportStatus.error) {
      return ErrorStateView(
        message: _errorMessage ?? s.couldntReadScreenshots,
        retryLabel: s.tryAgain,
        onRetry: () => setState(() => _status = _ImportStatus.idle),
      );
    }

    return Column(
      children: [
        Expanded(
          child: EmptyState(
            icon: Icons.photo_library_outlined,
            title: s.noScreenshotsYet,
            message: s.tapToPickFromGallery,
            actionLabel: s.pickScreenshots,
            onAction: _pickAndImport,
          ),
        ),
        if (_lastImportAt != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Text(
              s.lastImportSummary(
                '${_lastImportAt!.day}/${_lastImportAt!.month}',
                _lastImportOrderCount!,
              ),
              style: AppTextStyles.bodyMuted,
            ),
          ),
      ],
    );
  }
}
