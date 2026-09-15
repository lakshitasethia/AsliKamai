import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Thin wrapper around the `speech_to_text` plugin (Android's on-device
/// speech recognizer — no API key, no account, per build_execution.md's
/// Phase 4 decision).
class SpeechService {
  final _speech = stt.SpeechToText();
  bool _available = false;

  /// True once initialized and ready to listen — false if the device has no
  /// recognizer, or the user denied the microphone permission when
  /// [initialize] triggered the system prompt.
  Future<bool> init() async {
    try {
      _available = await _speech.initialize();
    } catch (_) {
      _available = false;
    }
    return _available;
  }

  bool get isListening => _speech.isListening;

  Future<void> startListening({
    required void Function(String text, bool isFinal) onResult,
  }) async {
    if (!_available) return;
    await _speech.listen(
      onResult: (result) {
        onResult(result.recognizedWords, result.finalResult);
      },
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 15),
      ),
    );
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }
}
