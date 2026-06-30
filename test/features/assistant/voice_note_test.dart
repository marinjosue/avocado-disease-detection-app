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
// Minimal fakes — no real plugins
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
// Helpers
// ---------------------------------------------------------------------------

VoiceController _makeVoice() =>
    VoiceController(_FakeStt(), _FakeTts(), VoicePrefs(), _FakeRecorder());

/// A fake repo that can be pre-seeded with extra messages before a getById
/// call — used to simulate conversations that already contain voice messages.
class _SeededRepo extends _FakeRepo {
  final List<AssistantMessage> _extraMessages = [];

  void seedMessage(AssistantMessage m) => _extraMessages.add(m);

  @override
  Future<Conversation?> getById(int id) async {
    final base = await super.getById(id);
    if (base == null) return null;
    final all = [...base.messages, ..._extraMessages];
    return base.copyWith(messages: all);
  }
}

/// Provider wired to a [_SeededRepo]; exposes [seed] + [reloadCurrent].
class _SeededProvider extends AssistantProvider {
  _SeededProvider(this._seededRepo)
      : super(StubAssistantService(), repository: _seededRepo);

  final _SeededRepo _seededRepo;

  void seed(AssistantMessage m) => _seededRepo.seedMessage(m);

  /// Re-opens the current conversation from the repo so seeded messages appear.
  Future<void> reloadCurrent() async {
    if (current?.id == null) return;
    await openConversation(current!.id!);
  }
}

_SeededProvider _makeSeededProvider() =>
    _SeededProvider(_SeededRepo());

Widget _buildTestApp(AssistantProvider provider) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('es'),
    theme: AppTheme.light,
    home: MultiProvider(
      providers: [
        ChangeNotifierProvider<AssistantProvider>.value(value: provider),
        ChangeNotifierProvider<VoiceController>.value(value: _makeVoice()),
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

  group('VoiceNoteBubble in ChatPage', () {
    testWidgets(
        'user message WITH audioPath renders play_arrow button and transcript',
        (tester) async {
      final provider = _makeSeededProvider();
      await provider.createGeneral();

      // Seed a user message with a fake audioPath, then reload so the
      // provider's in-memory conversation reflects it.
      provider.seed(AssistantMessage(
        role: AssistantRole.user,
        text: 'hola',
        timestamp: DateTime.now(),
        audioPath: '/tmp/x.m4a',
      ));
      await provider.reloadCurrent();

      await tester.pumpWidget(_buildTestApp(provider));
      await tester.pumpAndSettle();

      // The play_arrow icon must be present (VoiceNoteBubble player control).
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);

      // The transcript text must appear below the controls.
      expect(find.text('hola'), findsOneWidget);
    });

    testWidgets(
        'user message WITHOUT audioPath renders plain text and NO play button',
        (tester) async {
      final provider = _makeSeededProvider();
      await provider.createGeneral();

      // Seed a plain user message (no audioPath).
      provider.seed(AssistantMessage(
        role: AssistantRole.user,
        text: 'texto plano',
        timestamp: DateTime.now(),
        // audioPath intentionally omitted → null
      ));
      await provider.reloadCurrent();

      await tester.pumpWidget(_buildTestApp(provider));
      await tester.pumpAndSettle();

      // Plain text is shown.
      expect(find.text('texto plano'), findsOneWidget);

      // No play button (Icons.play_arrow) should appear for plain messages.
      expect(find.byIcon(Icons.play_arrow), findsNothing);
    });

    testWidgets('no exception thrown when audioPath file does not exist',
        (tester) async {
      // The AudioPlayer is only activated on tap, not in initState, so pumping
      // must not throw even if the file is missing.
      final provider = _makeSeededProvider();
      await provider.createGeneral();

      provider.seed(AssistantMessage(
        role: AssistantRole.user,
        text: 'sin archivo',
        timestamp: DateTime.now(),
        audioPath: '/nonexistent/path/x.m4a',
      ));
      await provider.reloadCurrent();

      // Should pump without any exception.
      await tester.pumpWidget(_buildTestApp(provider));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });
  });
}
