import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../l10n/strings.dart';
import '../models/evidence_type.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/relative_date.dart';
import '../widgets/app_card.dart';
import '../widgets/screen_title.dart';

/// Evidence detail (mockup screen 5's document view): the full photo, its
/// SHA-256 hash shown as proof it hasn't changed since capture, and a
/// "download" action via the system share sheet — no extra storage
/// permission needed to get a copy out of the app.
class EvidenceDetailScreen extends StatelessWidget {
  const EvidenceDetailScreen({super.key, required this.item});

  final EvidenceItem item;

  Future<void> _share(BuildContext context) async {
    await Share.shareXFiles([XFile(item.filePath)]);
  }

  Future<void> _delete(BuildContext context) async {
    final s = S(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteThisDocument),
        content: Text(s.thisCannotBeUndone),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(s.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(s.delete),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AppDatabase.instance.deleteEvidence(item.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final type = EvidenceType.fromKey(item.type);
    return Scaffold(
      appBar: AppBar(
        title: ScreenTitle(S(context).evidenceTypeLabel(type.name)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _share(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.redAlert),
            onPressed: () => _delete(context),
          ),
        ],
      ),
      body: SafeArea(
        // Pushed routes sit outside RootShell's SafeArea; without this,
        // Android 15+ edge-to-edge draws the bottom under the nav bar.
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              child: Image.file(File(item.filePath)),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(S(context).captured, style: AppTextStyles.label),
                  Text(formatRelativeDate(item.capturedAt), style: AppTextStyles.body),
                  if (item.notes != null && item.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(S(context).notes, style: AppTextStyles.label),
                    Text(item.notes!, style: AppTextStyles.body),
                  ],
                  const SizedBox(height: AppSpacing.sm),
                  Text(S(context).shaProofOfIntegrity, style: AppTextStyles.label),
                  SelectableText(
                    item.fileHash,
                    style: AppTextStyles.bodyMuted.copyWith(fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
