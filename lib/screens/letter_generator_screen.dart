import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../data/database.dart';
import '../models/letter_template.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import '../utils/relative_date.dart';
import '../widgets/app_card.dart';
import '../widgets/screen_title.dart';
import '../widgets/section_header.dart';
import 'letter_form_screen.dart';

/// Letter Generator (mockup screen 6, build_execution.md Phase 7): pick a
/// template, fill it in, generate a PDF citing the Karnataka Gig Workers
/// Act/Rules. Reached from the More tab.
class LetterGeneratorScreen extends StatelessWidget {
  const LetterGeneratorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const ScreenTitle('Letter Generator')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.redAlert.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.redAlert.withValues(alpha: 0.3)),
            ),
            child: Text(
              'These are information-request drafts, not legal advice, and '
              'have not yet been reviewed by a labour lawyer or union.',
              style: AppTextStyles.body,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader('Templates'),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < LetterTemplateType.values.length; i++) ...[
                  if (i > 0) const Divider(height: 1, color: AppColors.cardBorder),
                  _TemplateTile(type: LetterTemplateType.values[i]),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const SectionHeader('History'),
          StreamBuilder<List<Letter>>(
            stream: AppDatabase.instance.watchAllLetters(),
            builder: (context, snapshot) {
              final letters = snapshot.data ?? [];
              if (letters.isEmpty) {
                return Text(
                  'No letters generated yet.',
                  style: AppTextStyles.bodyMuted,
                );
              }
              return AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (var i = 0; i < letters.length; i++) ...[
                      if (i > 0) const Divider(height: 1, color: AppColors.cardBorder),
                      _LetterHistoryTile(letter: letters[i]),
                    ],
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TemplateTile extends StatelessWidget {
  const _TemplateTile({required this.type});

  final LetterTemplateType type;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(type.icon, color: AppColors.primaryGreen),
      title: Text(type.label, style: AppTextStyles.body),
      subtitle: Text(type.description, style: AppTextStyles.bodyMuted),
      isThreeLine: true,
      trailing: const Icon(Icons.chevron_right, color: AppColors.mutedGrey),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => LetterFormScreen(type: type)),
      ),
    );
  }
}

class _LetterHistoryTile extends StatelessWidget {
  const _LetterHistoryTile({required this.letter});

  final Letter letter;

  Future<void> _open() async {
    final bytes = await File(letter.filePath).readAsBytes();
    await Printing.layoutPdf(onLayout: (_) => bytes);
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this letter?'),
        content: const Text('This can\'t be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await AppDatabase.instance.deleteLetter(letter.id);
  }

  @override
  Widget build(BuildContext context) {
    final type = LetterTemplateType.fromKey(letter.templateId);
    final lang = LetterLanguage.values.firstWhere(
      (l) => l.name == letter.lang,
      orElse: () => LetterLanguage.english,
    );
    return ListTile(
      leading: Icon(type.icon, color: AppColors.primaryGreen),
      title: Text(type.label, style: AppTextStyles.body),
      subtitle: Text(
        '${lang.label} • ${formatRelativeDate(letter.generatedAt)}',
        style: AppTextStyles.bodyMuted,
      ),
      onTap: _open,
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: AppColors.mutedGrey),
        onPressed: () => _delete(context),
      ),
    );
  }
}
