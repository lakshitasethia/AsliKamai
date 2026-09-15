import 'package:flutter/material.dart';

/// Cost categories a rider logs against their earnings (research.md §3.8's
/// Expense model). Keywords drive the voice/text phrase parser.
enum ExpenseCategory {
  fuel,
  food,
  mobile,
  repair,
  toll,
  parking,
  other;

  static const _keywords = {
    ExpenseCategory.fuel: ['petrol', 'diesel', 'fuel', 'gas', 'cng'],
    ExpenseCategory.food: ['food', 'lunch', 'dinner', 'breakfast', 'tea', 'snack', 'water'],
    ExpenseCategory.mobile: ['mobile', 'recharge', 'phone', 'data', 'internet'],
    ExpenseCategory.repair: ['puncture', 'repair', 'service', 'mechanic', 'tyre', 'tire'],
    ExpenseCategory.toll: ['toll'],
    ExpenseCategory.parking: ['parking'],
  };

  /// Matches a category from free-text words (already lowercased), or
  /// [other] if nothing matches.
  static ExpenseCategory fromKeywords(String text) {
    final lower = text.toLowerCase();
    for (final entry in _keywords.entries) {
      for (final keyword in entry.value) {
        if (lower.contains(keyword)) return entry.key;
      }
    }
    return ExpenseCategory.other;
  }

  static ExpenseCategory fromKey(String key) {
    return ExpenseCategory.values.firstWhere(
      (c) => c.name == key.toLowerCase().trim(),
      orElse: () => ExpenseCategory.other,
    );
  }

  String get label => switch (this) {
        ExpenseCategory.fuel => 'Petrol',
        ExpenseCategory.food => 'Food',
        ExpenseCategory.mobile => 'Mobile',
        ExpenseCategory.repair => 'Repair',
        ExpenseCategory.toll => 'Toll',
        ExpenseCategory.parking => 'Parking',
        ExpenseCategory.other => 'Other',
      };

  IconData get icon => switch (this) {
        ExpenseCategory.fuel => Icons.local_gas_station,
        ExpenseCategory.food => Icons.restaurant,
        ExpenseCategory.mobile => Icons.smartphone,
        ExpenseCategory.repair => Icons.build,
        ExpenseCategory.toll => Icons.toll,
        ExpenseCategory.parking => Icons.local_parking,
        ExpenseCategory.other => Icons.receipt_long,
      };
}
