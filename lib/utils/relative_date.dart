import '../l10n/strings.dart';

/// "Today, 9:41 AM" / "Yesterday, 6:05 PM" / "16/9, 11:22 AM" — used
/// wherever a list of timestamped records (expenses, evidence orders) needs
/// a compact, glanceable date.
///
/// Compares calendar days, not 24-hour spans: 11:28 PM last night is
/// "Yesterday" at 2:47 AM even though it's under 24 hours ago.
String formatRelativeDate(DateTime dt, Strings s, {DateTime? now}) {
  now ??= DateTime.now();
  // UTC dates so a DST shift can't make a day 23/25 hours long.
  final days = DateTime.utc(now.year, now.month, now.day)
      .difference(DateTime.utc(dt.year, dt.month, dt.day))
      .inDays;
  if (days == 0) return '${s.today}, ${_time(dt)}';
  if (days == 1) return '${s.yesterday}, ${_time(dt)}';
  return '${dt.day}/${dt.month}, ${_time(dt)}';
}

String _time(DateTime dt) {
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final period = dt.hour < 12 ? 'AM' : 'PM';
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}
