import 'package:asli_kamai/models/expense_category.dart';
import 'package:asli_kamai/services/voice_expense_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses "category amount" phrases', () {
    final result = parseExpensePhrase('petrol 300');
    expect(result, isNotNull);
    expect(result!.category, ExpenseCategory.fuel);
    expect(result.amount, 300);
  });

  test('parses "amount for category" phrases', () {
    final result = parseExpensePhrase('300 for petrol');
    expect(result, isNotNull);
    expect(result!.category, ExpenseCategory.fuel);
    expect(result.amount, 300);
  });

  test('recognizes each known category keyword', () {
    expect(parseExpensePhrase('puncture 50')!.category, ExpenseCategory.repair);
    expect(parseExpensePhrase('lunch 120')!.category, ExpenseCategory.food);
    expect(parseExpensePhrase('mobile recharge 199')!.category, ExpenseCategory.mobile);
    expect(parseExpensePhrase('toll 40')!.category, ExpenseCategory.toll);
    expect(parseExpensePhrase('parking 20')!.category, ExpenseCategory.parking);
  });

  test('unrecognized category words fall back to "other"', () {
    final result = parseExpensePhrase('chai 15');
    expect(result, isNotNull);
    expect(result!.category, ExpenseCategory.other);
    expect(result.amount, 15);
  });

  test('handles decimal amounts', () {
    final result = parseExpensePhrase('petrol 299.50');
    expect(result!.amount, 299.5);
  });

  test('strips "rs"/"rupees" filler words', () {
    final result = parseExpensePhrase('petrol rs 300');
    expect(result!.category, ExpenseCategory.fuel);
    expect(result.amount, 300);
  });

  test('returns null when no number is present', () {
    expect(parseExpensePhrase('petrol'), isNull);
    expect(parseExpensePhrase(''), isNull);
    expect(parseExpensePhrase('   '), isNull);
  });

  test('returns null for a zero or negative amount', () {
    expect(parseExpensePhrase('petrol 0'), isNull);
  });
}
