import 'package:asli_kamai/models/letter_template.dart';
import 'package:asli_kamai/services/letter_content.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final data = LetterData(
    riderName: 'Ravi Kumar',
    platform: 'Swiggy',
    todayDate: '17 Sep 2026',
    orderRef: 'SW-88213',
    orderDate: '16 Sep 2026',
    orderAmount: '87',
    blockDate: '15 Sep 2026',
    details: 'My account was blocked without warning.',
  );

  group('deduction explanation request', () {
    test('English body includes the rider, platform, and order details', () {
      final body = buildLetterBody(
        type: LetterTemplateType.deductionExplanation,
        lang: LetterLanguage.english,
        data: data,
      );
      expect(body, contains('Ravi Kumar'));
      expect(body, contains('Swiggy'));
      expect(body, contains('SW-88213'));
      expect(body, contains('16 Sep 2026'));
      expect(body, contains('87'));
    });

    test('cites the "clearly explained" deductions provision', () {
      final body = buildLetterBody(
        type: LetterTemplateType.deductionExplanation,
        lang: LetterLanguage.english,
        data: data,
      );
      expect(body, contains('clearly explained'));
    });
  });

  group('ID-block written reasons request', () {
    test('English body includes the rider, platform, and block date', () {
      final body = buildLetterBody(
        type: LetterTemplateType.idBlockReasons,
        lang: LetterLanguage.english,
        data: data,
      );
      expect(body, contains('Ravi Kumar'));
      expect(body, contains('Swiggy'));
      expect(body, contains('15 Sep 2026'));
    });

    test('cites the 14-day written-reasons provision', () {
      final body = buildLetterBody(
        type: LetterTemplateType.idBlockReasons,
        lang: LetterLanguage.english,
        data: data,
      );
      expect(body, contains('14 days'));
    });
  });

  group('grievance filing', () {
    test('English body includes the rider, platform, and details', () {
      final body = buildLetterBody(
        type: LetterTemplateType.grievanceFiling,
        lang: LetterLanguage.english,
        data: data,
      );
      expect(body, contains('Ravi Kumar'));
      expect(body, contains('Swiggy'));
      expect(body, contains('blocked without warning'));
    });

    test('cites the dispute committee / Board escalation path', () {
      final body = buildLetterBody(
        type: LetterTemplateType.grievanceFiling,
        lang: LetterLanguage.english,
        data: data,
      );
      expect(body, contains('dispute committee'));
      expect(body, contains('Board'));
    });
  });

  test('each language produces distinct, non-empty text for every template', () {
    for (final type in LetterTemplateType.values) {
      final seen = <String>{};
      for (final lang in LetterLanguage.values) {
        final body = buildLetterBody(type: type, lang: lang, data: data);
        expect(body, isNotEmpty);
        expect(seen, isNot(contains(body)));
        seen.add(body);
      }
    }
  });

  test('every generated body still contains the rider name regardless of language', () {
    for (final type in LetterTemplateType.values) {
      for (final lang in LetterLanguage.values) {
        final body = buildLetterBody(type: type, lang: lang, data: data);
        expect(body, contains('Ravi Kumar'), reason: '$type / $lang');
      }
    }
  });
}
