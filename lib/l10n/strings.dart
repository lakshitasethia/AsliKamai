import 'package:flutter/widgets.dart';

import 'app_locale.dart';
import 'app_locale_scope.dart';

/// App-chrome text in all three UI languages (build_execution.md Phase 8).
/// Every screen reads its strings through `S(context)` rather than hardcoding
/// English, so switching the language in More -> Language changes the whole
/// app, not just letters.
///
/// Deliberately NOT translated (see build_execution.md Phase 8 notes):
/// platform brand names (Swiggy/Zomato/...), month abbreviations in date
/// labels, and the "Meri Asli Kamai" share-card brand phrase, which is
/// itself the Hindi wording research.md's growth-loop section uses
/// regardless of the app's language.
class Strings {
  const Strings(this._locale);

  final AppLocale _locale;

  String _t(String en, String hi, String kn) => switch (_locale) {
        AppLocale.english => en,
        AppLocale.hindi => hi,
        AppLocale.kannada => kn,
      };

  // Common
  String get cancel => _t('Cancel', 'रद्द करें', 'ರದ್ದುಮಾಡಿ');
  String get delete => _t('Delete', 'हटाएं', 'ಅಳಿಸಿ');
  String get save => _t('Save', 'सेव करें', 'ಉಳಿಸಿ');
  String get saveChanges => _t('Save changes', 'बदलाव सेव करें', 'ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ');
  String get tryAgain => _t('Try again', 'फिर कोशिश करें', 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ');
  String get thisCannotBeUndone =>
      _t('This can\'t be undone.', 'यह वापस नहीं हो सकता.', 'ಇದನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುವುದಿಲ್ಲ.');

  // Bottom nav (root_shell.dart)
  String get navHome => _t('Home', 'होम', 'ಮುಖಪುಟ');
  String get navImport => _t('Import', 'इम्पोर्ट', 'ಆಮದು');
  String get navCosts => _t('Costs', 'खर्च', 'ಖರ್ಚು');
  String get navEvidence => _t('Evidence', 'सबूत', 'ಪುರಾವೆ');
  String get navMore => _t('More', 'और', 'ಇನ್ನಷ್ಟು');

  // Home tab (home_screen.dart)
  String get offline => _t('Offline', 'ऑफ़लाइन', 'ಆಫ್‌ಲೈನ್');
  String get noDataYet => _t('No data yet', 'अभी कोई डेटा नहीं', 'ಇನ್ನೂ ಡೇಟಾ ಇಲ್ಲ');
  String get importScreenshotsPrompt => _t(
        'Import screenshots to see your weekly summary.',
        'अपनी साप्ताहिक जानकारी देखने के लिए स्क्रीनशॉट इम्पोर्ट करें.',
        'ನಿಮ್ಮ ವಾರದ ಸಾರಾಂಶ ನೋಡಲು ಸ್ಕ್ರೀನ್‌ಶಾಟ್‌ಗಳನ್ನು ಆಮದು ಮಾಡಿ.',
      );
  String get netEarnings => _t('Net Earnings', 'कुल कमाई', 'ನಿವ್ವಳ ಗಳಿಕೆ');
  String get gross => _t('Gross', 'कुल आय', 'ಒಟ್ಟು');
  String get costs => _t('Costs', 'खर्च', 'ಖರ್ಚು');
  String get bestHour => _t('Best Hour', 'सबसे अच्छा समय', 'ಉತ್ತಮ ಸಮಯ');
  String get worstHour => _t('Worst Hour', 'सबसे कम कमाई का समय', 'ಕಳಪೆ ಸಮಯ');
  String get bestZones => _t('Best Zones', 'सबसे अच्छे इलाके', 'ಉತ್ತಮ ವಲಯಗಳು');
  String get wasIncentiveWorthIt =>
      _t('Was the incentive worth it?', 'क्या इंसेंटिव फ़ायदेमंद था?', 'ಪ್ರೋತ್ಸಾಹಧನ ಪ್ರಯೋಜನಕಾರಿಯಾಗಿತ್ತೆ?');
  String get withIncentive => _t('With incentive', 'इंसेंटिव सहित', 'ಪ್ರೋತ್ಸಾಹಧನದೊಂದಿಗೆ');
  String get without => _t('Without', 'इंसेंटिव रहित', 'ಇಲ್ಲದೆ');
  String rateCutDetected(String platform) => _t(
        '$platform rate cut detected',
        '$platform में रेट कटौती हुई है',
        '$platform ದರ ಕಡಿತ ಪತ್ತೆಯಾಗಿದೆ',
      );
  String get viewFullDetails => _t('View Full Details', 'पूरी जानकारी देखें', 'ಪೂರ್ಣ ವಿವರ ನೋಡಿ');
  String get allGoodNoRateCut => _t(
        'All good! No rate cut detected this week.',
        'सब ठीक है! इस हफ़्ते कोई रेट कटौती नहीं मिली.',
        'ಎಲ್ಲಾ ಸರಿಯಿದೆ! ಈ ವಾರ ದರ ಕಡಿತ ಕಂಡುಬಂದಿಲ್ಲ.',
      );

  // Rate Cut Details (rate_cut_details_screen.dart)
  String get rateCutAlertTitle => _t('Rate Cut Alert', 'रेट कटौती अलर्ट', 'ದರ ಕಡಿತ ಎಚ್ಚರಿಕೆ');
  String get lastWeek => _t('Last week', 'पिछला हफ़्ता', 'ಕಳೆದ ವಾರ');
  String get thisWeek => _t('This week', 'यह हफ़्ता', 'ಈ ವಾರ');
  String rateDropSummary(String percent, String platform) => _t(
        'That\'s a $percent% drop in pay per kilometre on $platform compared to last week.',
        'यह पिछले हफ़्ते की तुलना में $platform पर प्रति किलोमीटर कमाई में $percent% की गिरावट है.',
        'ಇದು ಕಳೆದ ವಾರಕ್ಕೆ ಹೋಲಿಸಿದರೆ $platform ನಲ್ಲಿ ಪ್ರತಿ ಕಿಲೋಮೀಟರ್‌ಗೆ $percent% ಕುಸಿತವಾಗಿದೆ.',
      );
  String get evidenceThisWeeksOrders => _t(
        'Evidence (this week\'s orders)',
        'सबूत (इस हफ़्ते के ऑर्डर)',
        'ಪುರಾವೆ (ಈ ವಾರದ ಆರ್ಡರ್‌ಗಳು)',
      );

  // Import tab (import_screen.dart)
  String get importScreenTitle => _t(
        'Import This Week\'s Screenshots',
        'इस हफ़्ते के स्क्रीनशॉट इम्पोर्ट करें',
        'ಈ ವಾರದ ಸ್ಕ್ರೀನ್‌ಶಾಟ್‌ಗಳನ್ನು ಆಮದು ಮಾಡಿ',
      );
  String get noScreenshotsYet => _t('No screenshots yet', 'अभी कोई स्क्रीनशॉट नहीं', 'ಇನ್ನೂ ಸ್ಕ್ರೀನ್‌ಶಾಟ್‌ಗಳಿಲ್ಲ');
  String get tapToPickFromGallery =>
      _t('Tap to pick from gallery.', 'गैलरी से चुनने के लिए टैप करें.', 'ಗ್ಯಾಲರಿಯಿಂದ ಆಯ್ಕೆಮಾಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ.');
  String get pickScreenshots => _t('Pick Screenshots', 'स्क्रीनशॉट चुनें', 'ಸ್ಕ್ರೀನ್‌ಶಾಟ್‌ಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ');
  String get couldntOpenGallery =>
      _t('Couldn\'t open the gallery. Try again.', 'गैलरी नहीं खुल पाई. फिर कोशिश करें.', 'ಗ್ಯಾಲರಿ ತೆರೆಯಲಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.');
  String get screenshotReadingNotSetUp => _t(
        'Screenshot reading isn\'t set up yet (missing Gemini API key).',
        'स्क्रीनशॉट पढ़ने की सुविधा अभी सेट नहीं है (Gemini API key गायब है).',
        'ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಓದುವಿಕೆ ಇನ್ನೂ ಸಿದ್ಧವಾಗಿಲ್ಲ (Gemini API key ಕಾಣೆಯಾಗಿದೆ).',
      );
  String get couldntReadScreenshots =>
      _t('Couldn\'t read screenshots.', 'स्क्रीनशॉट पढ़े नहीं जा सके.', 'ಸ್ಕ್ರೀನ್‌ಶಾಟ್‌ಗಳನ್ನು ಓದಲಾಗಲಿಲ್ಲ.');
  String readingScreenshotOf(int current, int total) => _t(
        'Reading screenshot $current of $total…',
        'स्क्रीनशॉट पढ़ रहे हैं $current / $total…',
        'ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಓದಲಾಗುತ್ತಿದೆ $current / $total…',
      );
  String savedOrders(int count) => _t(
        'Saved $count ${count == 1 ? 'order' : 'orders'}.',
        '$count ऑर्डर सेव हुए.',
        '$count ಆರ್ಡರ್‌ಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ.',
      );
  String lastImportSummary(String date, int count) => _t(
        'Last import: $date • $count ${count == 1 ? 'order' : 'orders'}',
        'आखिरी इम्पोर्ट: $date • $count ऑर्डर',
        'ಕೊನೆಯ ಆಮದು: $date • $count ಆರ್ಡರ್‌ಗಳು',
      );

  // Import Review (import_review_screen.dart)
  String get screenshotReviewTitle =>
      _t('Screenshot Review (OCR)', 'स्क्रीनशॉट समीक्षा (OCR)', 'ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಪರಿಶೀಲನೆ (OCR)');
  String get reviewAndCorrectPrompt => _t(
        'Review and correct the details. We\'ll save these to your weekly report.',
        'जानकारी जांचें और ज़रूरत हो तो ठीक करें. इसे आपकी साप्ताहिक रिपोर्ट में सेव किया जाएगा.',
        'ವಿವರಗಳನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು ಸರಿಪಡಿಸಿ. ಇವುಗಳನ್ನು ನಿಮ್ಮ ವಾರದ ವರದಿಗೆ ಉಳಿಸಲಾಗುತ್ತದೆ.',
      );
  String get nothingLeftToSave => _t('Nothing left to save.', 'सेव करने के लिए कुछ नहीं बचा.', 'ಉಳಿಸಲು ಏನೂ ಉಳಿದಿಲ್ಲ.');
  String confirmAndSave(int count) => _t(
        'Confirm & Save ($count ${count == 1 ? 'order' : 'orders'})',
        'पुष्टि करें और सेव करें ($count ऑर्डर)',
        'ದೃಢೀಕರಿಸಿ ಮತ್ತು ಉಳಿಸಿ ($count ಆರ್ಡರ್‌ಗಳು)',
      );
  String get couldntReadScreenshotEntry => _t(
        'Couldn\'t read this screenshot. Tap to enter manually, or remove it.',
        'यह स्क्रीनशॉट पढ़ा नहीं जा सका. मैन्युअल रूप से भरने के लिए टैप करें, या इसे हटा दें.',
        'ಈ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಓದಲಾಗಲಿಲ್ಲ. ಸ್ವತಃ ನಮೂದಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ, ಅಥವಾ ಅದನ್ನು ತೆಗೆದುಹಾಕಿ.',
      );
  String orderNumberInline(String ref) =>
      _t('Order # $ref', 'ऑर्डर # $ref', 'ಆರ್ಡರ್ # $ref');
  String get editOrder => _t('Edit order', 'ऑर्डर बदलें', 'ಆರ್ಡರ್ ಸಂಪಾದಿಸಿ');
  String get platformLabel => _t('Platform', 'प्लेटफ़ॉर्म', 'ಪ್ಲಾಟ್‌ಫಾರ್ಮ್');
  String get basePayLabel => _t('Base pay (₹)', 'मूल भुगतान (₹)', 'ಮೂಲ ಪಾವತಿ (₹)');
  String get incentiveLabel => _t('Incentive (₹)', 'इंसेंटिव (₹)', 'ಪ್ರೋತ್ಸಾಹಧನ (₹)');
  String get tipLabel => _t('Tip (₹)', 'टिप (₹)', 'ಟಿಪ್ (₹)');
  String get distanceKmLabel => _t('Distance (km)', 'दूरी (km)', 'ದೂರ (km)');
  String get durationMinLabel => _t('Duration (min)', 'समय (मिनट)', 'ಅವಧಿ (ನಿಮಿಷ)');
  String get zoneLabel => _t('Zone', 'इलाका', 'ವಲಯ');
  String get orderNumberFieldLabel => _t('Order #', 'ऑर्डर #', 'ಆರ್ಡರ್ #');

  // Costs tab (costs_screen.dart)
  String get addExpenseTitle => _t('Add Expense', 'खर्च जोड़ें', 'ಖರ್ಚು ಸೇರಿಸಿ');
  String get orTypeExample =>
      _t('Or type e.g. Petrol 300', 'या टाइप करें, जैसे Petrol 300', 'ಅಥವಾ ಟೈಪ್ ಮಾಡಿ, ಉದಾ. Petrol 300');
  String get recent => _t('Recent', 'हाल के', 'ಇತ್ತೀಚಿನ');
  String get allExpenses => _t('All expenses', 'सभी खर्च', 'ಎಲ್ಲಾ ಖರ್ಚುಗಳು');
  String get noExpensesYet => _t('No expenses yet', 'अभी कोई खर्च नहीं', 'ಇನ್ನೂ ಖರ್ಚುಗಳಿಲ್ಲ');
  String get tapMicToAddFirst => _t(
        'Tap the mic to add your first expense.',
        'अपना पहला खर्च जोड़ने के लिए माइक पर टैप करें.',
        'ನಿಮ್ಮ ಮೊದಲ ಖರ್ಚು ಸೇರಿಸಲು ಮೈಕ್ ಒತ್ತಿ.',
      );
  String get tapAndSpeakExample => _t(
        'Tap and speak, e.g. "Petrol 300"',
        'टैप करके बोलें, जैसे "Petrol 300"',
        'ಟ್ಯಾಪ್ ಮಾಡಿ ಮಾತನಾಡಿ, ಉದಾ. "Petrol 300"',
      );
  String get starting => _t('Starting...', 'शुरू हो रहा है...', 'ಪ್ರಾರಂಭಿಸಲಾಗುತ್ತಿದೆ...');
  String get listening => _t('Listening...', 'सुन रहे हैं...', 'ಕೇಳುತ್ತಿದೆ...');
  String get voiceNotAvailable => _t(
        'Voice isn\'t available on this device. Type below instead.',
        'इस डिवाइस पर वॉइस उपलब्ध नहीं है. नीचे टाइप करें.',
        'ಈ ಸಾಧನದಲ್ಲಿ ಧ್ವನಿ ಲಭ್ಯವಿಲ್ಲ. ಬದಲಿಗೆ ಕೆಳಗೆ ಟೈಪ್ ಮಾಡಿ.',
      );
  String get couldntHearThat =>
      _t('Couldn\'t hear that — try again.', 'सुन नहीं पाए — फिर कोशिश करें.', 'ಅದು ಕೇಳಿಸಲಿಲ್ಲ — ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.');
  String couldntMakeOutAmount(String text) => _t(
        'Couldn\'t make out an amount in "$text" — check below.',
        '"$text" में राशि समझ नहीं आई — नीचे देखें.',
        '"$text" ನಲ್ಲಿ ಮೊತ್ತ ಗುರುತಿಸಲಾಗಲಿಲ್ಲ — ಕೆಳಗೆ ನೋಡಿ.',
      );
  String addedExpense(String category, String amount) =>
      _t('Added $category $amount', '$category $amount जोड़ा गया', '$category $amount ಸೇರಿಸಲಾಗಿದೆ');
  String get enterAmountExample =>
      _t('Enter an amount, e.g. "Petrol 300".', 'राशि डालें, जैसे "Petrol 300".', 'ಮೊತ್ತ ನಮೂದಿಸಿ, ಉದಾ. "Petrol 300".');
  String get enterValidAmount =>
      _t('Enter a valid amount.', 'सही राशि डालें.', 'ಮಾನ್ಯ ಮೊತ್ತ ನಮೂದಿಸಿ.');
  String get editExpense => _t('Edit expense', 'खर्च बदलें', 'ಖರ್ಚು ಸಂಪಾದಿಸಿ');
  String get category => _t('Category', 'श्रेणी', 'ವರ್ಗ');
  String get amountRupees => _t('Amount (₹)', 'राशि (₹)', 'ಮೊತ್ತ (₹)');

  // Evidence Locker (evidence_screen.dart, evidence_detail_screen.dart)
  String get evidenceLockerTitle => _t('Evidence Locker', 'सबूत लॉकर', 'ಪುರಾವೆ ಲಾಕರ್');
  String get tabAll => _t('All', 'सभी', 'ಎಲ್ಲಾ');
  String get addDocument => _t('Add Document', 'दस्तावेज़ जोड़ें', 'ದಾಖಲೆ ಸೇರಿಸಿ');
  String get noEvidenceYet => _t('No evidence yet', 'अभी कोई सबूत नहीं', 'ಇನ್ನೂ ಪುರಾವೆ ಇಲ್ಲ');
  String get addDocumentsFromGallery => _t(
        'Add documents from your gallery.',
        'अपनी गैलरी से दस्तावेज़ जोड़ें.',
        'ನಿಮ್ಮ ಗ್ಯಾಲರಿಯಿಂದ ದಾಖಲೆಗಳನ್ನು ಸೇರಿಸಿ.',
      );
  String get alreadySavedNoNew => _t(
        'Already saved — no new documents added.',
        'पहले से सेव है — कोई नया दस्तावेज़ नहीं जोड़ा गया.',
        'ಈಗಾಗಲೇ ಉಳಿಸಲಾಗಿದೆ — ಹೊಸ ದಾಖಲೆಗಳು ಸೇರಿಸಲ್ಪಟ್ಟಿಲ್ಲ.',
      );
  String addedDocuments(int count) => _t(
        'Added $count ${count == 1 ? 'document' : 'documents'}.',
        '$count दस्तावेज़ जोड़े गए.',
        '$count ದಾಖಲೆಗಳನ್ನು ಸೇರಿಸಲಾಗಿದೆ.',
      );
  String get couldntExportPdf =>
      _t('Couldn\'t export the PDF. Try again.', 'PDF एक्सपोर्ट नहीं हो पाई. फिर कोशिश करें.', 'PDF ರಫ್ತು ಮಾಡಲಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.');
  String exportToPdf(int count) =>
      _t('Export $count to PDF', '$count को PDF में एक्सपोर्ट करें', '$count ಅನ್ನು PDF ಗೆ ರಫ್ತು ಮಾಡಿ');
  String get saveAs => _t('Save as', 'इस रूप में सेव करें', 'ಹೀಗೆ ಉಳಿಸಿ');
  String get deleteThisDocument =>
      _t('Delete this document?', 'यह दस्तावेज़ हटाएं?', 'ಈ ದಾಖಲೆಯನ್ನು ಅಳಿಸುವುದೇ?');
  String get captured => _t('Captured', 'कैप्चर किया गया', 'ಸೆರೆಹಿಡಿಯಲಾಗಿದೆ');
  String get notes => _t('Notes', 'नोट्स', 'ಟಿಪ್ಪಣಿಗಳು');
  String get shaProofOfIntegrity =>
      _t('SHA-256 (proof of integrity)', 'SHA-256 (सत्यता का प्रमाण)', 'SHA-256 (ಸಮಗ್ರತೆಯ ಪುರಾವೆ)');

  // Letter Generator (letter_generator_screen.dart, letter_form_screen.dart)
  String get letterGeneratorTitle => _t('Letter Generator', 'पत्र जनरेटर', 'ಪತ್ರ ಜನರೇಟರ್');
  String get notLegalAdviceBanner => _t(
        'These are information-request drafts, not legal advice, and have not yet been reviewed by a labour lawyer or union.',
        'ये सूचना-अनुरोध के ड्राफ़्ट हैं, कानूनी सलाह नहीं, और अभी तक किसी लेबर वकील या यूनियन ने इनकी समीक्षा नहीं की है.',
        'ಇವು ಮಾಹಿತಿ-ಕೋರಿಕೆ ಕರಡುಗಳಾಗಿವೆ, ಕಾನೂನು ಸಲಹೆಯಲ್ಲ, ಮತ್ತು ಇವನ್ನು ಇನ್ನೂ ಕಾರ್ಮಿಕ ವಕೀಲ ಅಥವಾ ಯೂನಿಯನ್ ಪರಿಶೀಲಿಸಿಲ್ಲ.',
      );
  String get templates => _t('Templates', 'टेम्प्लेट', 'ಟೆಂಪ್ಲೇಟ್‌ಗಳು');
  String get history => _t('History', 'इतिहास', 'ಇತಿಹಾಸ');
  String get noLettersYet => _t('No letters generated yet.', 'अभी कोई पत्र नहीं बना.', 'ಇನ್ನೂ ಯಾವುದೇ ಪತ್ರ ರಚಿಸಿಲ್ಲ.');
  String get deleteThisLetter => _t('Delete this letter?', 'यह पत्र हटाएं?', 'ಈ ಪತ್ರವನ್ನು ಅಳಿಸುವುದೇ?');
  String get letterFormNotLegalAdvice => _t(
        'This generates an information request, not legal advice — a draft template pending review by a labour lawyer or union.',
        'यह एक सूचना-अनुरोध बनाता है, कानूनी सलाह नहीं — यह ड्राफ़्ट टेम्प्लेट लेबर वकील या यूनियन की समीक्षा का इंतज़ार कर रहा है.',
        'ಇದು ಮಾಹಿತಿ-ಕೋರಿಕೆ ರಚಿಸುತ್ತದೆ, ಕಾನೂನು ಸಲಹೆಯಲ್ಲ — ಈ ಕರಡು ಟೆಂಪ್ಲೇಟ್ ಕಾರ್ಮಿಕ ವಕೀಲ ಅಥವಾ ಯೂನಿಯನ್ ಪರಿಶೀಲನೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ.',
      );
  String get yourName => _t('Your name', 'आपका नाम', 'ನಿಮ್ಮ ಹೆಸರು');
  String get language => _t('Language', 'भाषा', 'ಭಾಷೆ');
  String get generateAndPreview => _t('Generate & Preview', 'बनाएं और देखें', 'ರಚಿಸಿ ಮತ್ತು ಪೂರ್ವವೀಕ್ಷಿಸಿ');
  String get referenceAnOrder => _t('Reference an order', 'किसी ऑर्डर का हवाला दें', 'ಆರ್ಡರ್ ಉಲ್ಲೇಖಿಸಿ');
  String get orderDateLabel => _t('Order date', 'ऑर्डर की तारीख', 'ಆರ್ಡರ್ ದಿನಾಂಕ');
  String get amountPaidLabel => _t('Amount paid (₹)', 'भुगतान की गई राशि (₹)', 'ಪಾವತಿಸಿದ ಮೊತ್ತ (₹)');
  String get referenceANotice => _t('Reference a notice', 'किसी नोटिस का हवाला दें', 'ಸೂಚನೆಯನ್ನು ಉಲ್ಲೇಖಿಸಿ');
  String get dateIdBlocked => _t('Date the ID was blocked', 'ID ब्लॉक होने की तारीख', 'ID ಬ್ಲಾಕ್ ಆದ ದಿನಾಂಕ');
  String get describeIssue => _t('Describe the issue', 'समस्या बताएं', 'ಸಮಸ್ಯೆಯನ್ನು ವಿವರಿಸಿ');
  String get pickAnOrder => _t('Pick an order', 'एक ऑर्डर चुनें', 'ಒಂದು ಆರ್ಡರ್ ಆಯ್ಕೆಮಾಡಿ');
  String get noOrdersImportedYet =>
      _t('No orders imported yet.', 'अभी कोई ऑर्डर इम्पोर्ट नहीं हुआ.', 'ಇನ್ನೂ ಆರ್ಡರ್‌ಗಳನ್ನು ಆಮದು ಮಾಡಿಲ್ಲ.');
  String get pickANotice => _t('Pick a notice', 'एक नोटिस चुनें', 'ಒಂದು ಸೂಚನೆ ಆಯ್ಕೆಮಾಡಿ');
  String get noRef => _t('no ref', 'कोई ऑर्डर # नहीं', 'ಯಾವುದೇ ಆರ್ಡರ್ # ಇಲ್ಲ');
  String get noNoticesSaved => _t(
        'No Notices saved in the Evidence Locker yet.',
        'सबूत लॉकर में अभी कोई नोटिस सेव नहीं है.',
        'ಪುರಾವೆ ಲಾಕರ್‌ನಲ್ಲಿ ಇನ್ನೂ ಯಾವುದೇ ಸೂಚನೆ ಉಳಿಸಿಲ್ಲ.',
      );

  // More tab (more_screen.dart)
  String get profile => _t('Profile', 'प्रोफ़ाइल', 'ಪ್ರೊಫೈಲ್');
  String get yourNamePlatforms => _t('Your name & platforms', 'आपका नाम और प्लेटफ़ॉर्म', 'ನಿಮ್ಮ ಹೆಸರು ಮತ್ತು ಪ್ಲಾಟ್‌ಫಾರ್ಮ್‌ಗಳು');
  String get tools => _t('Tools', 'टूल्स', 'ಉಪಕರಣಗಳು');
  String get shareCard => _t('Share Card', 'शेयर कार्ड', 'ಶೇರ್ ಕಾರ್ಡ್');
  String get yourData => _t('Your data', 'आपका डेटा', 'ನಿಮ್ಮ ಡೇಟಾ');
  String get languageTile => _t('Language', 'भाषा', 'ಭಾಷೆ');
  String get exportEverything => _t('Export everything', 'सब कुछ एक्सपोर्ट करें', 'ಎಲ್ಲವನ್ನೂ ರಫ್ತು ಮಾಡಿ');
  String get deleteEverything => _t('Delete everything', 'सब कुछ हटाएं', 'ಎಲ್ಲವನ್ನೂ ಅಳಿಸಿ');
  String get about => _t('About', 'जानकारी', 'ಬಗ್ಗೆ');
  String get privacyAboutAsliKamai =>
      _t('Privacy & about AsliKamai', 'प्राइवेसी और AsliKamai के बारे में', 'ಗೌಪ್ಯತೆ ಮತ್ತು AsliKamai ಬಗ್ಗೆ');
  String get preparingExport => _t('Preparing export…', 'एक्सपोर्ट तैयार हो रहा है…', 'ರಫ್ತು ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ…');
  String get deletingEllipsis => _t('Deleting…', 'हटाया जा रहा है…', 'ಅಳಿಸಲಾಗುತ್ತಿದೆ…');
  String get deleteEverythingConfirmTitle =>
      _t('Delete everything?', 'सब कुछ हटाएं?', 'ಎಲ್ಲವನ್ನೂ ಅಳಿಸುವುದೇ?');
  String get deleteEverythingConfirmBody => _t(
        'This permanently deletes every order, expense, evidence photo, and letter, plus your saved name and platforms. This cannot be undone.',
        'यह हर ऑर्डर, खर्च, सबूत की फोटो और पत्र, साथ ही आपका सेव किया गया नाम और प्लेटफ़ॉर्म हमेशा के लिए हटा देगा. यह वापस नहीं हो सकता.',
        'ಇದು ಪ್ರತಿ ಆರ್ಡರ್, ಖರ್ಚು, ಪುರಾವೆ ಫೋಟೋ ಮತ್ತು ಪತ್ರ, ಜೊತೆಗೆ ನಿಮ್ಮ ಉಳಿಸಿದ ಹೆಸರು ಮತ್ತು ಪ್ಲಾಟ್‌ಫಾರ್ಮ್‌ಗಳನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸುತ್ತದೆ. ಇದನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುವುದಿಲ್ಲ.',
      );
  String get everythingDeletedToast =>
      _t('Everything has been deleted.', 'सब कुछ हटा दिया गया है.', 'ಎಲ್ಲವನ್ನೂ ಅಳಿಸಲಾಗಿದೆ.');
  String get savedToast => _t('Saved.', 'सेव हो गया.', 'ಉಳಿಸಲಾಗಿದೆ.');

  // Settings/Profile screen (settings_screen.dart)
  String get platformsYouWork => _t('Platform(s) you work', 'आप जिन प्लेटफ़ॉर्म पर काम करते हैं', 'ನೀವು ಕೆಲಸ ಮಾಡುವ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್‌ಗಳು');

  // Share Card (share_card_screen.dart)
  String get includeMyName => _t('Include my name', 'मेरा नाम शामिल करें', 'ನನ್ನ ಹೆಸರನ್ನು ಸೇರಿಸಿ');
  String get includeMyNameOff => _t(
        'Off by default — the card stays anonymous unless you turn this on.',
        'डिफ़ॉल्ट रूप से बंद — जब तक आप इसे चालू न करें, कार्ड गुमनाम रहता है.',
        'ಡೀಫಾಲ್ಟ್ ಆಗಿ ಆಫ್ ಆಗಿದೆ — ನೀವು ಇದನ್ನು ಆನ್ ಮಾಡದ ಹೊರತು ಕಾರ್ಡ್ ಅನಾಮಧೇಯವಾಗಿರುತ್ತದೆ.',
      );
  String get setYourNameHint => _t(
        'Set your name in More → Your name & platforms',
        'More → आपका नाम और प्लेटफ़ॉर्म में अपना नाम डालें',
        'More → ನಿಮ್ಮ ಹೆಸರು ಮತ್ತು ಪ್ಲಾಟ್‌ಫಾರ್ಮ್‌ಗಳಲ್ಲಿ ನಿಮ್ಮ ಹೆಸರನ್ನು ಹೊಂದಿಸಿ',
      );
  String get netAfterCosts => _t('net, after costs', 'खर्च के बाद', 'ಖರ್ಚಿನ ನಂತರ ನಿವ್ವಳ');
  String get shareCardNetEarnings => _t('Net earnings', 'कुल कमाई', 'ನಿವ್ವಳ ಗಳಿಕೆ');
  String get distance => _t('Distance', 'दूरी', 'ದೂರ');
  String get shareButton => _t('Share', 'शेयर करें', 'ಶೇರ್ ಮಾಡಿ');
  String get preparingEllipsis => _t('Preparing…', 'तैयार हो रहा है…', 'ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ…');
  String get nothingToShareYet => _t('Nothing to share yet', 'अभी शेयर करने लायक कुछ नहीं', 'ಇನ್ನೂ ಶೇರ್ ಮಾಡಲು ಏನೂ ಇಲ್ಲ');
  String get importScreenshotsFirst => _t(
        'Import this week\'s screenshots first, then come back here.',
        'पहले इस हफ़्ते के स्क्रीनशॉट इम्पोर्ट करें, फिर यहां वापस आएं.',
        'ಮೊದಲು ಈ ವಾರದ ಸ್ಕ್ರೀನ್‌ಶಾಟ್‌ಗಳನ್ನು ಆಮದು ಮಾಡಿ, ನಂತರ ಇಲ್ಲಿಗೆ ಹಿಂತಿರುಗಿ.',
      );
  String shareCaption(String rate) => _t(
        'Meri Asli Kamai this week: $rate/hour after costs. — via AsliKamai',
        'Meri Asli Kamai this week: $rate/hour after costs. — via AsliKamai',
        'Meri Asli Kamai this week: $rate/hour after costs. — via AsliKamai',
      );
  String get shareCaptionNoRate => _t(
        'Meri Asli Kamai this week, via AsliKamai.',
        'Meri Asli Kamai this week, via AsliKamai.',
        'Meri Asli Kamai this week, via AsliKamai.',
      );

  // About screen (about_screen.dart)
  String get aboutIntro => _t(
        'AsliKamai helps Karnataka\'s delivery and ride-hailing gig workers see their real net earnings, catch pay-rate cuts, and build evidence for disputes under the Karnataka Platform-Based Gig Workers Act.',
        'AsliKamai कर्नाटक के डिलीवरी और राइड-हेलिंग गिग वर्कर्स को उनकी असली कमाई देखने, रेट कटौती पकड़ने, और कर्नाटक प्लेटफ़ॉर्म-आधारित गिग वर्कर्स एक्ट के तहत विवादों के लिए सबूत बनाने में मदद करता है.',
        'AsliKamai ಕರ್ನಾಟಕದ ಡೆಲಿವರಿ ಮತ್ತು ರೈಡ್-ಹೇಲಿಂಗ್ ಗಿಗ್ ಕಾರ್ಮಿಕರಿಗೆ ಅವರ ನಿಜವಾದ ನಿವ್ವಳ ಗಳಿಕೆ ನೋಡಲು, ದರ ಕಡಿತಗಳನ್ನು ಪತ್ತೆಹಚ್ಚಲು ಮತ್ತು ಕರ್ನಾಟಕ ಪ್ಲಾಟ್‌ಫಾರ್ಮ್-ಆಧಾರಿತ ಗಿಗ್ ಕಾರ್ಮಿಕರ ಕಾಯ್ದೆಯಡಿ ವಿವಾದಗಳಿಗೆ ಪುರಾವೆ ನಿರ್ಮಿಸಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ.',
      );
  String get aboutDataStaysHeader =>
      _t('Your data stays on your phone', 'आपका डेटा आपके फ़ोन में ही रहता है', 'ನಿಮ್ಮ ಡೇಟಾ ನಿಮ್ಮ ಫೋನ್‌ನಲ್ಲೇ ಇರುತ್ತದೆ');
  String get aboutDataStaysBody => _t(
        'Orders, expenses, evidence photos and letters are stored only in this app\'s local database — never sent anywhere except when a screenshot is read by the vision AI to extract order details, or when you explicitly export, share, or generate a letter. There is no account and no cloud sync in this build.',
        'ऑर्डर, खर्च, सबूत की फोटो और पत्र सिर्फ़ इस ऐप के लोकल डेटाबेस में सेव होते हैं — कभी कहीं नहीं भेजे जाते, सिवाय तब जब कोई स्क्रीनशॉट ऑर्डर की जानकारी निकालने के लिए विज़न AI को भेजा जाता है, या जब आप खुद एक्सपोर्ट, शेयर या पत्र बनाते हैं. इस वर्ज़न में कोई अकाउंट या क्लाउड सिंक नहीं है.',
        'ಆರ್ಡರ್‌ಗಳು, ಖರ್ಚುಗಳು, ಪುರಾವೆ ಫೋಟೋಗಳು ಮತ್ತು ಪತ್ರಗಳು ಈ ಆ್ಯಪ್‌ನ ಲೋಕಲ್ ಡೇಟಾಬೇಸ್‌ನಲ್ಲಿ ಮಾತ್ರ ಸಂಗ್ರಹವಾಗುತ್ತವೆ — ಆರ್ಡರ್ ವಿವರಗಳನ್ನು ಹೊರತೆಗೆಯಲು ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಅನ್ನು ವಿಷನ್ AI ಓದಿದಾಗ, ಅಥವಾ ನೀವು ಸ್ವತಃ ರಫ್ತು, ಶೇರ್ ಅಥವಾ ಪತ್ರ ರಚಿಸಿದಾಗ ಹೊರತು ಎಲ್ಲಿಗೂ ಕಳುಹಿಸಲಾಗುವುದಿಲ್ಲ. ಈ ಆವೃತ್ತಿಯಲ್ಲಿ ಯಾವುದೇ ಖಾತೆ ಅಥವಾ ಕ್ಲೌಡ್ ಸಿಂಕ್ ಇಲ್ಲ.',
      );
  String get aboutYouControlHeader => _t('You control it', 'यह आपके नियंत्रण में है', 'ಇದು ನಿಮ್ಮ ನಿಯಂತ್ರಣದಲ್ಲಿದೆ');
  String get aboutYouControlBody => _t(
        'Export everything (More → Export everything) at any time as a file you can keep or move elsewhere. Delete everything (More → Delete everything) permanently erases all of it from this phone.',
        'जब चाहें, "सब कुछ एक्सपोर्ट करें" (More → सब कुछ एक्सपोर्ट करें) से एक फ़ाइल के रूप में डेटा निकालें, जिसे आप रख सकते हैं या कहीं और भेज सकते हैं. "सब कुछ हटाएं" (More → सब कुछ हटाएं) इस फ़ोन से सब कुछ हमेशा के लिए मिटा देता है.',
        'ಯಾವಾಗ ಬೇಕಾದರೂ "ಎಲ್ಲವನ್ನೂ ರಫ್ತು ಮಾಡಿ" (More → ಎಲ್ಲವನ್ನೂ ರಫ್ತು ಮಾಡಿ) ಮೂಲಕ ಡೇಟಾವನ್ನು ಫೈಲ್ ಆಗಿ ಪಡೆಯಿರಿ, ಅದನ್ನು ನೀವು ಇಟ್ಟುಕೊಳ್ಳಬಹುದು ಅಥವಾ ಬೇರೆಡೆ ಸ್ಥಳಾಂತರಿಸಬಹುದು. "ಎಲ್ಲವನ್ನೂ ಅಳಿಸಿ" (More → ಎಲ್ಲವನ್ನೂ ಅಳಿಸಿ) ಈ ಫೋನ್‌ನಿಂದ ಎಲ್ಲವನ್ನೂ ಶಾಶ್ವತವಾಗಿ ಅಳಿಸುತ್ತದೆ.',
      );
  String get aboutNotLegalHeader => _t('Not legal advice', 'कानूनी सलाह नहीं है', 'ಕಾನೂನು ಸಲಹೆಯಲ್ಲ');
  String get aboutNotLegalBody => _t(
        'The Letter Generator drafts information requests citing the Act — it is not a substitute for advice from a labour lawyer or union, and its templates are pending their review.',
        'पत्र जनरेटर एक्ट का हवाला देते हुए सूचना-अनुरोध बनाता है — यह लेबर वकील या यूनियन की सलाह का विकल्प नहीं है, और इसके टेम्प्लेट अभी उनकी समीक्षा के इंतज़ार में हैं.',
        'ಪತ್ರ ಜನರೇಟರ್ ಕಾಯ್ದೆಯನ್ನು ಉಲ್ಲೇಖಿಸಿ ಮಾಹಿತಿ-ಕೋರಿಕೆಗಳನ್ನು ರಚಿಸುತ್ತದೆ — ಇದು ಕಾರ್ಮಿಕ ವಕೀಲ ಅಥವಾ ಯೂನಿಯನ್‌ನ ಸಲಹೆಗೆ ಬದಲಿಯಲ್ಲ, ಮತ್ತು ಇದರ ಟೆಂಪ್ಲೇಟ್‌ಗಳು ಅವರ ಪರಿಶೀಲನೆಗಾಗಿ ಕಾಯುತ್ತಿವೆ.',
      );

  // Evidence types (models/evidence_type.dart)
  String evidenceTypeLabel(String key) => switch (key) {
        'notice' => _t('Notices', 'सूचनाएं', 'ಸೂಚನೆಗಳು'),
        'ticket' => _t('Tickets', 'टिकट', 'ಟಿಕೆಟ್‌ಗಳು'),
        'payout' => _t('Payouts', 'भुगतान', 'ಪಾವತಿಗಳು'),
        _ => key,
      };

  // Expense categories (models/expense_category.dart)
  String expenseCategoryLabel(String key) => switch (key) {
        'fuel' => _t('Petrol', 'पेट्रोल', 'ಪೆಟ್ರೋಲ್'),
        'food' => _t('Food', 'खाना', 'ಆಹಾರ'),
        'mobile' => _t('Mobile', 'मोबाइल', 'ಮೊಬೈಲ್'),
        'repair' => _t('Repair', 'रिपेयर', 'ರಿಪೇರಿ'),
        'toll' => _t('Toll', 'टोल', 'ಟೋಲ್'),
        'parking' => _t('Parking', 'पार्किंग', 'ಪಾರ್ಕಿಂಗ್'),
        _ => _t('Other', 'अन्य', 'ಇತರೆ'),
      };

  // Letter templates (models/letter_template.dart)
  String letterTemplateLabel(String key) => switch (key) {
        'deductionExplanation' =>
          _t('Deduction Explanation Request', 'कटौती स्पष्टीकरण अनुरोध', 'ಕಡಿತ ವಿವರಣೆ ಕೋರಿಕೆ'),
        'idBlockReasons' =>
          _t('ID-Block Written Reasons Request', 'ID-ब्लॉक कारण अनुरोध', 'ID-ಬ್ಲಾಕ್ ಕಾರಣ ಕೋರಿಕೆ'),
        'grievanceFiling' =>
          _t('Karnataka Grievance System Filing', 'कर्नाटक शिकायत प्रणाली में आवेदन', 'ಕರ್ನಾಟಕ ಕುಂದುಕೊರತೆ ವ್ಯವಸ್ಥೆಯಲ್ಲಿ ದಾಖಲಿಸಿ'),
        _ => key,
      };
  String letterTemplateDescription(String key) => switch (key) {
        'deductionExplanation' => _t(
            'Ask the platform to explain a pay deduction on a specific order.',
            'किसी खास ऑर्डर पर हुई कटौती का कारण प्लेटफ़ॉर्म से पूछें.',
            'ನಿರ್ದಿಷ್ಟ ಆರ್ಡರ್‌ನಲ್ಲಿ ವೇತನ ಕಡಿತದ ಕಾರಣವನ್ನು ಪ್ಲಾಟ್‌ಫಾರ್ಮ್‌ ಅನ್ನು ಕೇಳಿ.',
          ),
        'idBlockReasons' => _t(
            'Ask for the written reasons behind an account block or suspension.',
            'अकाउंट ब्लॉक या सस्पेंड होने के लिखित कारण मांगें.',
            'ಖಾತೆ ಬ್ಲಾಕ್ ಅಥವಾ ಅಮಾನತಿನ ಹಿಂದಿನ ಲಿಖಿತ ಕಾರಣಗಳನ್ನು ಕೇಳಿ.',
          ),
        'grievanceFiling' => _t(
            'File a grievance with the platform\'s dispute committee or the Karnataka Board.',
            'प्लेटफ़ॉर्म की विवाद समिति या कर्नाटक बोर्ड में शिकायत दर्ज करें.',
            'ಪ್ಲಾಟ್‌ಫಾರ್ಮ್‌ನ ವಿವಾದ ಸಮಿತಿ ಅಥವಾ ಕರ್ನಾಟಕ ಬೋರ್ಡ್‌ನಲ್ಲಿ ಕುಂದುಕೊರತೆ ದಾಖಲಿಸಿ.',
          ),
        _ => '',
      };
}

/// Shorthand for `Strings(AppLocaleScope.of(context).locale)`, read the
/// same way `Theme.of(context)` is.
Strings S(BuildContext context) => Strings(AppLocaleScope.of(context).locale);
