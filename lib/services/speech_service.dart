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
  ///
  /// [onStatus] and (Android/iOS) [onError] are only actually wired up to
  /// the plugin on the first call — `speech_to_text` ignores them on later
  /// calls once it's already initialized — but that's fine since callers
  /// pass the same closures every time.
  Future<bool> init({
    void Function(String status)? onStatus,
    void Function(String errorMsg)? onError,
  }) async {
    try {
      _available = await _speech.initialize(
        onStatus: onStatus,
        onError: onError == null ? null : (e) => onError(e.errorMsg),
      );
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
