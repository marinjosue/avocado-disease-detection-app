// test/core/theme/disease_colors_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/disease_colors.dart';

void main() {
  test('forType mapea cada clave de enfermedad y default', () {
    const d = DiseaseColors.light;
    expect(d.forType('healthy'), d.healthy);
    expect(d.forType('mancha_negra'), d.manchaNegra);
    expect(d.forType('rona'), d.rona);
    expect(d.forType('desconocido'), d.unknown);
  });

  test('lerp interpola entre dos extensiones', () {
    final mixed = DiseaseColors.light.lerp(DiseaseColors.dark, 0.5);
    expect(mixed, isA<DiseaseColors>());
  });

  test('diseaseIcon devuelve íconos distintos por clase', () {
    expect(diseaseIcon('healthy'), Icons.check_circle);
    expect(diseaseIcon('mancha_negra'), Icons.coronavirus);
    expect(diseaseIcon('rona'), Icons.warning_amber_rounded);
  });
}
