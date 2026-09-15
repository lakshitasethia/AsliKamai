import 'package:flutter/material.dart';

/// Design tokens matching the AsliKamai mockup's design system exactly.
/// Do not use raw [Color] literals elsewhere in the app — always go through
/// these tokens so the app stays visually consistent as new screens are added.
abstract final class AppColors {
  static const primaryGreen = Color(0xFF10684F);
  static const warmYellow = Color(0xFFF6C945);
  static const cream = Color(0xFFFFF8EC);
  static const charcoal = Color(0xFF1F2937);
  static const mutedGrey = Color(0xFF6B7280);
  static const redAlert = Color(0xFFEF4444);

  static const white = Color(0xFFFFFFFF);
  static const successGreen = Color(0xFF10684F);
  static const cardBorder = Color(0xFFE7E0D2);
}
