import 'package:asli_kamai/utils/currency.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('formats positive amounts with Indian digit grouping', () {
    expect(formatRupees(92480), '₹92,480');
    expect(formatRupees(681), '₹681');
  });

  test('rounds to the nearest rupee', () {
    expect(formatRupees(299.6), '₹300');
    expect(formatRupees(299.4), '₹299');
  });

  test('puts the minus sign before the currency symbol for negative amounts', () {
    expect(formatRupees(-206), '-₹206');
    expect(formatRupees(-1234), '-₹1,234');
  });

  test('zero has no sign', () {
    expect(formatRupees(0), '₹0');
  });
}
