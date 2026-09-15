import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Delivery/ride platforms this app knows how to read screenshots from.
/// Matches research.md §3.8's MVP scope (Swiggy, Zomato, Blinkit, Zepto).
enum GigPlatform {
  swiggy,
  zomato,
  blinkit,
  zepto,
  other;

  static GigPlatform fromKey(String key) {
    return GigPlatform.values.firstWhere(
      (p) => p.name == key.toLowerCase().trim(),
      orElse: () => GigPlatform.other,
    );
  }

  String get label => switch (this) {
        GigPlatform.swiggy => 'Swiggy',
        GigPlatform.zomato => 'Zomato',
        GigPlatform.blinkit => 'Blinkit',
        GigPlatform.zepto => 'Zepto',
        GigPlatform.other => 'Other',
      };

  Color get color => switch (this) {
        GigPlatform.swiggy => const Color(0xFFFC8019),
        GigPlatform.zomato => const Color(0xFFE23744),
        GigPlatform.blinkit => const Color(0xFFF8CB46),
        GigPlatform.zepto => const Color(0xFF8A2BE2),
        GigPlatform.other => AppColors.mutedGrey,
      };

  IconData get icon => switch (this) {
        GigPlatform.swiggy => Icons.delivery_dining,
        GigPlatform.zomato => Icons.restaurant,
        GigPlatform.blinkit => Icons.local_grocery_store,
        GigPlatform.zepto => Icons.bolt,
        GigPlatform.other => Icons.storefront,
      };
}
