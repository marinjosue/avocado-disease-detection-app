// test/core/widgets/app_states_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/app_states.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('EmptyState muestra título, mensaje y botón de acción', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(EmptyState(
      icon: Icons.history,
      title: 'Sin análisis',
      message: 'Toma una foto para empezar',
      actionLabel: 'Tomar foto',
      onAction: () => tapped = true,
    )));
    expect(find.text('Sin análisis'), findsOneWidget);
    expect(find.text('Toma una foto para empezar'), findsOneWidget);
    await tester.tap(find.text('Tomar foto'));
    expect(tapped, true);
  });

  testWidgets('LoadingState muestra indicador y mensaje', (tester) async {
    await tester.pumpWidget(_wrap(const LoadingState(message: 'Analizando…')));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Analizando…'), findsOneWidget);
  });
}
