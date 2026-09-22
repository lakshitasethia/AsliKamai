import 'dart:convert';

import 'package:asli_kamai/models/letter_template.dart';
import 'package:asli_kamai/services/letter_pdf_export.dart';
import 'package:flutter_test/flutter_test.dart';

int _pageCount(List<int> pdf) =>
    RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(pdf)).length;

void main() {
  testWidgets('Hindi letter renders to a one-page PDF', (tester) async {
    final bytes = await tester.runAsync(() => buildLetterPdf(
          type: LetterTemplateType.idBlockReasons,
          lang: LetterLanguage.hindi,
          body: 'दिनांक: 20 Sep 2026\n\nमेरा खाता ब्लॉक कर दिया गया।',
        ));

    expect(latin1.decode(bytes!.sublist(0, 5)), '%PDF-');
    expect(_pageCount(bytes), 1);
  });

  testWidgets('a long Kannada letter flows onto more pages', (tester) async {
    final body = List.filled(120, 'ನನ್ನ ಖಾತೆಯನ್ನು ಬ್ಲಾಕ್ ಮಾಡಲಾಗಿದೆ.').join('\n');
    final bytes = await tester.runAsync(() => buildLetterPdf(
          type: LetterTemplateType.idBlockReasons,
          lang: LetterLanguage.kannada,
          body: body,
        ));

    expect(_pageCount(bytes!), greaterThan(1));
  });
}
