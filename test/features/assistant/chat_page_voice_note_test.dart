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
// Fakes — mirrors the pattern used in voice_controller_test.dart /
// chat_page_test.dart. No real plugins are used.
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

/// Fake voice-note service: model is already downloaded (ready), starting a
/// recording always succeeds, and stopping always returns a fixed
/// (audioPath, text) pair — mirroring `_FakeNote` in voice_controller_test.dart.
class _FakeNote implements VoiceNoteService {
  int ensureModelCallCount = 0;
  int startCallCount = 0;
  int stopCallCount = 0;

  @override
  bool get isReady => true;

  @override
  Future<void> ensureModel({void Function(double progress)? onProgress}) async {
    ensureModelCallCount++;
  }

  @override
  Future<bool> start() async {
    startCallCount++;
    return true;
  }

  @override
  Future<({String? audioPath, String text})> stop() async {
    stopCallCount++;
    return (audioPath: '/n.wav', text: 'hola');
  }

  @override
  Future<void> cancel() async {}
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

VoiceController _makeVoiceController(VoiceNoteService note) {
  return VoiceController(
    _FakeStt(),
    _FakeTts(),
    VoicePrefs(),
    _FakeRecorder(),
    note,
  );
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

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('ChatPage voice-note recording', () {
    testWidgets('the voice-note record button is shown in the input row',
        (tester) async {
      final note = _FakeNote();
      final assistant = _makeAssistantProvider();
      final voice = _makeVoiceController(note);
      await voice.init();
      await assistant.createGeneral();

      await tester.pumpWidget(
        _buildTestApp(assistantProvider: assistant, voiceController: voice),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.graphic_eq), findsOneWidget);
      // Dictation mic and send button are still present, unchanged.
      expect(find.byIcon(Icons.mic_none), findsOneWidget);
      expect(find.byIcon(Icons.send), findsOneWidget);
    });

    testWidgets(
        'tapping record then stop sends the transcript + audioPath and '
        'shows the recording indicator while active', (tester) async {
      final note = _FakeNote();
      final assistant = _makeAssistantProvider();
      final voice = _makeVoiceController(note);
      await voice.init();
      await assistant.createGeneral();

      await tester.pumpWidget(
        _buildTestApp(assistantProvider: assistant, voiceController: voice),
      );
      await tester.pumpAndSettle();

      // Tap the voice-note button — model is already ready, so no download
      // dialog appears and recording starts immediately.
      await tester.tap(find.byIcon(Icons.graphic_eq));
      await tester.pump();

      expect(note.startCallCount, 1);
      expect(voice.isRecordingNote, isTrue);

      // Recording indicator is shown: "Grabando…" label + a stop button.
      expect(find.text('Grabando…'), findsOneWidget);
      expect(find.byIcon(Icons.stop_circle), findsOneWidget);
      // The text field / send button are hidden while recording.
      expect(find.byIcon(Icons.send), findsNothing);

      // Tap stop.
      await tester.tap(find.byIcon(Icons.stop_circle));
      await tester.pump();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(note.stopCallCount, 1);
      expect(voice.isRecordingNote, isFalse);

      // The AssistantProvider.send() call persisted a user message carrying
      // both the transcript and the audio path.
      final userMsgs = assistant.messages
          .where((m) => m.role == AssistantRole.user)
          .toList();
      expect(userMsgs, hasLength(1));
      expect(userMsgs.first.text, 'hola');
      expect(userMsgs.first.audioPath, '/n.wav');
    });

    testWidgets(
        'when the voice model is not ready, tapping record downloads it '
        'first via ensureVoiceModel then starts recording', (tester) async {
      final note = _NotReadyThenReadyNote();
      final assistant = _makeAssistantProvider();
      final voice = _makeVoiceController(note);
      await voice.init();
      await assistant.createGeneral();

      await tester.pumpWidget(
        _buildTestApp(assistantProvider: assistant, voiceController: voice),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.graphic_eq));
      await tester.pump();

      expect(note.ensureModelCallCount, 1);
      expect(note.startCallCount, 1);
    });
  });
}

/// Fake note service whose model is NOT ready until [ensureModel] is called.
class _NotReadyThenReadyNote implements VoiceNoteService {
  bool _ready = false;
  int ensureModelCallCount = 0;
  int startCallCount = 0;

  @override
  bool get isReady => _ready;

  @override
  Future<void> ensureModel({void Function(double progress)? onProgress}) async {
    ensureModelCallCount++;
    _ready = true;
  }

  @override
  Future<bool> start() async {
    startCallCount++;
    return true;
  }

  @override
  Future<({String? audioPath, String text})> stop() async =>
      (audioPath: null, text: '');

  @override
  Future<void> cancel() async {}
}
