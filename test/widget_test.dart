import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplication_tesis/core/providers/theme_provider.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MaterialApp refleja el ThemeMode del provider', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<ThemeProvider>(
          builder: (_, p, __) => MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: p.themeMode,
            home: const Scaffold(body: Text('AvoScan')),
          ),
        ),
      ),
    );

    expect(find.text('AvoScan'), findsOneWidget);

    await provider.setThemeMode(ThemeMode.dark);
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
