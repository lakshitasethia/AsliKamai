import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/parsed_order.dart';
import '../models/platform.dart';

/// Thrown when the API key is missing/empty, so callers can show a specific
/// "app isn't set up yet" message instead of a generic parse failure.
class GeminiNotConfiguredException implements Exception {}

/// Thrown for network/API-level failures (no internet, bad response, etc).
class GeminiRequestException implements Exception {
  GeminiRequestException(this.message);
  final String message;

  @override
  String toString() => 'GeminiRequestException: $message';
}

/// Sends one delivery-partner-app screenshot to Gemini and gets back a
/// structured order record. Screenshot bytes are sent for this single
/// call only and are not persisted anywhere server-side by this app.
class GeminiVisionService {
  // Pinned rather than an alias like gemini-flash-latest: aliases can return
  // 503 under load, and pinning keeps behavior stable as newer models ship.
  static const _model = 'gemini-3.5-flash';
  static const _endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  static const _prompt = '''
You are reading a single screenshot from an Indian gig-delivery partner app
(Swiggy, Zomato, Blinkit, or Zepto driver/partner app). Extract the ONE order
shown on this screen into JSON matching the given schema.

Rules:
- platform: one of swiggy, zomato, blinkit, zepto, other — infer from logo/branding/text.
- base_pay, incentive, tip: rupee amounts as plain numbers (no currency symbol). If a
  breakdown isn't shown separately, put the whole visible payout in base_pay and 0 for
  the others.
- distance_km and duration_min: null if not visible on screen.
- timestamp: best-guess ISO 8601 date-time for when this order happened, using any date/time
  visible on screen. If no date is visible, use today's date with the visible time, or null
  if no time is visible either.
- order_ref: the order/trip ID shown on screen, or null if none is visible.
- zone: the area/locality name shown on screen (e.g. "Koramangala"), or null.
- If this does not look like a delivery-partner-app order screen at all, set
  "not_an_order_screen" to true and leave other fields as best-effort or null.
''';

  static final _responseSchema = {
    'type': 'OBJECT',
    'properties': {
      'not_an_order_screen': {'type': 'BOOLEAN'},
      'platform': {
        'type': 'STRING',
        'enum': ['swiggy', 'zomato', 'blinkit', 'zepto', 'other'],
      },
      'order_ref': {'type': 'STRING', 'nullable': true},
      'timestamp': {'type': 'STRING', 'nullable': true},
      'base_pay': {'type': 'NUMBER'},
      'incentive': {'type': 'NUMBER'},
      'tip': {'type': 'NUMBER'},
      'distance_km': {'type': 'NUMBER', 'nullable': true},
      'duration_min': {'type': 'INTEGER', 'nullable': true},
      'zone': {'type': 'STRING', 'nullable': true},
    },
    'required': ['platform', 'base_pay', 'incentive', 'tip'],
  };

  Future<ParsedOrder> parseScreenshot({
    required List<int> imageBytes,
    required String screenshotHash,
  }) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'your_key_here') {
      throw GeminiNotConfiguredException();
    }

    final base64Image = base64Encode(imageBytes);
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': _prompt},
            {
              'inline_data': {'mime_type': 'image/jpeg', 'data': base64Image},
            },
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': _responseSchema,
        // Straightforward extraction task — extended thinking adds cost
        // and latency without improving accuracy here (verified: identical
        // output with ~7x fewer tokens with thinking disabled).
        'thinkingConfig': {'thinkingBudget': 0},
      },
    });

    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$_endpoint?key=$apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 30));
    } catch (e) {
      throw GeminiRequestException('Could not reach Gemini: $e');
    }

    if (response.statusCode != 200) {
      throw GeminiRequestException(
        'Gemini returned ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw GeminiRequestException('Gemini returned no candidates.');
    }

    final text = candidates[0]['content']['parts'][0]['text'] as String;
    final parsed = jsonDecode(text) as Map<String, dynamic>;

    if (parsed['not_an_order_screen'] == true) {
      return ParsedOrder(
        platform: GigPlatform.other,
        timestamp: DateTime.now(),
        basePay: 0,
        sourceScreenshotHash: screenshotHash,
        parseFailed: true,
      );
    }

    return ParsedOrder(
      platform: GigPlatform.fromKey(parsed['platform'] as String? ?? 'other'),
      orderRef: parsed['order_ref'] as String?,
      timestamp: DateTime.tryParse(parsed['timestamp'] as String? ?? '') ??
          DateTime.now(),
      basePay: (parsed['base_pay'] as num?)?.toDouble() ?? 0,
      incentive: (parsed['incentive'] as num?)?.toDouble() ?? 0,
      tip: (parsed['tip'] as num?)?.toDouble() ?? 0,
      distanceKm: (parsed['distance_km'] as num?)?.toDouble(),
      durationMin: (parsed['duration_min'] as num?)?.toInt(),
      zone: parsed['zone'] as String?,
      sourceScreenshotHash: screenshotHash,
    );
  }
}
