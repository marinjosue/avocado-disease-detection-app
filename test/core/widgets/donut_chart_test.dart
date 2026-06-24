// test/core/widgets/donut_chart_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/donut_chart.dart';

void main() {
  testWidgets('DonutChart renderiza la leyenda', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: DonutChart(
          centerValue: '128',
          centerLabel: 'frutos',
          sections: [
            DonutSection(value: 67, label: 'Sanos', color: Colors.green),
            DonutSection(value: 19, label: 'Mancha Negra', color: Colors.grey),
            DonutSection(value: 14, label: 'Roña', color: Colors.orange),
          ],
        ),
      ),
    ));
    expect(find.text('Sanos'), findsOneWidget);
    expect(find.text('Roña'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
  });
}
