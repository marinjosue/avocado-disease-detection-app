import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/domain/conversation.dart';
import 'package:aplication_tesis/features/assistant/data/stub_assistant_service.dart';
import 'package:aplication_tesis/features/assistant/data/conversation_repository.dart';
import 'package:aplication_tesis/features/assistant/data/voice_prefs.dart';
import 'package:aplication_tesis/features/assistant/domain/voice_services.dart';
import 'package:aplication_tesis/features/assistant/presentation/pages/chat_page.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/assistant_provider.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/voice_controller.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Minimal fake STT / TTS — no real plugins used
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

// ---------------------------------------------------------------------------
// In-memory fake repository — avoids real SQLite in widget tests
// ---------------------------------------------------------------------------

class _FakeRepo extends ConversationRepository {
  final List<Conversation> _convs = [];
  final Map<int, List<AssistantMessage>> _messages = {};
  int _nextId = 1;

  _FakeRepo() : super(db: null);

  @override
  Future<Conversation> create(Conversation c) async {
    final id = _nextId++;
    final saved = c.copyWith(id: id);
    _convs.add(saved);
    _messages[id] = [];
    return saved;
  }

  @override
  Future<List<Conversation>> getAll() async =>
      List<Conversation>.from(_convs.reversed);

  @override
  Future<Conversation?> getById(int id) async {
    final idx = _convs.indexWhere((c) => c.id == id);
    if (idx < 0) return null;
    final conv = _convs[idx];
    return conv.copyWith(messages: List.from(_messages[id] ?? []));
  }

  @override
  Future<Conversation?> getByDetectionKey(String key) async {
    final idx = _convs.lastIndexWhere((c) => c.detectionKey == key);
    if (idx < 0) return null;
    final conv = _convs[idx];
    return conv.copyWith(messages: List.from(_messages[conv.id!] ?? []));
  }

  @override
  Future<AssistantMessage> addMessage(
    int conversationId,
    AssistantMessage m,
  ) async {
    _messages.putIfAbsent(conversationId, () => []).add(m);
    return m;
  }

  @override
  Future<void> updateConversation(
    int id, {
    String? title,
    DateTime? updatedAt,
  }) async {
    final idx = _convs.indexWhere((c) => c.id == id);
    if (idx < 0) return;
    _convs[idx] = _convs[idx].copyWith(
      title: title ?? _convs[idx].title,
      updatedAt: updatedAt ?? _convs[idx].updatedAt,
    );
  }

  @override
  Future<void> delete(int id) async {
    _convs.removeWhere((c) => c.id == id);
    _messages.remove(id);
  }

  @override
  Future<void> deleteAll() async {
    _convs.clear();
    _messages.clear();
  }
}

// ---------------------------------------------------------------------------
// Helper: build test app with a pre-seeded provider + fake VoiceController
// ---------------------------------------------------------------------------

VoiceController _makeVoice() =>
    VoiceController(_FakeStt(), _FakeTts(), VoicePrefs(), _FakeRecorder());

Widget _buildTestApp(AssistantProvider provider) {
  final voice = _makeVoice();
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    theme: AppTheme.light,
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<AssistantProvider>.value(value: provider),
        ChangeNotifierProvider<VoiceController>.value(value: voice),
      ],
      child: const ChatPage(),
    ),
  );
}

AssistantProvider _makeProvider() =>
    AssistantProvider(StubAssistantService(), repository: _FakeRepo());

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatPage', () {
    testWidgets('no current conversation shows loading spinner', (tester) async {
      final provider = _makeProvider();
      // Do NOT open any conversation — current == null.
      await tester.pumpWidget(_buildTestApp(provider));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('general conversation: shows disclaimer and input', (tester) async {
      final provider = _makeProvider();
      await provider.createGeneral();

      await tester.pumpWidget(_buildTestApp(provider));
      await tester.pumpAndSettle();

      // Disclaimer text from l10n (es)
      expect(find.textContaining('Orientativo'), findsOneWidget);

      // Input field is present
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('AppBar shows assistant title', (tester) async {
      final provider = _makeProvider();
      await provider.createGeneral();

      await tester.pumpWidget(_buildTestApp(provider));
      await tester.pumpAndSettle();

      expect(find.text('Asistente IA'), findsOneWidget);
    });

    testWidgets('typing and tapping send shows user bubble', (tester) async {
      final provider = _makeProvider();
      await provider.createGeneral();

      await tester.pumpWidget(_buildTestApp(provider));
      await tester.pumpAndSettle();

      const userMessage = 'Hola, prueba de texto';

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, userMessage);
      await tester.pump();

      final sendButton = find.byIcon(Icons.send);
      expect(sendButton, findsOneWidget);
      await tester.tap(sendButton);

      // Wait for streaming reply to complete (stub has 120ms delays × 2 chunks)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text(userMessage), findsOneWidget);
    });

    testWidgets('detection conversation shows disease name, no "Sobre" without detection',
        (tester) async {
      final provider = _makeProvider();
      // Open a general conversation (no detection context).
      await provider.createGeneral();

      await tester.pumpWidget(_buildTestApp(provider));
      await tester.pumpAndSettle();

      // Without a detection context the "Sobre" label should NOT appear.
      expect(find.textContaining('Sobre'), findsNothing);
    });

    testWidgets('detection conversation shows disease name in context card',
        (tester) async {
      final provider = _makeProvider();
      const ctx = AssistantContext(
        diseaseType: 'mancha_negra',
        diseaseName: 'Mancha Negra',
        confidence: 0.92,
        // imagePath is null → errorBuilder fallback, no real file needed
      );
      await provider.openOrCreateForDetection(ctx);

      await tester.pumpWidget(_buildTestApp(provider));
      await tester.pumpAndSettle();

      // Disease name should appear in the context card
      expect(find.textContaining('Mancha Negra'), findsWidgets);
      // "Sobre" label is shown
      expect(find.textContaining('Sobre'), findsOneWidget);
    });

    testWidgets('assistant bubble renders markdown — no raw ** shown',
        (tester) async {
      final provider = _makeProvider();
      await provider.createGeneral();

      await tester.pumpWidget(_buildTestApp(provider));
      await tester.pumpAndSettle();

      // Send a message to trigger a reply from the stub assistant
      const userMessage = 'Pregunta de prueba markdown';
      await tester.enterText(find.byType(TextField), userMessage);
      await tester.pump();
      await tester.tap(find.byIcon(Icons.send));

      // Wait for the stub assistant reply (it has small delays)
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // The assistant reply rendered via GptMarkdown must not show raw **
      expect(find.textContaining('**'), findsNothing);
    });
  });
}
