/// Monday-to-Sunday week containing [date].
class WeekRange {
  WeekRange(DateTime date)
      : start = _mondayOf(date),
        end = _mondayOf(date).add(const Duration(days: 7));

  WeekRange._(this.start, this.end);

  final DateTime start;
  final DateTime end; // exclusive

  DateTime get inclusiveEnd => end.subtract(const Duration(seconds: 1));

  WeekRange previous() => WeekRange._(
        start.subtract(const Duration(days: 7)),
        end.subtract(const Duration(days: 7)),
      );

  WeekRange next() => WeekRange._(
        start.add(const Duration(days: 7)),
        end.add(const Duration(days: 7)),
      );

  bool get isCurrentWeek => WeekRange(DateTime.now()).start == start;

  static DateTime _mondayOf(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  String get label {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final last = inclusiveEnd;
    final startStr = '${months[start.month - 1]} ${start.day}';
    if (start.year != last.year) {
      return '$startStr, ${start.year} – ${months[last.month - 1]} ${last.day}, ${last.year}';
    }
    return '$startStr – ${months[last.month - 1]} ${last.day}, ${last.year}';
  }
}
