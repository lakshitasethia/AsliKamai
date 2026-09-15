import 'package:intl/intl.dart';

final _rupeeFormat = NumberFormat.decimalPattern('en_IN');

/// Formats a rupee amount with Indian digit grouping (₹92,480, not ₹92480).
/// Negative amounts read as "-₹206", not "₹-206" — a real case here, since
/// a bad day's costs can exceed earnings and the app should show that
/// honestly rather than hide or mis-format it.
String formatRupees(num amount) {
  final rounded = amount.round();
  final sign = rounded < 0 ? '-' : '';
  return '$sign₹${_rupeeFormat.format(rounded.abs())}';
}
