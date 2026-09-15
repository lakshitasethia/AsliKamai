import 'package:intl/intl.dart';

final _rupeeFormat = NumberFormat.decimalPattern('en_IN');

/// Formats a rupee amount with Indian digit grouping (₹92,480, not ₹92480).
String formatRupees(num amount) => '₹${_rupeeFormat.format(amount.round())}';
