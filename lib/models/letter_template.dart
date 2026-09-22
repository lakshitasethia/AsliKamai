import 'package:flutter/material.dart';

/// The three letter templates (research.md §3.8 / build_execution.md
/// Phase 7), each citing a specific Karnataka Gig Workers Act / Rules
/// provision.
enum LetterTemplateType {
  deductionExplanation,
  idBlockReasons,
  grievanceFiling;

  static LetterTemplateType fromKey(String key) {
    return LetterTemplateType.values.firstWhere(
      (t) => t.name == key,
      orElse: () => LetterTemplateType.deductionExplanation,
    );
  }

  String get label => switch (this) {
        LetterTemplateType.deductionExplanation => 'Deduction Explanation Request',
        LetterTemplateType.idBlockReasons => 'ID-Block Written Reasons Request',
        LetterTemplateType.grievanceFiling => 'Karnataka Grievance System Filing',
      };

  String get description => switch (this) {
        LetterTemplateType.deductionExplanation =>
          'Ask the platform to explain a pay deduction on a specific order.',
        LetterTemplateType.idBlockReasons =>
          'Ask for the written reasons behind an account block or suspension.',
        LetterTemplateType.grievanceFiling =>
          'File a grievance with the platform\'s dispute committee or the Karnataka Board.',
      };

  IconData get icon => switch (this) {
        LetterTemplateType.deductionExplanation => Icons.receipt_long_outlined,
        LetterTemplateType.idBlockReasons => Icons.block_outlined,
        LetterTemplateType.grievanceFiling => Icons.balance_outlined,
      };
}

/// EN/HI/KN — every generated letter is written in one of these.
enum LetterLanguage {
  english,
  hindi,
  kannada;

  /// Languages offered in the letter form's picker. All three: Hindi and
  /// Kannada PDFs are rendered through Flutter's text engine (see
  /// letter_pdf_export.dart), since the `pdf` package can't shape them.
  static const selectable = LetterLanguage.values;

  String get label => switch (this) {
        LetterLanguage.english => 'English',
        LetterLanguage.hindi => 'हिन्दी (Hindi)',
        LetterLanguage.kannada => 'ಕನ್ನಡ (Kannada)',
      };
}
