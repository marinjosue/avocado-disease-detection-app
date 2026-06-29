import 'package:speech_to_text/speech_to_text.dart';

import '../domain/voice_services.dart';

/// Production [SpeechToTextService] backed by `package:speech_to_text`.
class RealSpeechToTextService implements SpeechToTextService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;

  @override
  Future<bool> init() async {
    _available = await _speech.initialize(
      onError: (e) {},
      onStatus: (s) {},
    );
    return _available;
  }

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _speech.isListening;

  @override
  Future<void> startListening({
    required void Function(String partial) onPartial,
    required void Function(String finalText) onFinal,
    String localeId = 'es_ES',
  }) async {
    await _speech.listen(
      onResult: (result) {
        onPartial(result.recognizedWords);
        if (result.finalResult) {
          onFinal(result.recognizedWords);
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        localeId: localeId,
      ),
    );
  }

  @override
  Future<void> stop() async {
    await _speech.stop();
  }
}
