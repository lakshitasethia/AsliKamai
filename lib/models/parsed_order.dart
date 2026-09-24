import 'platform.dart';

/// An order as parsed from a screenshot by Gemini, before the rider has
/// confirmed/corrected it on the review screen. Distinct from the `Order`
/// drift row: this is an editable draft that may still have missing or
/// wrong fields.
class ParsedOrder {
  ParsedOrder({
    required this.platform,
    this.orderRef,
    required this.timestamp,
    required this.basePay,
    this.incentive = 0,
    this.tip = 0,
    this.distanceKm,
    this.durationMin,
    this.zone,
    this.sourceScreenshotHash,
    this.screenshotPath,
    this.parseFailed = false,
    this.dateMissing = false,
  });

  GigPlatform platform;
  String? orderRef;
  DateTime timestamp;
  double basePay;
  double incentive;
  double tip;
  double? distanceKm;
  int? durationMin;
  String? zone;
  String? sourceScreenshotHash;

  /// Local path of the persisted copy of the source screenshot (Phase 6),
  /// so a later rate-cut alert can pull it into the Evidence Locker.
  String? screenshotPath;

  /// True when Gemini could not read this screenshot at all — the rider
  /// sees an inline error on this card instead of editable fields.
  bool parseFailed;

  /// True when the screenshot showed no date, so [timestamp] is only a
  /// guess (today) — the review screen asks the rider to set it.
  bool dateMissing;

  double get totalPay => basePay + incentive + tip;
}
