/// Abstract interfaces for Speech-to-Text and Text-to-Speech services.
///
/// Concrete implementations live in `data/`; fakes live in tests.
/// This separation keeps [VoiceController] testable without native plugins.
library;

/// Speech recognition service contract.
abstract class SpeechToTextService {
  /// Initialize the recognition engine and request mic permission.
  /// Returns `true` if the service is available.
  Future<bool> init();

  /// Whether the service initialized successfully.
  bool get isAvailable;

  /// Whether the service is currently listening for speech.
  bool get isListening;

  /// Start a listening session.
  ///
  /// [onPartial] is called with intermediate recognized words.
  /// [onFinal]   is called once with the final recognized text.
  /// [localeId]  BCP-47 locale string, e.g. `'es_ES'` or `'en_US'`.
  Future<void> startListening({
    required void Function(String partial) onPartial,
    required void Function(String finalText) onFinal,
    String localeId = 'es_ES',
  });

  /// Stop the current listening session (produces a final result).
  Future<void> stop();
}

/// Text-to-speech service contract.
abstract class TtsService {
  /// Initialize the TTS engine.
  Future<void> init();

  /// Speak [text] in the given [languageTag] (e.g. `'es-ES'`).
  Future<void> speak(String text, {String languageTag = 'es-ES'});

  /// Stop any ongoing speech.
  Future<void> stop();

  /// Register a callback that is invoked when speech starts (`true`)
  /// or ends / is cancelled / errors (`false`).
  set onSpeakingChanged(void Function(bool speaking) cb);
}

/// Audio recording service contract (used during dictation to capture a
/// voice-note alongside the STT transcript).
///
/// Implementations are best-effort: callers must handle `start()` returning
/// `false` and `stop()` returning `null` gracefully.
abstract class VoiceRecorderService {
  /// Starts recording audio.
  ///
  /// Returns `true` if recording actually started; `false` on permission
  /// denial or any other error.
  Future<bool> start();

  /// Stops recording and returns the path of the saved audio file, or `null`
  /// if the file could not be retrieved.
  Future<String?> stop();

  /// Cancels an in-progress recording without saving.
  Future<void> cancel();
}

/// Offline voice-note service contract.
///
/// Captures the microphone ONCE as a raw PCM stream and fans it out to (a)
/// a playable `.wav` file and (b) an offline transcriber, so recording a
/// voice note and transcribing it never contend for the microphone.
///
/// This is a separate flow from dictation ([SpeechToTextService]): dictation
/// stays STT-only (system recognizer), voice notes stay record+transcribe.
abstract class VoiceNoteService {
  /// Whether the offline transcription model has been downloaded/loaded.
  bool get isReady;

  /// Downloads (if needed) and loads the offline transcription model.
  ///
  /// [onProgress] receives values in `[0.0, 1.0]`.
  Future<void> ensureModel({void Function(double progress)? onProgress});

  /// Starts a single-capture recording: begins streaming PCM audio to both
  /// the WAV buffer and the transcriber.
  ///
  /// Returns `true` if recording actually started; `false` on permission
  /// denial, a not-ready model, or any other error.
  Future<bool> start();

  /// Stops recording, finalizes the transcript, and writes the accumulated
  /// PCM audio to a `.wav` file.
  ///
  /// Returns the saved audio path (or `null` if no audio was captured) and
  /// the transcribed text (empty string if transcription failed).
  Future<({String? audioPath, String text})> stop();

  /// Cancels an in-progress recording without saving audio or finalizing a
  /// transcript.
  Future<void> cancel();
}
