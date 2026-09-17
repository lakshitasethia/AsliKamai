import 'package:asli_kamai/models/letter_template.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('selectable excludes Kannada (verified broken text shaping in the pdf package)', () {
    expect(LetterLanguage.selectable, [LetterLanguage.english, LetterLanguage.hindi]);
    expect(LetterLanguage.selectable, isNot(contains(LetterLanguage.kannada)));
  });

  test('kannada still exists on the enum, for old history entries to display', () {
    expect(LetterLanguage.values, contains(LetterLanguage.kannada));
  });
}
