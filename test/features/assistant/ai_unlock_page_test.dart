import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/features/assistant/data/voice_prefs.dart';
import 'package:aplication_tesis/features/assistant/domain/voice_services.dart';
import 'package:aplication_tesis/features/assistant/presentation/pages/ai_unlock_page.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/voice_controller.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Minimal fakes so no real plugin is touched (VoiceController dependency).
// ---------------------------------------------------------------------------

class _FakeStt implements SpeechToTextService {
  @override
  Future<bool> init() async => true;
  @override
  bool get isAvailable => true;
  @override
  bool get isListening => false;
  @override
  Future<void> startListening({
    required void Function(String partial) onPartial,
    required void Function(String finalText) onFinal,
    String localeId = 'es_ES',
  }) async {}
  @override
  Future<void> stop() async {}
}

class _FakeTts implements TtsService {
  @override
  Future<void> init() async {}
  @override
  Future<void> speak(String text, {String languageTag = 'es-ES'}) async {}
  @override
  Future<void> stop() async {}
  @override
  set onSpeakingChanged(void Function(bool speaking) cb) {}
}

class _FakeRecorder implements VoiceRecorderService {
  @override
  Future<bool> start() async => false;
  @override
  Future<String?> stop() async => null;
  @override
  Future<void> cancel() async {}
}

class _FakeNote implements VoiceNoteService {
  @override
  bool get isReady => true;
  @override
  Future<void> ensureModel({void Function(double progress)? onProgress}) async {}
  @override
  Future<bool> start() async => false;
  @override
  Future<({String? audioPath, String text})> stop() async =>
      (audioPath: null, text: '');
  @override
  Future<void> cancel() async {}
}

Widget _buildTestApp() {
  final voice = VoiceController(
    _FakeStt(),
    _FakeTts(),
    VoicePrefs(),
    _FakeRecorder(),
    _FakeNote(),
  );
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    theme: AppTheme.light,
    home: ChangeNotifierProvider<VoiceController>.value(
      value: voice,
      child: const AiUnlockPage(),
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AiUnlockPage', () {
    testWidgets('shows the code field and the unlock button', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Desbloquear'), findsOneWidget);
      expect(find.text('Acceso exclusivo'), findsWidgets);
    });

    testWidgets('wrong code shows the error and stays locked', (tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '9999');
      await tester.tap(find.text('Desbloquear'));
      await tester.pumpAndSettle();

      expect(find.text('Código incorrecto'), findsOneWidget);
      // Still on the locked stage (input remains visible).
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
