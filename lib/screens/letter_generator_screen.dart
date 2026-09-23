import 'dart:io';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../data/database.dart';
import '../l10n/strings.dart';
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
    final s = S(context);
    return Scaffold(
      appBar: AppBar(title: ScreenTitle(s.letterGeneratorTitle)),
      body: SafeArea(
        // Pushed routes sit outside RootShell's SafeArea; without this,
        // Android 15+ edge-to-edge draws the bottom under the nav bar.
        top: false,
        child: ListView(
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
                s.notLegalAdviceBanner,
                style: AppTextStyles.body,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SectionHeader(s.templates),
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
            SectionHeader(s.history),
            StreamBuilder<List<Letter>>(
              stream: AppDatabase.instance.watchAllLetters(),
              builder: (context, snapshot) {
                final letters = snapshot.data ?? [];
                if (letters.isEmpty) {
                  return Text(
                    s.noLettersYet,
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
      title: Text(S(context).letterTemplateLabel(type.name), style: AppTextStyles.body),
      subtitle: Text(S(context).letterTemplateDescription(type.name), style: AppTextStyles.bodyMuted),
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
    final s = S(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.deleteThisLetter),
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
      title: Text(S(context).letterTemplateLabel(type.name), style: AppTextStyles.body),
      subtitle: Text(
        '${lang.label} • ${formatRelativeDate(letter.generatedAt, S(context))}',
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
