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
    this.parseFailed = false,
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

  /// True when Gemini could not read this screenshot at all — the rider
  /// sees an inline error on this card instead of editable fields.
  bool parseFailed;

  double get totalPay => basePay + incentive + tip;
}
