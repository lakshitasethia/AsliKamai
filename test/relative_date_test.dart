import 'package:asli_kamai/l10n/app_locale.dart';
import 'package:asli_kamai/l10n/strings.dart';
import 'package:asli_kamai/utils/relative_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 9, 23, 2, 47);
  const en = Strings(AppLocale.english);

  test('last night, under 24 hours ago, is Yesterday — not Today', () {
    expect(
      formatRelativeDate(DateTime(2026, 9, 22, 23, 28), en, now: now),
      'Yesterday, 11:28 PM',
    );
  });

  test('earlier the same calendar day is Today', () {
    expect(
      formatRelativeDate(DateTime(2026, 9, 23, 0, 5), en, now: now),
      'Today, 12:05 AM',
    );
  });

  test('two calendar days back shows the date', () {
    expect(
      formatRelativeDate(DateTime(2026, 9, 21, 23, 59), en, now: now),
      '21/9, 11:59 PM',
    );
  });

  test('Today/Yesterday follow the app language', () {
    const kn = Strings(AppLocale.kannada);
    expect(
      formatRelativeDate(DateTime(2026, 9, 23, 0, 5), kn, now: now),
      'ಇಂದು, 12:05 AM',
    );
  });
}
