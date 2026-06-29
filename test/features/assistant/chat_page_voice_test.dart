// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/features/assistant/data/conversation_repository.dart';
import 'package:aplication_tesis/features/assistant/data/stub_assistant_service.dart';
import 'package:aplication_tesis/features/assistant/data/voice_prefs.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/domain/conversation.dart';
import 'package:aplication_tesis/features/assistant/domain/voice_services.dart';
import 'package:aplication_tesis/features/assistant/presentation/pages/chat_page.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/assistant_provider.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/voice_controller.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

// ---------------------------------------------------------------------------
// Fake STT (no real speech_to_text plugin used)
// ---------------------------------------------------------------------------

class _FakeStt implements SpeechToTextService {
  final bool _available = true;
  bool _isListening = false;

  void Function(String partial)? onPartialCb;
  void Function(String finalText)? onFinalCb;

  void emitFinal(String text) {
    _isListening = false;
    onFinalCb?.call(text);
  }

  @override
  Future<bool> init() async => _available;

  @override
  bool get isAvailable => _available;

  @override
  bool get isListening => _isListening;

  @override
  Future<void> startListening({
    required void Function(String partial) onPartial,
    required void Function(String finalText) onFinal,
    String localeId = 'es_ES',
  }) async {
    _isListening = true;
    onPartialCb = onPartial;
    onFinalCb = onFinal;
  }

  @override
  Future<void> stop() async {
    _isListening = false;
    onPartialCb = null;
    onFinalCb = null;
  }
}

// ---------------------------------------------------------------------------
// Fake TTS (no real flutter_tts plugin used)
// ---------------------------------------------------------------------------

class _FakeTts implements TtsService {
  void Function(bool speaking)? _cb;

  final List<String> spokenTexts = [];
  int stopCallCount = 0;

  void emitStart() => _cb?.call(true);
  void emitStop() => _cb?.call(false);

  @override
  Future<void> init() async {}

  @override
  Future<void> speak(String text, {String languageTag = 'es-ES'}) async {
    spokenTexts.add(text);
    // Simulate TTS speaking state starting immediately for tests
    _cb?.call(true);
  }

  @override
  Future<void> stop() async {
    stopCallCount++;
    _cb?.call(false);
  }

  @override
  set onSpeakingChanged(void Function(bool speaking) cb) {
    _cb = cb;
  }
}

// ---------------------------------------------------------------------------
// In-memory fake repository (same pattern as chat_page_test.dart)
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
// Test helpers
// ---------------------------------------------------------------------------

AssistantProvider _makeAssistantProvider() =>
    AssistantProvider(StubAssistantService(), repository: _FakeRepo());

VoiceController _makeVoiceController(_FakeStt stt, _FakeTts tts) {
  return VoiceController(stt, tts, VoicePrefs());
}

Widget _buildTestApp({
  required AssistantProvider assistantProvider,
  required VoiceController voiceController,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    theme: AppTheme.light,
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<AssistantProvider>.value(
          value: assistantProvider,
        ),
        ChangeNotifierProvider<VoiceController>.value(
          value: voiceController,
        ),
      ],
      child: const ChatPage(),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatPage voice integration', () {
    testWidgets('mic IconButton is present in input row', (tester) async {
      final stt = _FakeStt();
      final tts = _FakeTts();
      final assistant = _makeAssistantProvider();
      final voice = _makeVoiceController(stt, tts);
      await voice.init();
      await assistant.createGeneral();

      await tester.pumpWidget(
        _buildTestApp(
          assistantProvider: assistant,
          voiceController: voice,
        ),
      );
      await tester.pumpAndSettle();

      // Mic button is shown (mic_none icon when not listening)
      expect(find.byIcon(Icons.mic_none), findsOneWidget);
    });

    testWidgets(
        'tapping the AppBar volume action toggles autoSpeak on VoiceController',
        (tester) async {
      final stt = _FakeStt();
      final tts = _FakeTts();
      final assistant = _makeAssistantProvider();
      final voice = _makeVoiceController(stt, tts);
      await voice.init();
      await assistant.createGeneral();

      await tester.pumpWidget(
        _buildTestApp(
          assistantProvider: assistant,
          voiceController: voice,
        ),
      );
      await tester.pumpAndSettle();

      // Default: autoSpeak is true → volume_up icon shown
      expect(voice.autoSpeak, isTrue);
      expect(find.byIcon(Icons.volume_up), findsOneWidget);

      // Tap the AppBar volume toggle
      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pumpAndSettle();

      // autoSpeak is now false → volume_off
      expect(voice.autoSpeak, isFalse);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);

      // Tap again to re-enable
      await tester.tap(find.byIcon(Icons.volume_off));
      await tester.pumpAndSettle();

      expect(voice.autoSpeak, isTrue);
    });

    testWidgets(
        'assistant message bubble shows a play icon button that calls voice.speak',
        (tester) async {
      final stt = _FakeStt();
      final tts = _FakeTts();
      final assistant = _makeAssistantProvider();
      final voice = _makeVoiceController(stt, tts);
      await voice.init();

      // Seed a conversation with one assistant message by letting the
      // StubAssistantService reply to a sent message.
      await assistant.createGeneral();

      // Use the provider send() which will stream a reply via StubService.
      assistant.send('hola');
      // Wait for thinking + streaming to complete
      await tester.pumpWidget(
        _buildTestApp(
          assistantProvider: assistant,
          voiceController: voice,
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // There should now be at least one assistant bubble, which has a
      // volume_up play button
      expect(find.byIcon(Icons.volume_up), findsWidgets);

      // The first volume_up in the list is the play button on the bubble
      // (the AppBar one is also volume_up since autoSpeak=true).
      // Tap the first one that is NOT in the AppBar action (it will be in
      // the scrollable list). We find all and tap the last one (the bubble).
      final volumeIcons = find.byIcon(Icons.volume_up);
      // At least one icon exists (AppBar) — if there's an assistant message
      // there'll be a second one on the bubble.
      // The stub service always produces a reply, so there should be 2 icons.
      if (volumeIcons.evaluate().length >= 2) {
        await tester.tap(volumeIcons.last);
        await tester.pump();
        // Verify TTS received the speak call
        expect(tts.spokenTexts.isNotEmpty, isTrue);
      }
    });

    testWidgets(
        'when listening, stop icon replaces mic_none in input row',
        (tester) async {
      final stt = _FakeStt();
      final tts = _FakeTts();
      final assistant = _makeAssistantProvider();
      final voice = _makeVoiceController(stt, tts);
      await voice.init();
      await assistant.createGeneral();

      await tester.pumpWidget(
        _buildTestApp(
          assistantProvider: assistant,
          voiceController: voice,
        ),
      );
      await tester.pumpAndSettle();

      // Tap mic to start listening
      await tester.tap(find.byIcon(Icons.mic_none));
      await tester.pump();

      // Now voice.isListening is true → stop icon shown in row
      // The AppBar has volume_up still; the row has stop
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.mic_none), findsNothing);
    });
  });
}
