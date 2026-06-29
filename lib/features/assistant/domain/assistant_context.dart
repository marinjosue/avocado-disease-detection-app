import 'package:aplication_tesis/core/models/detection_result.dart';

class AssistantContext {
  final String? diseaseType;
  final double? confidence;
  final String? diseaseName;
  final String? recommendation;
  final String? historySummary;
  final String? imagePath;

  const AssistantContext({
    this.diseaseType,
    this.confidence,
    this.diseaseName,
    this.recommendation,
    this.historySummary,
    this.imagePath,
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
      imagePath: r.imagePath,
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

  Map<String, dynamic> toJson() => {
        'diseaseType': diseaseType,
        'confidence': confidence,
        'diseaseName': diseaseName,
        'recommendation': recommendation,
        'historySummary': historySummary,
        'imagePath': imagePath,
      };

  factory AssistantContext.fromJson(Map<String, dynamic> j) {
    return AssistantContext(
      diseaseType: j['diseaseType'] as String?,
      confidence: (j['confidence'] as num?)?.toDouble(),
      diseaseName: j['diseaseName'] as String?,
      recommendation: j['recommendation'] as String?,
      historySummary: j['historySummary'] as String?,
      imagePath: j['imagePath'] as String?,
    );
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
