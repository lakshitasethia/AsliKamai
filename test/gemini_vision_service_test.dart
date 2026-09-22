import 'package:asli_kamai/services/gemini_vision_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prompt states today\'s date so Gemini can resolve year-less dates', () {
    final prompt = GeminiVisionService.buildPrompt(DateTime(2026, 9, 17));

    expect(prompt, contains('2026-09-17'));
  });

  test(
    'prompt tells Gemini not to guess a future year for a year-less date',
    () {
      final prompt = GeminiVisionService.buildPrompt(DateTime(2026, 9, 17));

      expect(prompt, contains('never in the future'));
    },
  );

  test('PNG screenshots are sent as image/png, not mislabelled as JPEG', () {
    final png = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A];

    expect(GeminiVisionService.mimeTypeFor(png), 'image/png');
  });

  test('JPEG and unknown bytes fall back to image/jpeg', () {
    expect(
      GeminiVisionService.mimeTypeFor([0xFF, 0xD8, 0xFF, 0xE0]),
      'image/jpeg',
    );
    expect(GeminiVisionService.mimeTypeFor([]), 'image/jpeg');
  });

  test('WebP images are detected', () {
    final webp = [0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50];

    expect(GeminiVisionService.mimeTypeFor(webp), 'image/webp');
  });

  test('OCR tries the fast flash model first, with lite fallbacks', () {
    expect(GeminiVisionService.models.first, 'gemini-3.6-flash');
    expect(GeminiVisionService.models.length, greaterThan(1));
  });
}
