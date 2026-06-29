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
