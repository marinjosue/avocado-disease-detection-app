import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/data/stub_assistant_service.dart';

void main() {
  group('StubAssistantService', () {
    late StubAssistantService service;

    setUp(() {
      service = StubAssistantService();
    });

    test('streams recommendation content when detection context and treatment prompt', () async {
      const knownRecommendation = 'Aplicar fungicidas cúpricos y eliminar ramas infectadas.';
      final context = AssistantContext(
        diseaseType: 'mancha_negra',
        confidence: 0.90,
        diseaseName: 'Mancha Negra',
        recommendation: knownRecommendation,
      );

      final result = await service
          .reply(prompt: '¿cómo lo trato?', context: context)
          .join();

      expect(result, contains('Aplicar'));
    });

    test('streams canned reply when no detection context', () async {
      final result = await service
          .reply(prompt: 'hola')
          .join();

      expect(result, isNotEmpty);
    });

    test('streams canned reply when context has no detection', () async {
      const ctx = AssistantContext();
      final result = await service
          .reply(prompt: '¿cómo lo trato?', context: ctx)
          .join();

      expect(result, isNotEmpty);
    });

    test('streams multiple chunks (delay between each)', () async {
      const knownRecommendation =
          'Línea uno de recomendación.\nLínea dos de recomendación.\nLínea tres.';
      final context = AssistantContext(
        diseaseType: 'rona',
        confidence: 0.80,
        diseaseName: 'Roña',
        recommendation: knownRecommendation,
      );

      final chunks = await service
          .reply(prompt: 'qué hago', context: context)
          .toList();

      expect(chunks.length, greaterThanOrEqualTo(2));
    });

    test('reply uses history parameter without error', () async {
      final history = [
        AssistantMessage(
          role: AssistantRole.user,
          text: 'primera pregunta',
          timestamp: DateTime(2026),
        ),
        AssistantMessage(
          role: AssistantRole.assistant,
          text: 'primera respuesta',
          timestamp: DateTime(2026),
        ),
      ];

      final result = await service
          .reply(prompt: 'segunda pregunta', history: history)
          .join();

      expect(result, isNotEmpty);
    });
  });
}
