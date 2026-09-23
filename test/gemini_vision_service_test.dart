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

  test('notice-date prompt is anchored to today and ignores the status-bar clock', () {
    final prompt =
        GeminiVisionService.buildDocumentDatePrompt(DateTime(2026, 9, 22));

    expect(prompt, contains('2026-09-22'));
    expect(prompt, contains('status-bar'));
  });

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

  group('GeminiRoute', () {
    test('goes through the Supabase proxy when it is configured', () {
      final route = GeminiRoute.fromEnv({
        'SUPABASE_URL': 'https://abc.supabase.co',
        'SUPABASE_PUBLISHABLE_KEY': 'sb_publishable_x',
        'GEMINI_API_KEY': 'secret',
      })!;

      expect(
        route.uriFor('gemini-3.6-flash').toString(),
        'https://abc.supabase.co/functions/v1/gemini-proxy?model=gemini-3.6-flash',
      );
      expect(route.headers, {'apikey': 'sb_publishable_x'});
      expect(route.headers.values, isNot(contains('secret')));
    });

    test('falls back to a direct Gemini key for local dev', () {
      final route = GeminiRoute.fromEnv({'GEMINI_API_KEY': 'secret'})!;

      expect(route.uriFor('m').host, 'generativelanguage.googleapis.com');
      expect(route.uriFor('m').query, isEmpty);
      expect(route.headers['x-goog-api-key'], 'secret');
    });

    test('is unconfigured with neither set', () {
      expect(GeminiRoute.fromEnv({}), isNull);
      expect(GeminiRoute.fromEnv({'GEMINI_API_KEY': 'your_key_here'}), isNull);
    });
  });
}
