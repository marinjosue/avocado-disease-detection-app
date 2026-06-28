import 'package:aplication_tesis/core/models/detection_result.dart';

class AssistantContext {
  final String? diseaseType;
  final double? confidence;
  final String? diseaseName;
  final String? recommendation;
  final String? historySummary;

  const AssistantContext({
    this.diseaseType,
    this.confidence,
    this.diseaseName,
    this.recommendation,
    this.historySummary,
  });

  factory AssistantContext.fromDetection(
    DetectionResult r, {
    required bool isSpanish,
  }) {
    return AssistantContext(
      diseaseType: r.diseaseType,
      confidence: r.confidence,
      diseaseName: isSpanish ? r.getDiseaseNameES() : r.getDiseaseNameEN(),
      recommendation:
          isSpanish ? r.getRecommendationES() : r.getRecommendationEN(),
    );
  }

  factory AssistantContext.fromHistory({
    required int total,
    required int healthy,
    required int manchaNegra,
    required int rona,
    required bool isSpanish,
  }) {
    final String summary;
    if (isSpanish) {
      summary =
          'Historial: $total detecciones en total — '
          '$healthy sanas, $manchaNegra Mancha Negra, $rona Roña.';
    } else {
      summary =
          'History: $total detections total — '
          '$healthy healthy, $manchaNegra Black Spot, $rona Scab.';
    }
    return AssistantContext(historySummary: summary);
  }

  bool get hasDetection => diseaseType != null;

  String toGroundingText() {
    if (!hasDetection && historySummary == null) return '';

    final buffer = StringBuffer();

    if (hasDetection) {
      final confPct = ((confidence ?? 0.0) * 100).round();
      final name = diseaseName ?? diseaseType!;
      buffer.write(
        'Contexto: la CNN detectó $name con $confPct% de confianza.',
      );
      if (recommendation != null) {
        buffer.write(' Recomendación: $recommendation.');
      }
    }

    if (historySummary != null) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(historySummary);
    }

    return buffer.toString();
  }
}
