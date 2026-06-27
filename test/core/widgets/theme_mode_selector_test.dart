import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/theme_mode_selector.dart';

void main() {
  testWidgets('ThemeModeSelector emite el modo elegido', (tester) async {
    ThemeMode? picked;
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(
      body: ThemeModeSelector(value: ThemeMode.system, onChanged: (m) => picked = m,
        lightLabel: 'Claro', darkLabel: 'Oscuro', systemLabel: 'Automático'),
    )));
    await tester.tap(find.text('Oscuro'));
    expect(picked, ThemeMode.dark);
  });
}
