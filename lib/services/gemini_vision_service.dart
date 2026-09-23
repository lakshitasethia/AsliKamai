import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
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

/// Internal only: a failure worth retrying (timeout, network blip, 429/5xx).
/// Never escapes [GeminiVisionService] — callers only ever see
/// [GeminiRequestException] once retries are exhausted.
class _RetryableGeminiException implements Exception {
  _RetryableGeminiException(this.message);
  final String message;
}

/// Where generateContent requests go. Release builds go through the
/// `gemini-proxy` Supabase Edge Function, which holds the Gemini key as a
/// server secret — anything in `.env` is bundled into the APK and readable
/// by anyone who unzips it. A direct GEMINI_API_KEY is a local-dev fallback
/// only.
@visibleForTesting
class GeminiRoute {
  GeminiRoute._(this._uriFor, this.headers);

  final Uri Function(String model) _uriFor;
  final Map<String, String> headers;

  Uri uriFor(String model) => _uriFor(model);

  static GeminiRoute? fromEnv(Map<String, String> env) {
    final supabaseUrl = env['SUPABASE_URL'] ?? '';
    final anonKey = env['SUPABASE_ANON_KEY'] ?? '';
    if (supabaseUrl.isNotEmpty && anonKey.isNotEmpty) {
      return GeminiRoute._(
        (model) => Uri.parse('$supabaseUrl/functions/v1/gemini-proxy')
            .replace(queryParameters: {'model': model}),
        {'Authorization': 'Bearer $anonKey', 'apikey': anonKey},
      );
    }
    final apiKey = env['GEMINI_API_KEY'] ?? '';
    if (apiKey.isNotEmpty && apiKey != 'your_key_here') {
      return GeminiRoute._(
        (model) => Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
        ),
        {'x-goog-api-key': apiKey},
      );
    }
    return null;
  }
}

/// Sends one delivery-partner-app screenshot to Gemini and gets back a
/// structured order record. Screenshot bytes are sent for this single
/// call only and are not persisted anywhere server-side by this app.
class GeminiVisionService {
  // Tried in order; a model that's overloaded (503), rate-limited (429) or
  // too slow (timeout) hands off to the next one immediately. Measured
  // 2026-09-22 on the free tier: gemini-3.6-flash read every test
  // screenshot correctly in 6-11s but still threw the occasional 503;
  // the flash-lite models were just as accurate but took 20-40s. 3.7/3.8
  // flash returned 503 on every call, so they aren't in the chain.
  @visibleForTesting
  static const models = [
    'gemini-3.6-flash',
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
  ];

  // gemini-3.6-flash's free tier is only 20 requests/day; once a model
  // reports its per-day quota as spent, stop paying a wasted round-trip
  // on it for every remaining screenshot this session.
  static final _dailyQuotaSpent = <String>{};

  /// Builds the vision prompt anchored to [today] — without this anchor,
  /// Gemini has no way to resolve a screenshot's date when it's shown
  /// without a year (e.g. "9 Sep", which every partner app does), and can
  /// guess an arbitrary — and arbitrarily wrong — year. Verified directly:
  /// with no anchor, Gemini resolved "9 Sep" to 2024 when the real year was
  /// 2026, silently landing the order two years away from where it belonged.
  @visibleForTesting
  static String buildPrompt(DateTime today) {
    final todayIso =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    return '''
You are reading a single screenshot from an Indian gig-delivery partner app
(Swiggy, Zomato, Blinkit, or Zepto driver/partner app). Extract the ONE order
shown on this screen into JSON matching the given schema.

Today's date is $todayIso.

Rules:
- platform: one of swiggy, zomato, blinkit, zepto, other — infer from logo/branding/text.
- base_pay, incentive, tip: rupee amounts as plain numbers (no currency symbol). If a
  breakdown isn't shown separately, put the whole visible payout in base_pay and 0 for
  the others.
- distance_km and duration_min: null if not visible on screen.
- timestamp: best-guess ISO 8601 date-time for when this order happened, using any date/time
  visible on screen. If the visible date has no year, assume it happened in $todayIso's year —
  but never in the future relative to $todayIso, so use the year before instead if that would
  otherwise put it after today. If no date is visible at all, use today's date with the
  visible time, or null if no time is visible either.
- order_ref: the order/trip ID shown on screen, or null if none is visible.
- zone: the area/locality name shown on screen (e.g. "Koramangala"), or null.
- If this does not look like a delivery-partner-app order screen at all, set
  "not_an_order_screen" to true and leave other fields as best-effort or null.
''';
  }

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

  /// Full passes over [models] before giving up.
  static const _maxRounds = 2;

  // The old 30s cutoff abandoned most flash-lite requests just before
  // they answered (measured 16-60s per screenshot on 2026-09-22), so
  // nearly every import came back as "couldn't read". 45s covers
  // 3.6-flash (6-11s) and the lite fallbacks' typical case; anything
  // slower hands off to the next model in [models].
  static const _requestTimeout = Duration(seconds: 45);

