import 'package:asli_kamai/data/database.dart';
import 'package:asli_kamai/models/rate_cut_alert.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order({
  required String platform,
  required DateTime timestamp,
  required double basePay,
  double incentive = 0,
  double tip = 0,
  double? distanceKm,
}) {
  return Order(
    id: 0,
    platform: platform,
    orderRef: null,
    timestamp: timestamp,
    basePay: basePay,
    incentive: incentive,
    tip: tip,
    distanceKm: distanceKm,
    durationMin: null,
    zone: null,
    sourceScreenshotHash: null,
    createdAt: timestamp,
  );
}

void main() {
  test('no alert when there is no prior-week data at all', () {
    final thisWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14),
        basePay: 20,
        distanceKm: 2,
      ),
    ];

    final alert = RateCutAlert.detect(
      thisWeekOrders: thisWeek,
      lastWeekOrders: [],
    );

    expect(alert, isNull);
  });

  test('no alert when the drop is below the 10% threshold', () {
    // last week: ₹50/km. this week: ₹46/km -> 8% drop.
    final lastWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 7),
        basePay: 100,
        distanceKm: 2,
      ),
    ];
    final thisWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14),
        basePay: 92,
        distanceKm: 2,
      ),
    ];

    final alert = RateCutAlert.detect(
      thisWeekOrders: thisWeek,
      lastWeekOrders: lastWeek,
    );

    expect(alert, isNull);
  });

  test('detects a rate cut of >= 10% and reports before/after ₹/km', () {
    // last week: ₹50/km. this week: ₹30/km -> 40% drop.
    final lastWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 7),
        basePay: 100,
        distanceKm: 2,
      ),
    ];
    final thisWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14),
        basePay: 60,
        distanceKm: 2,
      ),
    ];

    final alert = RateCutAlert.detect(
      thisWeekOrders: thisWeek,
      lastWeekOrders: lastWeek,
    );

    expect(alert, isNotNull);
    expect(alert!.platform, 'swiggy');
    expect(alert.lastWeekRatePerKm, closeTo(50, 0.01));
    expect(alert.thisWeekRatePerKm, closeTo(30, 0.01));
    expect(alert.dropPercent, closeTo(40, 0.01));
  });

  test('ignores platforms with orders this week but no orders last week', () {
    final lastWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 7),
        basePay: 100,
        distanceKm: 2,
      ),
    ];
    final thisWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14),
        basePay: 60,
        distanceKm: 2,
      ),
      // zomato has no prior-week data -> can't be compared, no matter
      // how low this looks.
      _order(
        platform: 'zomato',
        timestamp: DateTime(2026, 9, 14),
        basePay: 2,
        distanceKm: 2,
      ),
    ];

    final alert = RateCutAlert.detect(
      thisWeekOrders: thisWeek,
      lastWeekOrders: lastWeek,
    );

    expect(alert!.platform, 'swiggy');
  });

  test('when multiple platforms show a cut, reports the largest drop', () {
    final lastWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 7),
        basePay: 100,
        distanceKm: 2, // ₹50/km
      ),
      _order(
        platform: 'zomato',
        timestamp: DateTime(2026, 9, 7),
        basePay: 100,
        distanceKm: 2, // ₹50/km
      ),
    ];
    final thisWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14),
        basePay: 90,
        distanceKm: 2, // ₹45/km -> 10% drop
      ),
      _order(
        platform: 'zomato',
        timestamp: DateTime(2026, 9, 14),
        basePay: 20,
        distanceKm: 2, // ₹10/km -> 80% drop
      ),
    ];

    final alert = RateCutAlert.detect(
      thisWeekOrders: thisWeek,
      lastWeekOrders: lastWeek,
    );

    expect(alert!.platform, 'zomato');
    expect(alert.dropPercent, closeTo(80, 0.01));
  });

  test('evidence is the 5 most recent this-week orders for the flagged platform', () {
    final lastWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 7),
        basePay: 100,
        distanceKm: 2,
      ),
    ];
    final thisWeek = [
      for (var day = 14; day <= 20; day++)
        _order(
          platform: 'swiggy',
          timestamp: DateTime(2026, 9, day),
          basePay: 60,
          distanceKm: 2,
        ),
    ]; // 7 orders, one per day 14..20

    final alert = RateCutAlert.detect(
      thisWeekOrders: thisWeek,
      lastWeekOrders: lastWeek,
    );

    expect(alert!.evidenceOrders, hasLength(5));
    // most recent first
    expect(alert.evidenceOrders.first.timestamp, DateTime(2026, 9, 20));
    expect(alert.evidenceOrders.last.timestamp, DateTime(2026, 9, 16));
  });

  test('orders without distanceKm are excluded from the rate calculation', () {
    final lastWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 7),
        basePay: 100,
        distanceKm: 2, // ₹50/km
      ),
    ];
    final thisWeek = [
      // No distance -> excluded, would otherwise skew the median.
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14),
        basePay: 1000,
        distanceKm: null,
      ),
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 15),
        basePay: 60,
        distanceKm: 2, // ₹30/km -> 40% drop
      ),
    ];

    final alert = RateCutAlert.detect(
      thisWeekOrders: thisWeek,
      lastWeekOrders: lastWeek,
    );

    expect(alert!.thisWeekRatePerKm, closeTo(30, 0.01));
  });

  test('median of an even number of orders averages the two middle values', () {
    final lastWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 7),
        basePay: 100,
        distanceKm: 2, // ₹50/km
      ),
    ];
    final thisWeek = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14),
        basePay: 20,
        distanceKm: 2, // ₹10/km
      ),
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 15),
        basePay: 40,
        distanceKm: 2, // ₹20/km
      ),
    ]; // median = (10 + 20) / 2 = 15

    final alert = RateCutAlert.detect(
      thisWeekOrders: thisWeek,
      lastWeekOrders: lastWeek,
    );

    expect(alert!.thisWeekRatePerKm, closeTo(15, 0.01));
  });
}
