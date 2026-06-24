// test/core/widgets/stat_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/stat_card.dart';

void main() {
  testWidgets('StatCard muestra label y value', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: StatCard(icon: Icons.analytics, label: 'Análisis totales', value: '128', accentColor: Colors.green),
      ),
    ));
    expect(find.text('Análisis totales'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.byIcon(Icons.analytics), findsOneWidget);
  });
}
