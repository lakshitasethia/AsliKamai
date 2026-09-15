import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text styles matching the mockup: Inter/Poppins for headings and numbers,
/// Noto Sans for body copy (chosen for its Devanagari/Kannada coverage,
/// needed once the Hindi/Kannada language toggle lands in a later phase).
abstract final class AppTextStyles {
  static TextStyle get screenTitle => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
      );

  static TextStyle get sectionHeader => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.charcoal,
      );

  static TextStyle get bigNumber => GoogleFonts.inter(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        height: 1.1,
      );

  static TextStyle get statNumber => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.charcoal,
      );

  static TextStyle get body => GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.charcoal,
      );

  static TextStyle get bodyMuted => GoogleFonts.notoSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedGrey,
      );

  static TextStyle get label => GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedGrey,
      );

  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
      );
}
