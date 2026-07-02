import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:aplication_tesis/features/assistant/data/real_voice_note_service.dart';

void main() {
  group('wavFromPcm', () {
    test('total length is 44-byte header + pcm data length', () {
      final pcm = Uint8List.fromList([1, 2, 3, 4]);
      final wav = wavFromPcm(pcm);
      expect(wav.length, 44 + 4);
    });

    test('bytes 0..3 are "RIFF"', () {
      final wav = wavFromPcm(Uint8List.fromList([1, 2, 3, 4]));
      expect(String.fromCharCodes(wav.sublist(0, 4)), 'RIFF');
    });

    test('bytes 8..11 are "WAVE"', () {
      final wav = wavFromPcm(Uint8List.fromList([1, 2, 3, 4]));
      expect(String.fromCharCodes(wav.sublist(8, 12)), 'WAVE');
    });

    test('bytes 12..15 are "fmt "', () {
      final wav = wavFromPcm(Uint8List.fromList([1, 2, 3, 4]));
      expect(String.fromCharCodes(wav.sublist(12, 16)), 'fmt ');
    });

    test('sample rate field (offset 24, uint32 LE) is 16000', () {
      final wav = wavFromPcm(Uint8List.fromList([1, 2, 3, 4]));
      final data = ByteData.sublistView(wav);
      expect(data.getUint32(24, Endian.little), 16000);
    });

    test('bits per sample field (offset 34, uint16 LE) is 16', () {
      final wav = wavFromPcm(Uint8List.fromList([1, 2, 3, 4]));
      final data = ByteData.sublistView(wav);
      expect(data.getUint16(34, Endian.little), 16);
    });

    test('"data" tag at offset 36', () {
      final wav = wavFromPcm(Uint8List.fromList([1, 2, 3, 4]));
      expect(String.fromCharCodes(wav.sublist(36, 40)), 'data');
    });

    test('data length field (offset 40, uint32 LE) equals pcm length', () {
      final wav = wavFromPcm(Uint8List.fromList([1, 2, 3, 4]));
      final data = ByteData.sublistView(wav);
      expect(data.getUint32(40, Endian.little), 4);
    });

    test('preserves the raw pcm bytes after the header', () {
      final pcm = Uint8List.fromList([9, 8, 7, 6]);
      final wav = wavFromPcm(pcm);
      expect(wav.sublist(44), pcm);
    });

    test('honors custom sampleRate/channels/bitsPerSample', () {
      final wav = wavFromPcm(
        Uint8List.fromList([1, 2]),
        sampleRate: 8000,
        channels: 2,
        bitsPerSample: 8,
      );
      final data = ByteData.sublistView(wav);
      expect(data.getUint32(24, Endian.little), 8000);
      expect(data.getUint16(22, Endian.little), 2); // num channels
      expect(data.getUint16(34, Endian.little), 8);
    });
  });
}
