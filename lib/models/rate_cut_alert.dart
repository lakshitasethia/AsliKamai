import '../data/database.dart';

/// Detects a per-platform pay-rate drop between this week and last week
/// (research.md §3.9 / build_execution.md Phase 5). A pure function over
/// already-loaded orders, deliberately independent of the database and any
/// UI, so a future local-push-notification caller can reuse it as-is.
class RateCutAlert {
  RateCutAlert({
    required this.platform,
    required this.thisWeekRatePerKm,
    required this.lastWeekRatePerKm,
    required this.beforeOrder,
    required this.evidenceOrders,
  });

  static const dropThresholdPercent = 10.0;

  final String platform;
  final double thisWeekRatePerKm;
  final double lastWeekRatePerKm;

  /// The most recent last-week order for [platform] — the "before" half of
  /// research.md's "saves the before and after screenshots automatically".
  final Order beforeOrder;

  /// The 5 most recent this-week orders for [platform], most recent first —
  /// the "after" evidence, shown as proof of the lower rate.
  final List<Order> evidenceOrders;

  double get dropPercent =>
      (lastWeekRatePerKm - thisWeekRatePerKm) / lastWeekRatePerKm * 100;

  /// Returns the platform with the worst (largest) rate cut of >= 10%
  /// between [lastWeekOrders] and [thisWeekOrders], or null if no platform
  /// has both weeks' data with a qualifying drop.
  static RateCutAlert? detect({
    required List<Order> thisWeekOrders,
    required List<Order> lastWeekOrders,
  }) {
    final thisWeekByPlatform = _groupByPlatform(thisWeekOrders);
    final lastWeekByPlatform = _groupByPlatform(lastWeekOrders);

    RateCutAlert? worst;
    for (final entry in thisWeekByPlatform.entries) {
      final lastWeekGroup = lastWeekByPlatform[entry.key];
      if (lastWeekGroup == null) continue;

      final thisWeekMedian = _medianRatePerKm(entry.value);
      final lastWeekMedian = _medianRatePerKm(lastWeekGroup);
      if (thisWeekMedian == null || lastWeekMedian == null) continue;
      if (lastWeekMedian <= 0) continue;

      final drop = (lastWeekMedian - thisWeekMedian) / lastWeekMedian * 100;
      if (drop < dropThresholdPercent) continue;
      if (worst != null && drop <= worst.dropPercent) continue;

      final evidence = entry.value
          .where((o) => o.distanceKm != null && o.distanceKm! > 0)
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final beforeOrder = ([...lastWeekGroup]
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp)))
          .first;

      worst = RateCutAlert(
        platform: entry.key,
        thisWeekRatePerKm: thisWeekMedian,
        lastWeekRatePerKm: lastWeekMedian,
        beforeOrder: beforeOrder,
        evidenceOrders: evidence.take(5).toList(),
      );
    }
    return worst;
  }

  static Map<String, List<Order>> _groupByPlatform(List<Order> orders) {
    final map = <String, List<Order>>{};
    for (final o in orders) {
      map.putIfAbsent(o.platform, () => []).add(o);
    }
    return map;
  }

  static double? _medianRatePerKm(List<Order> orders) {
    final rates = orders
        .where((o) => o.distanceKm != null && o.distanceKm! > 0)
        .map((o) => (o.basePay + o.incentive + o.tip) / o.distanceKm!)
        .toList()
      ..sort();
    if (rates.isEmpty) return null;
    final mid = rates.length ~/ 2;
    if (rates.length.isOdd) return rates[mid];
    return (rates[mid - 1] + rates[mid]) / 2;
  }
}