  /// Picks the mime type from the file's magic bytes. Android screenshots
  /// are usually PNG, and image_picker can hand them back untouched, so
  /// hardcoding image/jpeg mislabels most real inputs.
  @visibleForTesting
  static String mimeTypeFor(List<int> bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        bytes[0] == 0x52 && // RIFF....WEBP
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50) {
      return 'image/webp';
    }
    return 'image/jpeg';
  }

  Future<ParsedOrder> parseScreenshot({
    required List<int> imageBytes,
    required String screenshotHash,
  }) async {
    final parsed = await _generateWithFallback(
      prompt: buildPrompt(DateTime.now()),
      imageBytes: imageBytes,
      schema: _responseSchema,
    );

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
      timestamp:
          DateTime.tryParse(parsed['timestamp'] as String? ?? '') ??
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

  /// Prompt for [readDocumentDate], anchored to [today] for the same
  /// missing-year reason as [buildPrompt].
  @visibleForTesting
  static String buildDocumentDatePrompt(DateTime today) {
    final todayIso =
        '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    return '''
You are reading a screenshot of a notice from an Indian gig-delivery partner app
(Swiggy, Zomato, Blinkit, Zepto) — usually an account block/suspension/deactivation
notice. Find the date the notice itself states: the date of the block/suspension if
one is given, otherwise the date the notice was issued or sent.

Today's date is $todayIso.

Rules:
- date: ISO 8601 date (YYYY-MM-DD). If the visible date has no year, assume $todayIso's
  year — but never after $todayIso, so use the year before if needed.
- Ignore the phone's status-bar clock/date; only use dates that are part of the notice.
- If no such date is visible, set date to null.
''';
  }

  static final _documentDateSchema = {
    'type': 'OBJECT',
    'properties': {
      'date': {'type': 'STRING', 'nullable': true},
    },
  };

  /// Reads the date printed on a notice screenshot (e.g. the block date),
  /// or null when none is visible. Throws like [parseScreenshot] on
  /// config/network failures.
  Future<DateTime?> readDocumentDate(List<int> imageBytes) async {
    final parsed = await _generateWithFallback(
      prompt: buildDocumentDatePrompt(DateTime.now()),
      imageBytes: imageBytes,
      schema: _documentDateSchema,
    );
    final date = DateTime.tryParse(parsed['date'] as String? ?? '');
    return date == null ? null : DateTime(date.year, date.month, date.day);
  }

  Future<Map<String, dynamic>> _generateWithFallback({
    required String prompt,
    required List<int> imageBytes,
    required Map<String, Object> schema,
  }) async {
    final route = GeminiRoute.fromEnv(dotenv.env);
    if (route == null) throw GeminiNotConfiguredException();

    var lastError = 'Gemini unavailable.';
    for (var round = 1; round <= _maxRounds; round++) {
      for (final model in models) {
        if (_dailyQuotaSpent.contains(model)) continue;
        try {
          return await _generateOnce(
            route: route,
            model: model,
            prompt: prompt,
            imageBytes: imageBytes,
            schema: schema,
          );
        } on _RetryableGeminiException catch (e) {
          debugPrint('AsliKamai: $model failed, trying next: ${e.message}');
          lastError = e.message;
        }
      }
      if (round < _maxRounds) {
        // Every model was busy — give the demand spike a moment to clear
        // before one more full pass.
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    }
    throw GeminiRequestException(lastError);
  }

  Future<Map<String, dynamic>> _generateOnce({
    required GeminiRoute route,
    required String model,
    required String prompt,
    required List<int> imageBytes,
    required Map<String, Object> schema,
  }) async {
    final base64Image = base64Encode(imageBytes);
    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': mimeTypeFor(imageBytes),
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'responseMimeType': 'application/json',
        'responseSchema': schema,
        // No thinkingConfig here: thinkingBudget returns 400
        // INVALID_ARGUMENT with responseSchema on these models, and
        // thinkingLevel "minimal" was no faster (re-measured 2026-09-22).
      },
    });

    final http.Response response;
    try {
      response = await http
          .post(
            route.uriFor(model),
            headers: {'Content-Type': 'application/json', ...route.headers},
            body: body,
          )
          .timeout(_requestTimeout);
    } catch (e) {
      throw _RetryableGeminiException('Could not reach Gemini: $e');
    }

    if (response.statusCode == 429 && response.body.contains('PerDay')) {
      _dailyQuotaSpent.add(model);
    }
    // 404 = model retired for this key (2.5-flash-lite went this way) —
    // fall through to the next model rather than failing the import.
    if (response.statusCode == 429 ||
        response.statusCode == 404 ||
        response.statusCode >= 500) {
      throw _RetryableGeminiException(
        'Gemini returned ${response.statusCode}: ${response.body}',
      );
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

    // Thinking models can return more than one part; the answer is the
    // non-thought part carrying text.
    final parts =
        (candidates[0]['content']?['parts'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>();
    final text = parts
        .where((p) => p['thought'] != true && p['text'] is String)
        .map((p) => p['text'] as String)
        .firstOrNull;
    if (text == null) {
      throw _RetryableGeminiException('$model returned no text.');
    }
    try {
      return jsonDecode(text) as Map<String, dynamic>;
    } on FormatException {
      throw _RetryableGeminiException('$model returned malformed JSON.');
    }
  }
}
