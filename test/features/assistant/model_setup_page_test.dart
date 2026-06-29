import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplication_tesis/features/assistant/data/assistant_prefs.dart';
import 'package:aplication_tesis/features/assistant/data/gemma_model_service.dart';
import 'package:aplication_tesis/features/assistant/presentation/pages/model_setup_page.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// Always reports the model as NOT installed; never triggers a real download.
class _FakeGemmaModelService extends GemmaModelService {
  @override
  Future<bool> isInstalled() async => false;

  @override
  Future<void> download({
    required String url,
    String? token,
    required void Function(int progress) onProgress,
  }) async {
    // no-op in tests
  }
}

/// Returns empty/default values; backed by mocked SharedPreferences.
class _FakeAssistantPrefs extends AssistantPrefs {
  @override
  Future<String?> getToken() async => null;

  @override
  Future<void> setToken(String token) async {}

  @override
  Future<String> getModelUrl() async => GemmaModelService.defaultModelUrl;

  @override
  Future<void> setModelUrl(String url) async {}
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _wrapPage(Widget page) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    home: page,
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('ModelSetupPage shows download button when model not installed',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      _wrapPage(
        ModelSetupPage(
          service: _FakeGemmaModelService(),
          prefs: _FakeAssistantPrefs(),
        ),
      ),
    );

    // Let initState async work complete
    await tester.pumpAndSettle();

    // The download button must be visible with the l10n label
    expect(find.text('Descargar modelo'), findsOneWidget);
  });

  testWidgets('ModelSetupPage shows modelReady when model is installed',
      (WidgetTester tester) async {
    // Override fake to report installed
    final installedService = _InstalledGemmaModelService();

    await tester.pumpWidget(
      _wrapPage(
        ModelSetupPage(
          service: installedService,
          prefs: _FakeAssistantPrefs(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Modelo listo'), findsOneWidget);
    // Download button should NOT be present when already installed
    expect(find.text('Descargar modelo'), findsNothing);
  });
}

class _InstalledGemmaModelService extends GemmaModelService {
  @override
  Future<bool> isInstalled() async => true;

  @override
  Future<void> download({
    required String url,
    String? token,
    required void Function(int progress) onProgress,
  }) async {}
}
