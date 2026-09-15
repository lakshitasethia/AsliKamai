import '../data/database.dart';

class HourlyRate {
  HourlyRate({required this.hour, required this.ratePerHour});

  /// 0-23, the hour-of-day bucket this rate was computed for.
  final int hour;
  final double ratePerHour;

  String get label {
    final start = _formatHour(hour);
    final end = _formatHour((hour + 1) % 24);
    return '$start - $end';
  }

  static String _formatHour(int h) {
    final period = h < 12 ? 'AM' : 'PM';
    final twelve = h % 12 == 0 ? 12 : h % 12;
    return '$twelve $period';
  }
}

class ZoneRate {
  ZoneRate({required this.zone, required this.ratePerKm});

  final String zone;
  final double ratePerKm;
}

/// All figures the Weekly Dashboard (mockup screen 3) needs, computed from
/// this week's Orders and Expenses.
class WeeklyDashboardData {
  WeeklyDashboardData({
    required this.weekStart,
    required this.weekEnd,
    required this.orderCount,
    required this.gross,
    required this.costs,
    required this.totalIncentive,
    required this.totalHours,
    required this.totalKm,
    required this.bestHour,
    required this.worstHour,
    required this.topZones,
  });

  final DateTime weekStart;
  final DateTime weekEnd;
  final int orderCount;
  final double gross;
  final double costs;
  final double totalIncentive;
  final double totalHours;
  final double totalKm;
  final HourlyRate? bestHour;
  final HourlyRate? worstHour;
  final List<ZoneRate> topZones;

  double get net => gross - costs;
  double? get netPerHour => totalHours > 0 ? net / totalHours : null;
  double? get netPerKm => totalKm > 0 ? net / totalKm : null;

  double get netWithoutIncentive => net - totalIncentive;
  double? get incentiveUpliftPercent {
    if (netWithoutIncentive <= 0) return null;
    return (totalIncentive / netWithoutIncentive) * 100;
  }

  bool get isEmpty => orderCount == 0;

  factory WeeklyDashboardData.fromOrders({
    required DateTime weekStart,
    required DateTime weekEnd,
    required List<Order> orders,
    List<Expense> expenses = const [],
  }) {
    final gross = orders.fold<double>(
      0,
      (sum, o) => sum + o.basePay + o.incentive + o.tip,
    );
    final costs = expenses.fold<double>(0, (sum, e) => sum + e.amount);
    final totalIncentive = orders.fold<double>(0, (sum, o) => sum + o.incentive);
    final totalMinutes = orders.fold<int>(
      0,
      (sum, o) => sum + (o.durationMin ?? 0),
    );
    final totalKm = orders.fold<double>(
      0,
      (sum, o) => sum + (o.distanceKm ?? 0),
    );

    final hourly = _hourlyRates(orders);
    HourlyRate? best;
    HourlyRate? worst;
    for (final h in hourly) {
      if (best == null || h.ratePerHour > best.ratePerHour) best = h;
      if (worst == null || h.ratePerHour < worst.ratePerHour) worst = h;
    }

    return WeeklyDashboardData(
      weekStart: weekStart,
      weekEnd: weekEnd,
      orderCount: orders.length,
      gross: gross,
      costs: costs,
      totalIncentive: totalIncentive,
      totalHours: totalMinutes / 60,
      totalKm: totalKm,
      bestHour: best,
      worstHour: (worst != null && best != null && worst.hour != best.hour)
          ? worst
          : null,
      topZones: _topZones(orders),
    );
  }

  static List<HourlyRate> _hourlyRates(List<Order> orders) {
    final payByHour = <int, double>{};
    final minutesByHour = <int, int>{};
    for (final o in orders) {
      final hour = o.timestamp.hour;
      final pay = o.basePay + o.incentive + o.tip;
      payByHour[hour] = (payByHour[hour] ?? 0) + pay;
      minutesByHour[hour] = (minutesByHour[hour] ?? 0) + (o.durationMin ?? 0);
    }
    final rates = <HourlyRate>[];
    for (final hour in payByHour.keys) {
      final minutes = minutesByHour[hour] ?? 0;
      if (minutes <= 0) continue;
      rates.add(HourlyRate(hour: hour, ratePerHour: payByHour[hour]! / (minutes / 60)));
    }
    return rates;
  }

  static List<ZoneRate> _topZones(List<Order> orders) {
    final payByZone = <String, double>{};
    final kmByZone = <String, double>{};
    for (final o in orders) {
      final zone = o.zone;
      if (zone == null || zone.trim().isEmpty) continue;
      final km = o.distanceKm;
      if (km == null || km <= 0) continue;
      final pay = o.basePay + o.incentive + o.tip;
      payByZone[zone] = (payByZone[zone] ?? 0) + pay;
      kmByZone[zone] = (kmByZone[zone] ?? 0) + km;
    }
    final zones = payByZone.keys
        .map((z) => ZoneRate(zone: z, ratePerKm: payByZone[z]! / kmByZone[z]!))
        .toList()
      ..sort((a, b) => b.ratePerKm.compareTo(a.ratePerKm));
    return zones.take(3).toList();
  }
}
