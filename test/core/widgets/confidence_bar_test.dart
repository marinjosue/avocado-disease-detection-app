import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/confidence_bar.dart';

void main() {
  testWidgets('ConfidenceBar muestra el porcentaje redondeado', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: ConfidenceBar(value: 0.87)),
    ));
    expect(find.text('87%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
