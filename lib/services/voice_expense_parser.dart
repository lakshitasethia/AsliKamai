import '../models/expense_category.dart';

class ParsedExpense {
  ParsedExpense({required this.category, required this.amount, required this.rawText});

  final ExpenseCategory category;
  final double amount;
  final String rawText;
}

/// Finds the last number in [text] and treats the rest as category words —
/// e.g. "petrol 300" or "300 for petrol" both work. Returns null if no
/// number is found at all, so the caller can fall back to manual entry.
ParsedExpense? parseExpensePhrase(String text) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;

  final matches = RegExp(r'\d+(\.\d+)?').allMatches(trimmed).toList();
  if (matches.isEmpty) return null;

  final last = matches.last;
  final amount = double.tryParse(last.group(0)!);
  if (amount == null || amount <= 0) return null;

  final words = (trimmed.substring(0, last.start) + trimmed.substring(last.end))
      .replaceAll(RegExp(r'\bfor\b|\brs\.?\b|\brupees?\b', caseSensitive: false), ' ')
      .trim();

  return ParsedExpense(
    category: ExpenseCategory.fromKeywords(words),
    amount: amount,
    rawText: trimmed,
  );
}
