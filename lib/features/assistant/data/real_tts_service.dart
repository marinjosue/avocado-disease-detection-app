import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../domain/voice_services.dart';

/// Production [TtsService] backed by `package:flutter_tts`.
///
/// Language is applied only when the engine reports it as available — setting
/// an uninstalled language (e.g. `es-ES` on a device without the Spanish voice)
/// can leave the engine silent, so we fall back to the default voice instead of
/// going mute.
class RealTtsService implements TtsService {
  final FlutterTts _tts = FlutterTts();
  void Function(bool)? _cb;

  @override
  set onSpeakingChanged(void Function(bool speaking) cb) => _cb = cb;

  @override
  Future<void> init() async {
    await _tts.setSpeechRate(0.5);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    try {
      await _tts.setLanguage('es-ES');
    } catch (_) {}
    _tts.setStartHandler(() => _cb?.call(true));
    _tts.setCompletionHandler(() => _cb?.call(false));
    _tts.setCancelHandler(() => _cb?.call(false));
    _tts.setErrorHandler((m) {
      debugPrint('[TTS] error: $m');
      _cb?.call(false);
    });
    debugPrint('[TTS] initialized');
  }

  @override
  Future<void> speak(String text, {String languageTag = 'es-ES'}) async {
    if (text.trim().isEmpty) return;
    try {
      final available = await _tts.isLanguageAvailable(languageTag);
      debugPrint('[TTS] speak lang=$languageTag available=$available len=${text.length}');
      if (available == true) {
        await _tts.setLanguage(languageTag);
      }
    } catch (e) {
      debugPrint('[TTS] language check failed: $e — using default voice');
    }
    await _tts.stop(); // avoid overlapping utterances
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}
