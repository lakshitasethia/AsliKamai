/// "Today, 9:41 AM" / "Yesterday, 6:05 PM" / "16/9, 11:22 AM" — used
/// wherever a list of timestamped records (expenses, evidence orders) needs
/// a compact, glanceable date.
String formatRelativeDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Today, ${_time(dt)}';
  if (diff.inDays == 1) return 'Yesterday, ${_time(dt)}';
  return '${dt.day}/${dt.month}, ${_time(dt)}';
}

String _time(DateTime dt) {
  final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final period = dt.hour < 12 ? 'AM' : 'PM';
  final minute = dt.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}
