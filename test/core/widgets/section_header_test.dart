import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/section_header.dart';
import 'package:aplication_tesis/core/widgets/status_badge.dart';

Widget _wrap(Widget c) => MaterialApp(theme: AppTheme.light, home: Scaffold(body: c));

void main() {
  testWidgets('SectionHeader muestra el título', (tester) async {
    await tester.pumpWidget(_wrap(const SectionHeader(title: 'Distribución')));
    expect(find.text('DISTRIBUCIÓN'), findsOneWidget);
  });

  testWidgets('StatusBadge muestra la etiqueta', (tester) async {
    await tester.pumpWidget(_wrap(const StatusBadge(diseaseType: 'rona', label: 'Roña')));
    expect(find.text('Roña'), findsOneWidget);
  });
}
