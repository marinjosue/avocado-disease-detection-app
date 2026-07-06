import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sherpa_onnx/sherpa_onnx.dart' as sherpa;

/// Offline speech-to-text transcriber backed by sherpa-onnx (k2-fsa),
/// running a multilingual Whisper "tiny" ONNX model forced to Spanish.
///
/// This is a de-risk sketch evaluated as a candidate replacement for
/// [VoskTranscriber] (see `vosk_transcriber.dart`) because Vosk's bundled
/// `libvosk.so` is not 16 KB page-size aligned (a Google Play requirement),
/// while sherpa-onnx 1.13.3's bundled native libraries are.
///
/// Unlike Vosk's incremental/streaming recognizer, sherpa-onnx's
/// [sherpa.OfflineRecognizer] decodes a whole buffered utterance at once —
/// there is no partial-result callback. The public shape below mirrors
/// [VoskTranscriber] anyway ([isReady], [ensureModel], [startUtterance],
/// [acceptPcm], [finishUtterance], [disposeTranscriber]) so call sites can
/// treat both transcribers interchangeably: audio is buffered internally
/// between [startUtterance] and [finishUtterance], and only decoded once,
/// at the end.
///
/// All public methods are best-effort: failures are logged via [debugPrint]
/// and surfaced through [isReady] / thrown exceptions rather than crashing
/// the caller silently.
class SherpaTranscriber {
  /// Multilingual Whisper "tiny" sherpa-onnx model (official k2-fsa release
  /// asset). ~103 MB total (int8 encoder + int8 decoder + tokens) — offline
  /// after the first download.
  static const String modelArchiveUrl =
      'https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-whisper-tiny.tar.bz2';

  /// Top-level folder name inside the downloaded tar.bz2 archive.
  static const String _modelDirName = 'sherpa-onnx-whisper-tiny';

  // int8-quantized encoder/decoder — smaller and faster than the fp32
  // variants also present in the archive, at a small accuracy cost that is
  // acceptable for short voice-note utterances.
  static const String _encoderFileName = 'tiny-encoder.int8.onnx';
  static const String _decoderFileName = 'tiny-decoder.int8.onnx';
  static const String _tokensFileName = 'tiny-tokens.txt';

  /// Force Whisper to decode as Spanish rather than auto-detecting the
  /// spoken language (more robust for short/noisy utterances).
  static const String _whisperLanguage = 'es';

  static const int _sampleRate = 16000;

  /// [sherpa.initBindings] loads the native `sherpa-onnx-c-api` library; it
  /// only needs to happen once per process.
  static bool _bindingsInitialized = false;

  sherpa.OfflineRecognizer? _recognizer;
  bool _isReady = false;

  /// Accumulates raw PCM16 mono @16 kHz bytes fed via [acceptPcm] until
  /// [finishUtterance] decodes them in one shot.
  final BytesBuilder _pcmBuffer = BytesBuilder(copy: false);

  /// Whether the model has been downloaded/loaded and is ready to decode.
  bool get isReady => _isReady;

  /// Downloads (if needed), extracts, and loads the Whisper tiny model.
  ///
  /// Caches to the app's support directory so a second call is a no-op once
  /// the three model files already exist on disk.
  Future<void> ensureModel({void Function(double progress)? onProgress}) async {
    if (_isReady && _recognizer != null) {
      debugPrint('[Sherpa] ensureModel: already ready, skipping');
      return;
    }
    try {
      debugPrint('[Sherpa] ensureModel: start (url=$modelArchiveUrl)');
      onProgress?.call(0.0);

      if (!_bindingsInitialized) {
        sherpa.initBindings();
        _bindingsInitialized = true;
      }

      final appDir = await getApplicationSupportDirectory();
      final modelDirPath = '${appDir.path}/$_modelDirName';
      final encoderPath = '$modelDirPath/$_encoderFileName';
      final decoderPath = '$modelDirPath/$_decoderFileName';
      final tokensPath = '$modelDirPath/$_tokensFileName';

      final alreadyExtracted =
          await File(encoderPath).exists() &&
          await File(decoderPath).exists() &&
          await File(tokensPath).exists();

      if (!alreadyExtracted) {
        final archiveFile = File('${appDir.path}/sherpa-onnx-whisper-tiny.tar.bz2');
        debugPrint('[Sherpa] ensureModel: downloading archive to ${archiveFile.path}');
        await _downloadFile(
          modelArchiveUrl,
          archiveFile,
          // Downloading is the bulk of the work; reserve the tail of the
          // progress range for extraction + recognizer creation.
          onProgress: (p) => onProgress?.call(p * 0.85),
        );

        debugPrint('[Sherpa] ensureModel: extracting archive into ${appDir.path}');
        onProgress?.call(0.9);
        await extractFileToDisk(archiveFile.path, appDir.path);

        if (await archiveFile.exists()) {
          await archiveFile.delete();
        }
      }
      onProgress?.call(0.95);

      final whisper = sherpa.OfflineWhisperModelConfig(
        encoder: encoderPath,
        decoder: decoderPath,
        language: _whisperLanguage,
        task: 'transcribe',
      );

      final modelConfig = sherpa.OfflineModelConfig(
        whisper: whisper,
        tokens: tokensPath,
        modelType: 'whisper',
        numThreads: 2,
        debug: false,
      );

      final config = sherpa.OfflineRecognizerConfig(model: modelConfig);
      _recognizer = sherpa.OfflineRecognizer(config);
      _isReady = true;

      onProgress?.call(1.0);
      debugPrint('[Sherpa] ensureModel: done, model ready');
    } catch (e, st) {
      _isReady = false;
      debugPrint('[Sherpa] ensureModel: FAILED — $e\n$st');
      rethrow;
    }
  }

