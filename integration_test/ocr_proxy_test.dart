import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:asli_kamai/models/platform.dart';
import 'package:asli_kamai/services/gemini_vision_service.dart';

import 'fixtures/screenshots.dart';

/// Live end-to-end check of screenshot OCR: the app's bundled `.env` →
/// the `gemini-proxy` Supabase Edge Function → Gemini → parsed order. Uses
/// real network and counts against the Gemini free-tier quota (2 calls
/// per run), so it's kept separate from the screen walkthrough:
///   flutter test integration_test/ocr_proxy_test.dart -d DEVICE_ID --no-uninstall
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: '.env');
    // Release builds must go through the proxy, never a bundled Gemini key.
    expect(dotenv.env['GEMINI_API_KEY'], isNull,
        reason: 'a Gemini key in .env would ship inside the APK');
    expect(dotenv.env['SUPABASE_URL'], isNotEmpty);
  });

  test('reads a Swiggy order screenshot through the proxy', () async {
    final order = await GeminiVisionService().parseScreenshot(
      imageBytes: base64Decode(swiggyOrderPng),
      screenshotHash: 'e2e-swiggy',
    );

    expect(order.parseFailed, isFalse);
    expect(order.platform, GigPlatform.swiggy);
    expect(order.orderRef, contains('62001'));
    expect(order.basePay, 80);
    expect(order.incentive, 20);
    expect(order.tip, 10);
    expect(order.distanceKm, 3.4);
    expect(order.durationMin, 19);
    expect(order.timestamp.month, 9);
    expect(order.timestamp.day, 21);
  }, timeout: const Timeout(Duration(minutes: 3)));

  test('flags a non-order screenshot instead of inventing an order', () async {
    final order = await GeminiVisionService().parseScreenshot(
      imageBytes: base64Decode(notAnOrderPng),
      screenshotHash: 'e2e-not-order',
    );

    expect(order.parseFailed, isTrue);
  }, timeout: const Timeout(Duration(minutes: 3)));
}
