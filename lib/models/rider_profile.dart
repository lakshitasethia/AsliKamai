import 'package:shared_preferences/shared_preferences.dart';

/// Minimal local rider profile (Phase 7) — just enough for letters to sign
/// off with. A full settings/profile screen (name, platform(s), data
/// export/delete) is Phase 8; this is a deliberately small pull-forward of
/// just the `name` field, stored as a simple key-value pair rather than a
/// drift table since there's nothing relational about it.
class RiderProfile {
  RiderProfile({required this.name});

  final String name;

  static const _nameKey = 'rider_profile_name';

  static Future<RiderProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    return RiderProfile(name: prefs.getString(_nameKey) ?? '');
  }

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }
}
