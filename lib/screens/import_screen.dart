import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/parsed_order.dart';
import '../models/platform.dart';
import '../services/gemini_vision_service.dart';
import '../services/image_hash.dart';
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
        _errorMessage = 'Couldn\'t open the gallery. Try again.';
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
        final parsed = await _gemini.parseScreenshot(
          imageBytes: bytes,
          screenshotHash: hash,
        );
        results.add(parsed);
      } on GeminiNotConfiguredException {
        if (!mounted) return;
        setState(() {
          _status = _ImportStatus.error;
          _errorMessage =
              'Screenshot reading isn\'t set up yet (missing Gemini API key).';
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
        SnackBar(
          content: Text(
            'Saved $savedCount ${savedCount == 1 ? 'order' : 'orders'}.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScreenTitle('Import This Week\'s Screenshots')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
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
                'Reading screenshot '
                '${(_parsedCount + 1).clamp(1, _totalCount)} of $_totalCount…',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ),
      );
    }

    if (_status == _ImportStatus.error) {
      return ErrorStateView(
        message: _errorMessage ?? 'Couldn\'t read screenshots.',
        retryLabel: 'Try again',
        onRetry: () => setState(() => _status = _ImportStatus.idle),
      );
    }

    return Column(
      children: [
        Expanded(
          child: EmptyState(
            icon: Icons.photo_library_outlined,
            title: 'No screenshots yet',
            message: 'Tap to pick from gallery.',
            actionLabel: 'Pick Screenshots',
            onAction: _pickAndImport,
          ),
        ),
        if (_lastImportAt != null)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Text(
              'Last import: ${_lastImportAt!.day}/${_lastImportAt!.month} '
              '• $_lastImportOrderCount '
              '${_lastImportOrderCount == 1 ? 'order' : 'orders'}',
              style: AppTextStyles.bodyMuted,
            ),
          ),
      ],
    );
  }
}
