import 'package:asli_kamai/services/evidence_pdf_export.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('replaces the rupee sign with an ASCII-safe form', () {
    expect(sanitizeForPdf('₹40/km'), 'Rs.40/km');
  });

  test('replaces the down arrow with an ASCII-safe form', () {
    expect(sanitizeForPdf('↓60%'), '-60%');
  });

  test('replaces the right arrow with an ASCII-safe form', () {
    expect(sanitizeForPdf('₹40 → ₹16'), 'Rs.40 -> Rs.16');
  });

  test('replaces the em dash with an ASCII-safe form', () {
    expect(sanitizeForPdf('Draft — pending review'), 'Draft - pending review');
  });

  test('leaves plain ASCII text untouched', () {
    expect(sanitizeForPdf('Rate-cut evidence: zomato'), 'Rate-cut evidence: zomato');
  });
}
