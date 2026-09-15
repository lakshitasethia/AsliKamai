import 'package:asli_kamai/data/database.dart';
import 'package:asli_kamai/models/weekly_dashboard_data.dart';
import 'package:flutter_test/flutter_test.dart';

Order _order({
  required String platform,
  required DateTime timestamp,
  required double basePay,
  double incentive = 0,
  double tip = 0,
  double? distanceKm,
  int? durationMin,
  String? zone,
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
    durationMin: durationMin,
    zone: zone,
    sourceScreenshotHash: null,
    createdAt: timestamp,
  );
}

void main() {
  final weekStart = DateTime(2026, 9, 14);
  final weekEnd = weekStart.add(const Duration(days: 7));

  test('empty week has isEmpty true and no divide-by-zero crashes', () {
    final data = WeeklyDashboardData.fromOrders(
      weekStart: weekStart,
      weekEnd: weekEnd,
      orders: [],
    );

    expect(data.isEmpty, isTrue);
    expect(data.net, 0);
    expect(data.netPerHour, isNull);
    expect(data.netPerKm, isNull);
    expect(data.bestHour, isNull);
    expect(data.worstHour, isNull);
    expect(data.topZones, isEmpty);
  });

  test('gross/net/rate math matches hand calculation', () {
    final orders = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14, 8),
        basePay: 45,
        tip: 5,
        distanceKm: 2.8,
        durationMin: 15,
        zone: 'Koramangala',
      ),
      _order(
        platform: 'zomato',
        timestamp: DateTime(2026, 9, 14, 19, 30),
        basePay: 60,
        incentive: 10,
        distanceKm: 4.1,
        durationMin: 22,
        zone: 'Indiranagar',
      ),
    ];

    final data = WeeklyDashboardData.fromOrders(
      weekStart: weekStart,
      weekEnd: weekEnd,
      orders: orders,
    );

    expect(data.gross, 120); // 50 + 70
    expect(data.costs, 0); // Expense tracking lands in Phase 4
    expect(data.net, 120);
    expect(data.totalIncentive, 10);
    expect(data.totalHours, closeTo(37 / 60, 0.001));
    expect(data.totalKm, closeTo(6.9, 0.001));
    expect(data.netPerHour, closeTo(120 / (37 / 60), 0.01));
    expect(data.netPerKm, closeTo(120 / 6.9, 0.01));
    expect(data.netWithoutIncentive, 110);
    expect(data.incentiveUpliftPercent, closeTo(10 / 110 * 100, 0.01));
  });

  test('best/worst hour picks the highest and lowest ₹/hr buckets', () {
    final orders = [
      // Hour 19: high rate.
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14, 19),
        basePay: 100,
        durationMin: 20,
      ),
      // Hour 3: low rate.
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 15, 3),
        basePay: 20,
        durationMin: 30,
      ),
    ];

    final data = WeeklyDashboardData.fromOrders(
      weekStart: weekStart,
      weekEnd: weekEnd,
      orders: orders,
    );

    expect(data.bestHour!.hour, 19);
    expect(data.worstHour!.hour, 3);
    expect(data.bestHour!.ratePerHour, closeTo(300, 0.01)); // 100 / (20/60)
    expect(data.worstHour!.ratePerHour, closeTo(40, 0.01)); // 20 / (30/60)
  });

  test('single order week: best/worst hour collapse to one bucket', () {
    final orders = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14, 10),
        basePay: 50,
        durationMin: 20,
        distanceKm: 3,
      ),
    ];

    final data = WeeklyDashboardData.fromOrders(
      weekStart: weekStart,
      weekEnd: weekEnd,
      orders: orders,
    );

    // Only one hour bucket exists, so there's no meaningful "worst" —
    // best and worst would be identical, so worstHour is suppressed.
    expect(data.bestHour, isNotNull);
    expect(data.worstHour, isNull);
  });

  test('zones with no distance are excluded from the ranking', () {
    final orders = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14, 10),
        basePay: 50,
        zone: 'Koramangala',
        distanceKm: null, // no distance -> can't compute ₹/km
      ),
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14, 11),
        basePay: 40,
        zone: 'Indiranagar',
        distanceKm: 2,
      ),
    ];

    final data = WeeklyDashboardData.fromOrders(
      weekStart: weekStart,
      weekEnd: weekEnd,
      orders: orders,
    );

    expect(data.topZones, hasLength(1));
    expect(data.topZones.first.zone, 'Indiranagar');
  });

  test('incentiveUpliftPercent is null when without-incentive net is zero',
      () {
    final orders = [
      _order(
        platform: 'swiggy',
        timestamp: DateTime(2026, 9, 14, 10),
        basePay: 0,
        incentive: 50,
      ),
    ];

    final data = WeeklyDashboardData.fromOrders(
      weekStart: weekStart,
      weekEnd: weekEnd,
      orders: orders,
    );

    expect(data.netWithoutIncentive, 0);
    expect(data.incentiveUpliftPercent, isNull);
  });
}
