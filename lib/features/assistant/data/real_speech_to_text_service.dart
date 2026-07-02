import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../domain/voice_services.dart';

/// Production [SpeechToTextService] backed by `package:speech_to_text`.
///
/// Robust finalization: the system recognizer does not always deliver a
/// `finalResult` (e.g. it can stop on silence and only report a status change).
/// To avoid the "Listening… but nothing gets sent" bug, we deliver the last
/// recognized words as the final transcript when the recognizer stops
/// (`notListening`/`done` status) if a final wasn't already emitted. A
/// `_finalized` guard makes sure [onFinal] fires at most once per session.
class RealSpeechToTextService implements SpeechToTextService {
  final SpeechToText _speech = SpeechToText();
  bool _available = false;

  void Function(String finalText)? _onFinal;
  String _lastWords = '';
  bool _finalized = false;

  @override
  Future<bool> init() async {
    _available = await _speech.initialize(
      onError: (e) => debugPrint('[STT] error: ${e.errorMsg} permanent=${e.permanent}'),
      onStatus: (s) {
        debugPrint('[STT] status: $s');
        if (s == 'notListening' || s == 'done') {
          _deliverFinal();
        }
      },
    );
    debugPrint('[STT] initialized: available=$_available');
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
    _onFinal = onFinal;
    _lastWords = '';
    _finalized = false;
    debugPrint('[STT] startListening locale=$localeId');
    await _speech.listen(
      onResult: (result) {
        _lastWords = result.recognizedWords;
        onPartial(result.recognizedWords);
        if (result.finalResult) {
          debugPrint('[STT] finalResult: "${result.recognizedWords}"');
          _deliverFinal();
        }
      },
      listenOptions: SpeechListenOptions(
        partialResults: true,
        localeId: localeId,
        cancelOnError: true,
        pauseFor: const Duration(seconds: 3),
        listenFor: const Duration(seconds: 30),
      ),
    );
  }

  /// Delivers [onFinal] with the last recognized words, at most once.
  void _deliverFinal() {
    if (_finalized) return;
    final cb = _onFinal;
    if (cb == null) return;
    _finalized = true;
    _onFinal = null;
    debugPrint('[STT] deliverFinal: "$_lastWords"');
    cb(_lastWords);
  }

  @override
  Future<void> stop() async {
    await _speech.stop();
    _deliverFinal();
  }
}
