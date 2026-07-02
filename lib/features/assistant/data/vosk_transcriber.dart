import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:vosk_flutter_2/vosk_flutter_2.dart';

/// Offline speech-to-text transcriber backed by Vosk.
///
/// Loads a small Spanish acoustic model (downloaded once, cached on device)
/// and transcribes raw PCM16 mono @16 kHz audio fed to it in chunks.
///
/// All public methods are best-effort: failures are logged via [debugPrint]
/// and surfaced through [isReady] / thrown exceptions rather than crashing
/// the caller silently.
class VoskTranscriber {
  /// Small Spanish Vosk model — offline after the first download.
  static const String modelUrl =
      'https://alphacephei.com/vosk/models/vosk-model-small-es-0.42.zip';

  static const int _sampleRate = 16000;

  final ModelLoader _modelLoader = ModelLoader();

  Model? _model;
  Recognizer? _recognizer;
  bool _isReady = false;

  /// Whether the model has been downloaded/loaded and is ready to create
  /// recognizers.
  bool get isReady => _isReady;

  /// Downloads (if needed) and loads the small Spanish Vosk model.
  ///
  /// Caches so a second call is a no-op (the underlying [ModelLoader]
  /// already skips re-downloading when the model directory exists).
  Future<void> ensureModel({void Function(double progress)? onProgress}) async {
    if (_isReady && _model != null) {
      debugPrint('[Vosk] ensureModel: already ready, skipping');
      return;
    }
    try {
      debugPrint('[Vosk] ensureModel: start (url=$modelUrl)');
      onProgress?.call(0.0);

      final String modelPath = await _modelLoader.loadFromNetwork(modelUrl);
      debugPrint('[Vosk] ensureModel: model files at $modelPath');
      onProgress?.call(0.8);

      final vosk = VoskFlutterPlugin.instance();
      _model = await vosk.createModel(modelPath);
      _isReady = true;

      onProgress?.call(1.0);
      debugPrint('[Vosk] ensureModel: done, model ready');
    } catch (e, st) {
      _isReady = false;
      debugPrint('[Vosk] ensureModel: FAILED — $e\n$st');
      rethrow;
    }
  }

  /// Creates/resets a recognizer at 16 kHz for a new utterance.
  ///
  /// Must be called after [ensureModel] has completed successfully.
  Future<void> startUtterance() async {
    if (!_isReady || _model == null) {
      debugPrint('[Vosk] startUtterance: model not ready, aborting');
      throw StateError('VoskTranscriber: model is not ready. Call ensureModel() first.');
    }
    try {
      debugPrint('[Vosk] startUtterance: creating recognizer');
      final vosk = VoskFlutterPlugin.instance();
      _recognizer = await vosk.createRecognizer(
        model: _model!,
        sampleRate: _sampleRate,
      );
      debugPrint('[Vosk] startUtterance: recognizer ready');
    } catch (e, st) {
      debugPrint('[Vosk] startUtterance: FAILED — $e\n$st');
      rethrow;
    }
  }

  /// Feeds a chunk of PCM16 mono @16 kHz audio to the active recognizer.
  Future<void> acceptPcm(Uint8List bytes) async {
    final recognizer = _recognizer;
    if (recognizer == null) {
      debugPrint('[Vosk] acceptPcm: no active recognizer, ignoring chunk');
      return;
    }
    try {
      await recognizer.acceptWaveformBytes(bytes);
    } catch (e, st) {
      debugPrint('[Vosk] acceptPcm: FAILED — $e\n$st');
    }
  }

  /// Flushes the recognizer and returns the final transcript text.
  ///
  /// Returns an empty string if there is no active recognizer or the result
  /// carries no `text` field.
  Future<String> finishUtterance() async {
    final recognizer = _recognizer;
    if (recognizer == null) {
      debugPrint('[Vosk] finishUtterance: no active recognizer');
      return '';
    }
    try {
      final String resultJson = await recognizer.getFinalResult();
      debugPrint('[Vosk] finishUtterance: raw result = $resultJson');
      final text = _extractText(resultJson);
      await recognizer.dispose();
      _recognizer = null;
      debugPrint('[Vosk] finishUtterance: text = "$text"');
      return text;
    } catch (e, st) {
      debugPrint('[Vosk] finishUtterance: FAILED — $e\n$st');
      _recognizer = null;
      return '';
    }
  }

  String _extractText(String resultJson) {
    try {
      final decoded = jsonDecode(resultJson);
      if (decoded is Map<String, dynamic> && decoded['text'] is String) {
        return (decoded['text'] as String).trim();
      }
      return '';
    } catch (e) {
      debugPrint('[Vosk] _extractText: failed to parse JSON — $e');
      return '';
    }
  }

  /// Releases native resources held by the recognizer and model.
  void disposeTranscriber() {
    debugPrint('[Vosk] disposeTranscriber: releasing resources');
    try {
      _recognizer?.dispose();
    } catch (e) {
      debugPrint('[Vosk] disposeTranscriber: recognizer dispose failed — $e');
    }
    try {
      _model?.dispose();
    } catch (e) {
      debugPrint('[Vosk] disposeTranscriber: model dispose failed — $e');
    }
    _recognizer = null;
    _model = null;
    _isReady = false;
  }
}
