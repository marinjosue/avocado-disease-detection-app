import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/models/detection_result.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';

void main() {
  group('AssistantContext.fromDetection', () {
    test('hasDetection is true and toGroundingText contains disease name and confidence', () {
      final result = DetectionResult(
        diseaseType: 'rona',
        confidence: 0.87,
        imagePath: 'x',
        timestamp: DateTime(2026),
      );

      final ctx = AssistantContext.fromDetection(result, isSpanish: true);

      expect(ctx.hasDetection, isTrue);

      final grounding = ctx.toGroundingText();
      expect(grounding, contains('Roña'));
      expect(grounding, contains('87'));
    });

    test('fromDetection fills confidence and recommendation', () {
      final result = DetectionResult(
        diseaseType: 'mancha_negra',
        confidence: 0.95,
        imagePath: 'img.jpg',
        timestamp: DateTime(2026),
      );

      final ctx = AssistantContext.fromDetection(result, isSpanish: true);

      expect(ctx.diseaseType, equals('mancha_negra'));
      expect(ctx.confidence, equals(0.95));
      expect(ctx.recommendation, isNotNull);
      expect(ctx.toGroundingText(), contains('Mancha Negra'));
      expect(ctx.toGroundingText(), contains('95'));
    });

    test('fromDetection EN locale uses English names', () {
      final result = DetectionResult(
        diseaseType: 'rona',
        confidence: 0.72,
        imagePath: 'img.jpg',
        timestamp: DateTime(2026),
      );

      final ctx = AssistantContext.fromDetection(result, isSpanish: false);

      expect(ctx.toGroundingText(), contains('Scab'));
      expect(ctx.toGroundingText(), contains('72'));
    });
  });

  group('AssistantContext.fromHistory', () {
    test('builds a historySummary and hasDetection is false', () {
      final ctx = AssistantContext.fromHistory(
        total: 10,
        healthy: 5,
        manchaNegra: 3,
        rona: 2,
        isSpanish: true,
      );

      expect(ctx.hasDetection, isFalse);
      expect(ctx.historySummary, isNotNull);
      final grounding = ctx.toGroundingText();
      expect(grounding, isNotEmpty);
    });
  });

  group('AssistantContext default', () {
    test('empty context has hasDetection false and empty grounding', () {
      const ctx = AssistantContext();
      expect(ctx.hasDetection, isFalse);
      expect(ctx.toGroundingText(), isEmpty);
    });
  });
}
