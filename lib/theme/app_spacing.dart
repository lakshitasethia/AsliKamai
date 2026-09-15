/// Spacing scale used across the app so padding/margins stay consistent.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;

  /// Side gutter for screen content — matches the mockup's card insets and
  /// keeps content clear of screen edges/notches on every device width.
  static const screenPadding = 16.0;

  static const cardRadius = 16.0;
  static const buttonRadius = 14.0;
}
