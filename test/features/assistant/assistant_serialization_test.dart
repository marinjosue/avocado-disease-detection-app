import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';
import 'package:aplication_tesis/core/models/detection_result.dart';

void main() {
  group('AssistantMessage serialization', () {
    test('round-trip toJson → fromJson preserves role, text, timestamp', () {
      final original = AssistantMessage(
        role: AssistantRole.assistant,
        text: 'Hola, soy AvoScan AI.',
        timestamp: DateTime.utc(2026, 1, 15, 10, 30, 0),
      );

      final json = original.toJson();
      final restored = AssistantMessage.fromJson(json);

      expect(restored.role, original.role);
      expect(restored.text, original.text);
      expect(restored.timestamp, original.timestamp);
    });

    test('toJson encodes role as name string', () {
      final msg = AssistantMessage(
        role: AssistantRole.user,
        text: 'test',
        timestamp: DateTime.utc(2026, 1, 1),
      );
      expect(msg.toJson()['role'], 'user');
    });

    test('round-trip preserves audioPath when set', () {
      final original = AssistantMessage(
        role: AssistantRole.user,
        text: 'nota de voz',
        timestamp: DateTime.utc(2026, 6, 29, 12, 0, 0),
        audioPath: '/a/b.m4a',
      );

      final json = original.toJson();
      final restored = AssistantMessage.fromJson(json);

      expect(restored.audioPath, '/a/b.m4a');
    });

    test('round-trip keeps audioPath null when not set', () {
      final original = AssistantMessage(
        role: AssistantRole.user,
        text: 'texto plano',
        timestamp: DateTime.utc(2026, 6, 29),
      );

      final json = original.toJson();
      final restored = AssistantMessage.fromJson(json);

      expect(restored.audioPath, isNull);
    });
  });

  group('AssistantContext serialization', () {
    late DetectionResult detection;
    late AssistantContext ctx;

    setUp(() {
      detection = DetectionResult(
        diseaseType: 'rona',
        confidence: 0.87,
        imagePath: '/x.jpg',
        timestamp: DateTime(2026),
      );
      ctx = AssistantContext.fromDetection(detection, isSpanish: true);
    });

    test('fromDetection sets imagePath from DetectionResult', () {
      expect(ctx.imagePath, '/x.jpg');
    });

    test('round-trip toJson → fromJson preserves diseaseType, confidence, imagePath', () {
      final json = ctx.toJson();
      final restored = AssistantContext.fromJson(json);

      expect(restored.diseaseType, 'rona');
      expect(restored.confidence, closeTo(0.87, 0.0001));
      expect(restored.imagePath, '/x.jpg');
    });

    test('round-trip preserves hasDetection', () {
      final json = ctx.toJson();
      final restored = AssistantContext.fromJson(json);
      expect(restored.hasDetection, isTrue);
    });

    test('round-trip preserves diseaseName and recommendation', () {
      final json = ctx.toJson();
      final restored = AssistantContext.fromJson(json);
      expect(restored.diseaseName, isNotNull);
      expect(restored.recommendation, isNotNull);
    });

    test('fromJson handles null imagePath', () {
      final json = <String, dynamic>{
        'diseaseType': 'healthy',
        'confidence': 0.99,
        'diseaseName': 'Sano',
        'recommendation': 'Fruto sano.',
        'historySummary': null,
        'imagePath': null,
      };
      final restored = AssistantContext.fromJson(json);
      expect(restored.imagePath, isNull);
      expect(restored.hasDetection, isTrue);
    });
  });
}
