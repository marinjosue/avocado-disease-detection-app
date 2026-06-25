// test/core/widgets/info_hint_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/info_hint.dart';

void main() {
  testWidgets('InfoHint abre una hoja con la explicación', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: InfoHint(term: 'Confianza', explanation: 'Qué tan seguro está el análisis (0–100%).'),
      ),
    ));
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('Confianza'), findsOneWidget);
    expect(find.text('Qué tan seguro está el análisis (0–100%).'), findsOneWidget);
  });
}
