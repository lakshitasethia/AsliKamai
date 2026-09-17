import 'package:asli_kamai/services/gemini_vision_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('prompt states today\'s date so Gemini can resolve year-less dates', () {
    final prompt = GeminiVisionService.buildPrompt(DateTime(2026, 9, 17));

    expect(prompt, contains('2026-09-17'));
  });

  test('prompt tells Gemini not to guess a future year for a year-less date', () {
    final prompt = GeminiVisionService.buildPrompt(DateTime(2026, 9, 17));

    expect(prompt, contains('never in the future'));
  });
}
