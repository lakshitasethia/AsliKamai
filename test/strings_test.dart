import 'package:asli_kamai/l10n/app_locale.dart';
import 'package:asli_kamai/l10n/strings.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every locale returns non-empty text for every static field', () {
    for (final locale in AppLocale.values) {
      final s = Strings(locale);
      // Spot-check across every screen's strings rather than every single
      // field (there are ~90) — enough to catch a forgotten _t() branch
      // returning '' for a whole locale.
      final samples = <String>[
        s.navHome, s.navImport, s.navCosts, s.navEvidence, s.navMore,
        s.offline, s.noDataYet, s.importScreenshotsPrompt,
        s.netEarnings, s.gross, s.costs, s.bestHour, s.worstHour,
        s.rateCutAlertTitle, s.lastWeek, s.thisWeek,
        s.importScreenTitle, s.noScreenshotsYet, s.pickScreenshots,
        s.screenshotReviewTitle, s.editOrder, s.platformLabel,
        s.addExpenseTitle, s.recent, s.allExpenses, s.noExpensesYet,
        s.evidenceLockerTitle, s.tabAll, s.addDocument, s.saveAs,
        s.letterGeneratorTitle, s.templates, s.history, s.yourName,
        s.profile, s.yourNamePlatforms, s.tools, s.shareCard, s.yourData,
        s.languageTile, s.exportEverything, s.deleteEverything, s.about,
        s.platformsYouWork, s.includeMyName, s.distance, s.shareButton,
        s.aboutIntro, s.aboutDataStaysHeader, s.aboutYouControlHeader,
        s.evidenceTypeLabel('notice'), s.evidenceTypeLabel('ticket'), s.evidenceTypeLabel('payout'),
        s.expenseCategoryLabel('fuel'), s.expenseCategoryLabel('food'), s.expenseCategoryLabel('other'),
        s.letterTemplateLabel('deductionExplanation'),
        s.letterTemplateDescription('deductionExplanation'),
        s.rateCutDetected('Swiggy'),
        s.savedOrders(1),
        s.savedOrders(2),
        s.readingScreenshotOf(1, 3),
        s.confirmAndSave(2),
        s.addedExpense('Petrol', '300'),
        s.rateDropSummary('12', 'Swiggy'),
      ];
      for (final value in samples) {
        expect(value.trim(), isNotEmpty, reason: 'empty string for $locale');
      }
    }
  });

  test('English, Hindi and Kannada give visibly different text for core labels', () {
    final en = Strings(AppLocale.english);
    final hi = Strings(AppLocale.hindi);
    final kn = Strings(AppLocale.kannada);

    expect(en.navHome, isNot(equals(hi.navHome)));
    expect(en.navHome, isNot(equals(kn.navHome)));
    expect(hi.navHome, isNot(equals(kn.navHome)));

    expect(en.netEarnings, isNot(equals(hi.netEarnings)));
    expect(en.netEarnings, isNot(equals(kn.netEarnings)));
  });

  test('AppLocale.label is distinct for every value', () {
    final labels = AppLocale.values.map((l) => l.label).toSet();
    expect(labels, hasLength(AppLocale.values.length));
  });
}
