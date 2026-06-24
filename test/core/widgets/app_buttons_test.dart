import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/app_buttons.dart';

Widget _wrap(Widget c) => MaterialApp(theme: AppTheme.light, home: Scaffold(body: c));

void main() {
  testWidgets('PrimaryButton dispara onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(PrimaryButton(label: 'Guardar', onPressed: () => tapped = true)));
    await tester.tap(find.text('Guardar'));
    expect(tapped, true);
  });

  testWidgets('PrimaryButton en isLoading muestra spinner y se deshabilita', (tester) async {
    await tester.pumpWidget(_wrap(const PrimaryButton(label: 'Guardar', isLoading: true)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
