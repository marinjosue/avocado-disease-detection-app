// test/core/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/theme/disease_colors.dart';
import 'package:aplication_tesis/core/theme/app_tokens.dart';

void main() {
  test('light theme usa Material 3, Inter, primary y extensión', () {
    final t = AppTheme.light;
    expect(t.useMaterial3, true);
    expect(t.brightness, Brightness.light);
    expect(t.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(t.colorScheme.primary, LightTokens.primary);
    expect(t.extension<DiseaseColors>(), DiseaseColors.light);
  });

  test('dark theme es oscuro y trae la extensión oscura', () {
    final t = AppTheme.dark;
    expect(t.brightness, Brightness.dark);
    expect(t.colorScheme.primary, DarkTokens.primary);
    expect(t.extension<DiseaseColors>(), DiseaseColors.dark);
  });
}
