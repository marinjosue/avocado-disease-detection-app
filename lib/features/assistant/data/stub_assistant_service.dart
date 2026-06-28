import '../domain/assistant_context.dart';
import '../domain/assistant_message.dart';
import '../domain/assistant_service.dart';

/// Rule-based streaming stub that satisfies [AssistantService] without any
/// network or ML call. Deterministic output — safe to use in tests.
class StubAssistantService implements AssistantService {
  static const _treatmentKeywords = [
    'trat',
    'cómo',
    'como',
    'qué',
    'que',
    'grav',
    'hacer',
    'fungic',
    'cuid',
  ];

  static const _cannedReply =
      'Hola, soy AvoScan AI. Toma una foto de tu aguacate y te ayudaré '
      'a identificar posibles enfermedades.';

  static const _closingSentence =
      'Recuerda monitorear el cultivo regularmente para mejores resultados.';

  @override
  Stream<String> reply({
    required String prompt,
    AssistantContext? context,
    List<AssistantMessage> history = const [],
  }) async* {
    final lower = prompt.toLowerCase();
    final hasTreatmentKeyword = _treatmentKeywords.any(lower.contains);

    if (context?.hasDetection == true && hasTreatmentKeyword) {
      yield* _streamRecommendation(context!.recommendation ?? '');
    } else {
      yield* _streamCanned();
    }
  }

  /// Splits [recommendation] into lines, yields each as a chunk, then appends
  /// a closing sentence. Always produces at least 2 chunks.
  Stream<String> _streamRecommendation(String recommendation) async* {
    final lines = recommendation
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      yield* _streamCanned();
      return;
    }

    for (final line in lines) {
      await Future.delayed(const Duration(milliseconds: 120));
      yield '$line\n';
    }

    await Future.delayed(const Duration(milliseconds: 120));
    yield _closingSentence;
  }

  /// Yields a 2-chunk canned response.
  Stream<String> _streamCanned() async* {
    await Future.delayed(const Duration(milliseconds: 120));
    yield _cannedReply;
    await Future.delayed(const Duration(milliseconds: 120));
    yield ' (Respuesta de marcador de posición — modelo no disponible.)';
  }
}
