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

  /// Holds the active dictation's [onFinal] callback until the session ends —
  /// either because the recognizer delivers a final result, or the user taps
  /// stop. Kept so a manual stop can still deliver the partial transcript.
  void Function(String text, String? audioPath)? _onFinalCb;

  /// Starts a dictation session that calls [onFinal] with the recognized text.
  ///
  /// Any ongoing TTS is stopped first.
  ///
  /// NOTE: we deliberately do NOT record audio while the recognizer is active.
  /// On Android the system speech recognizer and an audio recorder contend for
  /// the single microphone; recording starves the recognizer so it never
  /// transcribes (the bug where it said "Listening…" forever and never sent).
  /// Therefore [onFinal]'s `audioPath` is always `null` here — the transcript
  /// (what the assistant needs) is the priority and is never lost. Saving the
  /// dictation as playable audio is left to a separate, non-concurrent flow.
  ///
  /// [localeId] defaults to `'es_ES'`.
  Future<void> startDictation({
    required void Function(String text, String? audioPath) onFinal,
    String localeId = 'es_ES',
  }) async {
    await _tts.stop();
    _onFinalCb = onFinal;
    _partialText = '';
    _isListening = true;
    notifyListeners();
    await _stt.startListening(
      onPartial: (p) {
        _partialText = p;
        notifyListeners();
      },
      onFinal: (t) => _finishDictation(t),
      localeId: localeId,
    );
  }

  /// Finalizes a dictation exactly once: delivers [text] (or the last partial
  /// if [text] is empty) to the stored callback.
  void _finishDictation(String text) {
    final cb = _onFinalCb;
    if (cb == null) return; // already finalized
    _onFinalCb = null;
    final finalText =
        text.trim().isNotEmpty ? text.trim() : _partialText.trim();
    _isListening = false;
    _partialText = '';
    notifyListeners();
    if (finalText.isNotEmpty) cb(finalText, null);
  }

  /// Stops the active dictation session. If the recognizer has not already
  /// delivered a final result, the current partial transcript is sent so the
  /// message is not lost when the user taps stop.
  Future<void> stopDictation() async {
    await _recorder.cancel();
    await _stt.stop();
    final cb = _onFinalCb;
    _onFinalCb = null;
    final pending = _partialText.trim();
    _isListening = false;
    _partialText = '';
    notifyListeners();
    if (cb != null && pending.isNotEmpty) cb(pending, null);
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
