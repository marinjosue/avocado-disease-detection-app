import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../domain/voice_services.dart';
import 'vosk_transcriber.dart';

/// Builds a canonical 44-byte WAV (RIFF/PCM) header followed by [pcm] data.
///
/// [pcm] must already be raw, uncompressed PCM samples (e.g. 16-bit mono
/// @16 kHz, as produced by `record`'s [AudioEncoder.pcm16bits] stream).
/// Exported (top-level) so it can be unit-tested without native plugins.
Uint8List wavFromPcm(
  Uint8List pcm, {
  int sampleRate = 16000,
  int channels = 1,
  int bitsPerSample = 16,
}) {
  final int byteRate = sampleRate * channels * (bitsPerSample ~/ 8);
  final int blockAlign = channels * (bitsPerSample ~/ 8);
  final int dataLength = pcm.length;
  final int riffChunkSize = 36 + dataLength;

  final header = BytesBuilder();
  header.add(_asciiBytes('RIFF'));
  header.add(_uint32le(riffChunkSize));
  header.add(_asciiBytes('WAVE'));

  header.add(_asciiBytes('fmt '));
  header.add(_uint32le(16)); // fmt chunk size (PCM)
  header.add(_uint16le(1)); // audio format = 1 (PCM)
  header.add(_uint16le(channels));
  header.add(_uint32le(sampleRate));
  header.add(_uint32le(byteRate));
  header.add(_uint16le(blockAlign));
  header.add(_uint16le(bitsPerSample));

  header.add(_asciiBytes('data'));
  header.add(_uint32le(dataLength));

  final builder = BytesBuilder();
  builder.add(header.toBytes());
  builder.add(pcm);
  return builder.toBytes();
}

/// Encodes an ASCII string to bytes (used for RIFF chunk tags).
Uint8List _asciiBytes(String s) => Uint8List.fromList(s.codeUnits);

Uint8List _uint32le(int value) {
  final bytes = Uint8List(4);
  final data = ByteData.view(bytes.buffer);
  data.setUint32(0, value, Endian.little);
  return bytes;
}

Uint8List _uint16le(int value) {
  final bytes = Uint8List(2);
  final data = ByteData.view(bytes.buffer);
  data.setUint16(0, value, Endian.little);
  return bytes;
}

/// Concrete [VoiceNoteService] backed by `record`'s PCM streaming API and
/// [VoskTranscriber].
///
/// Captures the microphone ONCE: each PCM chunk is appended to an in-memory
/// buffer (later written as a `.wav` file) AND fed to the Vosk recognizer —
/// a single mic consumer, so recording and transcription never contend for
/// the microphone.
///
/// All operations are best-effort: every public method swallows exceptions
/// and returns a safe fallback so callers never need to guard against
/// failures here.
class RealVoiceNoteService implements VoiceNoteService {
  RealVoiceNoteService({VoskTranscriber? transcriber, AudioRecorder? recorder})
      : _transcriber = transcriber ?? VoskTranscriber(),
        _rec = recorder ?? AudioRecorder();

  final VoskTranscriber _transcriber;
  final AudioRecorder _rec;

  StreamSubscription<Uint8List>? _sub;
  BytesBuilder _pcm = BytesBuilder();

  @override
  bool get isReady => _transcriber.isReady;

  @override
  Future<void> ensureModel({void Function(double progress)? onProgress}) {
    return _transcriber.ensureModel(onProgress: onProgress);
  }

  @override
  Future<bool> start() async {
    try {
      await _transcriber.startUtterance();
      final stream = await _rec.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      _pcm = BytesBuilder();
      _sub = stream.listen((chunk) {
        _pcm.add(chunk);
        _transcriber.acceptPcm(chunk);
      });
      return true;
    } catch (e, st) {
      debugPrint('[VoiceNote] start: FAILED — $e\n$st');
      return false;
    }
  }

  @override
  Future<({String? audioPath, String text})> stop() async {
    try {
      await _sub?.cancel();
      _sub = null;
      await _rec.stop();

      final text = await _transcriber.finishUtterance();

      final pcmBytes = _pcm.toBytes();
      _pcm = BytesBuilder();
      if (pcmBytes.isEmpty) {
        return (audioPath: null, text: text);
      }

      final appDocsDir = await getApplicationDocumentsDirectory();
      final voiceNotesDir = Directory('${appDocsDir.path}/voice_notes');
      await voiceNotesDir.create(recursive: true);
      final path =
          '${voiceNotesDir.path}/${DateTime.now().millisecondsSinceEpoch}.wav';
      final wav = wavFromPcm(pcmBytes);
      await File(path).writeAsBytes(wav);

      return (audioPath: path, text: text);
    } catch (e, st) {
      debugPrint('[VoiceNote] stop: FAILED — $e\n$st');
      return (audioPath: null, text: '');
    }
  }

  @override
  Future<void> cancel() async {
    try {
      await _sub?.cancel();
      _sub = null;
      await _rec.cancel();
    } catch (e) {
      debugPrint('[VoiceNote] cancel: FAILED — $e');
    }
    _pcm = BytesBuilder();
  }
}
