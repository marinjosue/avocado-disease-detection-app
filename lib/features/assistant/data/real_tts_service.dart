import 'package:flutter_tts/flutter_tts.dart';

import '../domain/voice_services.dart';

/// Production [TtsService] backed by `package:flutter_tts`.
class RealTtsService implements TtsService {
  final FlutterTts _tts = FlutterTts();
  void Function(bool)? _cb;

  @override
  set onSpeakingChanged(void Function(bool speaking) cb) => _cb = cb;

  @override
  Future<void> init() async {
    await _tts.setLanguage('es-ES');
    await _tts.setSpeechRate(0.5);
    _tts.setStartHandler(() => _cb?.call(true));
    _tts.setCompletionHandler(() => _cb?.call(false));
    _tts.setCancelHandler(() => _cb?.call(false));
    _tts.setErrorHandler((m) => _cb?.call(false));
  }

  @override
  Future<void> speak(String text, {String languageTag = 'es-ES'}) async {
    await _tts.setLanguage(languageTag);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