  Future<void> _downloadFile(
    String url,
    File destination, {
    void Function(double progress)? onProgress,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) {
        throw HttpException('Unexpected status ${response.statusCode} downloading $url');
      }

      final total = response.contentLength;
      var received = 0;
      final sink = destination.openWrite();
      try {
        await for (final chunk in response) {
          sink.add(chunk);
          received += chunk.length;
          if (total > 0) {
            onProgress?.call(received / total);
          }
        }
        await sink.flush();
      } finally {
        await sink.close();
      }
    } finally {
      client.close(force: true);
    }
  }

  /// Resets the internal PCM buffer for a new utterance.
  ///
  /// Must be called after [ensureModel] has completed successfully.
  Future<void> startUtterance() async {
    if (!_isReady || _recognizer == null) {
      debugPrint('[Sherpa] startUtterance: model not ready, aborting');
      throw StateError('SherpaTranscriber: model is not ready. Call ensureModel() first.');
    }
    _pcmBuffer.clear();
    debugPrint('[Sherpa] startUtterance: PCM buffer reset');
  }

  /// Buffers a chunk of PCM16 mono @16 kHz audio for the active utterance.
  ///
  /// sherpa-onnx's offline recognizer has no incremental/streaming API, so
  /// unlike Vosk this does not feed the model yet — it only accumulates
  /// bytes that [finishUtterance] will convert and decode as a whole.
  Future<void> acceptPcm(Uint8List pcm16) async {
    if (!_isReady) {
      debugPrint('[Sherpa] acceptPcm: model not ready, ignoring chunk');
      return;
    }
    _pcmBuffer.add(pcm16);
  }

  /// Converts the buffered int16 PCM to normalized float32 samples, runs the
  /// offline recognizer once, and returns the final transcript text.
  ///
  /// Returns an empty string if there is no ready recognizer or nothing was
  /// buffered.
  Future<String> finishUtterance() async {
    final recognizer = _recognizer;
    if (recognizer == null) {
      debugPrint('[Sherpa] finishUtterance: no recognizer ready');
      return '';
    }

    final pcmBytes = _pcmBuffer.takeBytes();
    if (pcmBytes.isEmpty) {
      debugPrint('[Sherpa] finishUtterance: no buffered audio');
      return '';
    }

    sherpa.OfflineStream? stream;
    try {
      final samples = _int16BytesToFloat32(pcmBytes);

      stream = recognizer.createStream();
      stream.acceptWaveform(samples: samples, sampleRate: _sampleRate);
      recognizer.decode(stream);

      final result = recognizer.getResult(stream);
      final text = result.text.trim();
      debugPrint('[Sherpa] finishUtterance: text = "$text"');
      return text;
    } catch (e, st) {
      debugPrint('[Sherpa] finishUtterance: FAILED — $e\n$st');
      return '';
    } finally {
      stream?.free();
    }
  }

  /// Interprets [bytes] as little-endian int16 PCM and normalizes to
  /// float32 samples in `[-1, 1]`, as required by
  /// [sherpa.OfflineStream.acceptWaveform].
  Float32List _int16BytesToFloat32(Uint8List bytes) {
    final byteData = ByteData.sublistView(bytes);
    final sampleCount = bytes.lengthInBytes ~/ 2;
    final samples = Float32List(sampleCount);
    for (var i = 0; i < sampleCount; i++) {
      final int16 = byteData.getInt16(i * 2, Endian.little);
      samples[i] = int16 / 32768.0;
    }
    return samples;
  }

  /// Releases native resources held by the recognizer.
  void disposeTranscriber() {
    debugPrint('[Sherpa] disposeTranscriber: releasing resources');
    try {
      _recognizer?.free();
    } catch (e) {
      debugPrint('[Sherpa] disposeTranscriber: recognizer free failed — $e');
    }
    _recognizer = null;
    _pcmBuffer.clear();
    _isReady = false;
  }
}
