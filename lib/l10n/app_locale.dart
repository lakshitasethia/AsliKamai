import 'package:shared_preferences/shared_preferences.dart';

/// App-wide UI language (build_execution.md Phase 8's "Language toggle
/// (EN/HI/KN) applied app-wide, not just letters"). Separate from
/// [LetterLanguage] in letter_template.dart, which is the language a
/// generated letter's PDF is written in — the two are independent choices.
///
/// Unlike letters, Kannada is NOT restricted here: the Kannada PDF bug
/// (letter_template.dart's [LetterLanguage.selectable] doc) is specific to
/// the `pdf` package's own text shaper. This screen text renders through
/// Flutter's normal text engine (the same one used for `असली कमाई` on the
/// Home tab today), which shapes Kannada correctly — verified on-device
/// before shipping this toggle.
enum AppLocale {
  english,
  hindi,
  kannada;

  String get label => switch (this) {
        AppLocale.english => 'English',
        AppLocale.hindi => 'हिन्दी (Hindi)',
        AppLocale.kannada => 'ಕನ್ನಡ (Kannada)',
      };

  static const _key = 'app_locale';

  static Future<AppLocale> load() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_key);
    return AppLocale.values.firstWhere(
      (l) => l.name == key,
      orElse: () => AppLocale.english,
    );
  }

  static Future<void> save(AppLocale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.name);
  }
}
