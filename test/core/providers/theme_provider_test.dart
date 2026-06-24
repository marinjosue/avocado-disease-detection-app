import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplication_tesis/core/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('por defecto es ThemeMode.system', () async {
    SharedPreferences.setMockInitialValues({});
    final p = ThemeProvider();
    expect(p.themeMode, ThemeMode.system);
  });

  test('setThemeMode actualiza y persiste', () async {
    SharedPreferences.setMockInitialValues({});
    final p = ThemeProvider();
    await p.setThemeMode(ThemeMode.dark);
    expect(p.themeMode, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('themeMode'), 'dark');
  });

  test('carga el modo guardado', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'light'});
    final p = ThemeProvider();
    await Future<void>.delayed(Duration.zero);
    expect(p.themeMode, ThemeMode.light);
  });
}
