// lib/core/theme/disease_colors.dart
import 'package:flutter/material.dart';
import 'app_tokens.dart';

IconData diseaseIcon(String type) {
  switch (type) {
    case 'healthy':
      return Icons.check_circle;
    case 'mancha_negra':
      return Icons.coronavirus;
    case 'rona':
      return Icons.warning_amber_rounded;
    default:
      return Icons.help_outline;
  }
}

@immutable
class DiseaseColors extends ThemeExtension<DiseaseColors> {
  const DiseaseColors({
    required this.healthy,
    required this.manchaNegra,
    required this.rona,
    required this.unknown,
  });

  final Color healthy;
  final Color manchaNegra;
  final Color rona;
  final Color unknown;

  Color forType(String diseaseType) {
    switch (diseaseType) {
      case 'healthy':
        return healthy;
      case 'mancha_negra':
        return manchaNegra;
      case 'rona':
        return rona;
      default:
        return unknown;
    }
  }

  static const DiseaseColors light = DiseaseColors(
    healthy: LightTokens.healthy,
    manchaNegra: LightTokens.manchaNegra,
    rona: LightTokens.rona,
    unknown: Color(0xFF9E9E9E),
  );

  static const DiseaseColors dark = DiseaseColors(
    healthy: DarkTokens.healthy,
    manchaNegra: DarkTokens.manchaNegra,
    rona: DarkTokens.rona,
    unknown: Color(0xFFAEB4BA),
  );

  @override
  DiseaseColors copyWith({Color? healthy, Color? manchaNegra, Color? rona, Color? unknown}) {
    return DiseaseColors(
      healthy: healthy ?? this.healthy,
      manchaNegra: manchaNegra ?? this.manchaNegra,
      rona: rona ?? this.rona,
      unknown: unknown ?? this.unknown,
    );
  }

  @override
  DiseaseColors lerp(ThemeExtension<DiseaseColors>? other, double t) {
    if (other is! DiseaseColors) return this;
    return DiseaseColors(
      healthy: Color.lerp(healthy, other.healthy, t)!,
      manchaNegra: Color.lerp(manchaNegra, other.manchaNegra, t)!,
      rona: Color.lerp(rona, other.rona, t)!,
      unknown: Color.lerp(unknown, other.unknown, t)!,
    );
  }
}
