import 'package:asli_kamai/models/letter_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every letter language, Kannada included, is selectable', () {
    expect(LetterLanguage.selectable, [
      LetterLanguage.english,
      LetterLanguage.hindi,
      LetterLanguage.kannada,
    ]);
  });
}
