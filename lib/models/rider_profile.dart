import 'package:shared_preferences/shared_preferences.dart';

import 'platform.dart';

/// Local rider profile: name (Phase 7, for letters to sign off with) plus
/// the platform(s) the rider works (Phase 8's settings screen). Stored as
/// simple key-value pairs rather than a drift table since there's nothing
/// relational about it.
class RiderProfile {
  RiderProfile({required this.name, required this.platforms});

  final String name;
  final List<GigPlatform> platforms;

  static const _nameKey = 'rider_profile_name';
  static const _platformsKey = 'rider_profile_platforms';

  static Future<RiderProfile> load() async {
    final prefs = await SharedPreferences.getInstance();
    final platformKeys = prefs.getStringList(_platformsKey) ?? const [];
    return RiderProfile(
      name: prefs.getString(_nameKey) ?? '',
      platforms: platformKeys.map(GigPlatform.fromKey).toList(),
    );
  }

  static Future<void> saveName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  static Future<void> savePlatforms(List<GigPlatform> platforms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _platformsKey,
      platforms.map((p) => p.name).toList(),
    );
  }

  /// Clears both fields — used by "Delete everything".
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_nameKey);
    await prefs.remove(_platformsKey);
  }
}
