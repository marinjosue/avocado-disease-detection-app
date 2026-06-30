import 'package:flutter/foundation.dart';

import '../../domain/voice_services.dart';
import '../../data/voice_prefs.dart';

/// Composes [SpeechToTextService], [TtsService], [VoicePrefs], and
/// [VoiceRecorderService] into a single [ChangeNotifier] that the UI listens
/// to for all voice-related state.
class VoiceController extends ChangeNotifier {
  final SpeechToTextService _stt;
  final TtsService _tts;
  final VoicePrefs _prefs;
  final VoiceRecorderService _recorder;

  VoiceController(this._stt, this._tts, this._prefs, this._recorder);

  bool _isListening = false;
  bool _isSpeaking = false;
  bool _autoSpeak = true;
  String _partialText = '';

  /// Whether the underlying STT engine is available (initialized).
  bool get isAvailable => _stt.isAvailable;

  /// Whether the controller is currently listening for speech.
  bool get isListening => _isListening;

  /// Whether the TTS engine is currently speaking.
  bool get isSpeaking => _isSpeaking;

  /// Whether the assistant should automatically speak responses.
  bool get autoSpeak => _autoSpeak;

  /// In-progress partial transcription during an active dictation session.
  String get partialText => _partialText;

  /// Initializes STT + TTS, loads persisted prefs.
  ///
  /// Call once after construction (e.g. via `..init()` in the Provider create).
  Future<void> init() async {
    _autoSpeak = await _prefs.getAutoSpeak();
    await _stt.init();
    await _tts.init();
    _tts.onSpeakingChanged = (s) {
      _isSpeaking = s;
      notifyListeners();
    };
    notifyListeners();
  }

  /// Toggles [autoSpeak] and persists the new value.
  ///
  /// If auto-speak is turned off while the TTS is speaking, the speech is
  /// stopped immediately.
  Future<void> toggleAutoSpeak() async {
    _autoSpeak = !_autoSpeak;
    await _prefs.setAutoSpeak(_autoSpeak);
    if (!_autoSpeak) await stopSpeaking();
    notifyListeners();
  }

  /// Starts a dictation session that calls [onFinal] with the recognized text
  /// and the path of the recorded audio file (or `null` if recording failed).
  ///
  /// Any ongoing TTS is stopped first. Audio recording is best-effort: if the
  /// recorder cannot start (e.g. no permission), [onFinal] still fires with
  /// `audioPath == null` and the transcript is not lost.
  ///
  /// [localeId] defaults to `'es_ES'`.
  Future<void> startDictation({
    required void Function(String text, String? audioPath) onFinal,
    String localeId = 'es_ES',
  }) async {
    await _tts.stop();
    final recording = await _recorder.start();
    _isListening = true;
    notifyListeners();
    await _stt.startListening(
      onPartial: (p) {
        _partialText = p;
        notifyListeners();
      },
      onFinal: (t) async {
        final path = recording ? await _recorder.stop() : null;
        _isListening = false;
        _partialText = '';
        notifyListeners();
        onFinal(t, path);
      },
      localeId: localeId,
    );
  }

  /// Stops the active dictation session (cancels any in-progress recording).
  Future<void> stopDictation() async {
    await _recorder.cancel();
    await _stt.stop();
    _isListening = false;
    _partialText = '';
    notifyListeners();
  }

  /// Speaks [text] via the TTS engine in [languageTag] (defaults to `'es-ES'`).
  Future<void> speak(String text, {String languageTag = 'es-ES'}) async {
    await _tts.speak(text, languageTag: languageTag);
  }

  /// Stops any ongoing TTS speech.
  Future<void> stopSpeaking() async {
    await _tts.stop();
  }
}
