// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter_test/flutter_test.dart';

import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_service.dart';
import 'package:aplication_tesis/features/assistant/domain/conversation.dart';
import 'package:aplication_tesis/features/assistant/data/conversation_repository.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/assistant_provider.dart';

// ---------------------------------------------------------------------------
// Fake AssistantService — yields two tokens then closes.
// ---------------------------------------------------------------------------

class _FakeService implements AssistantService {
  @override
  Stream<String> reply({
    required String prompt,
    AssistantContext? context,
    List<AssistantMessage> history = const [],
  }) async* {
    yield 'Hola ';
    yield 'mundo.';
  }
}

// ---------------------------------------------------------------------------
// In-memory fake ConversationRepository (no SQLite needed in tests)
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

  /// Expose stored messages for assertions.
  List<AssistantMessage> storedMessages(int conversationId) =>
      List.from(_messages[conversationId] ?? []);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late _FakeRepo repo;
  late AssistantProvider provider;

  setUp(() {
    repo = _FakeRepo();
    provider = AssistantProvider(_FakeService(), repository: repo);
  });

  group('AssistantProvider — persistent conversations', () {
    // -------------------------------------------------------------------------
    // createGeneral
    // -------------------------------------------------------------------------

    test('createGeneral adds one conversation to the list', () async {
      expect(provider.conversations, isEmpty);

      await provider.createGeneral();

      expect(provider.conversations, hasLength(1));
      expect(provider.current, isNotNull);
      expect(provider.current!.title, 'Conversación');
    });

    // -------------------------------------------------------------------------
    // send — persists user + assistant messages and auto-titles
    // -------------------------------------------------------------------------

    test('send persists user + assistant messages in repo', () async {
      await provider.createGeneral();
      final id = provider.current!.id!;

      await provider.send('Primera pregunta');

      // The repo should have exactly 2 stored messages: user + assistant.
      final stored = repo.storedMessages(id);
      expect(stored, hasLength(2));
      expect(stored[0].role, AssistantRole.user);
      expect(stored[0].text, 'Primera pregunta');
      expect(stored[1].role, AssistantRole.assistant);
      expect(stored[1].text, isNotEmpty);
    });

    test('send auto-titles a general conversation from the first user message', () async {
      await provider.createGeneral();

      await provider.send('Esto es la primera pregunta del usuario');

      // Title should be the message text (≤40 chars or truncated).
      expect(provider.current!.title, isNot('Conversación'));
      expect(
        provider.current!.title.startsWith('Esto es la primera'),
        isTrue,
      );
    });

    test('send auto-title truncates text longer than 40 chars', () async {
      await provider.createGeneral();
      const longText =
          'Esta es una pregunta muy larga que supera los cuarenta caracteres fácilmente';

      await provider.send(longText);

      expect(provider.current!.title.length, lessThanOrEqualTo(42)); // 40 + '…'
    });

    test('send does NOT override auto-title on second message', () async {
      await provider.createGeneral();
      await provider.send('Primera');
      final titleAfterFirst = provider.current!.title;

      await provider.send('Segunda');

      // Title must remain what was set by the first send.
      expect(provider.current!.title, equals(titleAfterFirst));
    });

    // -------------------------------------------------------------------------
    // openOrCreateForDetection — dedup by detectionKey
    // -------------------------------------------------------------------------

    test('openOrCreateForDetection creates a conversation linked to imagePath', () async {
      const ctx = AssistantContext(
        diseaseType: 'mancha_negra',
        diseaseName: 'Mancha Negra',
        confidence: 0.92,
        imagePath: '/data/images/img1.jpg',
      );

      final conv = await provider.openOrCreateForDetection(ctx);

      expect(conv.id, isNotNull);
      expect(conv.detectionKey, '/data/images/img1.jpg');
      expect(conv.title, contains('Mancha Negra'));
      expect(conv.title, contains('92%'));
      expect(provider.conversations, hasLength(1));
    });

    test('openOrCreateForDetection returns SAME conversation on second call', () async {
      const ctx = AssistantContext(
        diseaseType: 'rona',
        diseaseName: 'Roña',
        confidence: 0.80,
        imagePath: '/data/images/img2.jpg',
      );

      final first = await provider.openOrCreateForDetection(ctx);
      final second = await provider.openOrCreateForDetection(ctx);

      // Only one conversation must exist.
      expect(provider.conversations, hasLength(1));
      expect(first.id, equals(second.id));
    });

    test('openOrCreateForDetection without imagePath always creates new', () async {
      const ctx = AssistantContext(diseaseType: 'healthy');

      await provider.openOrCreateForDetection(ctx);
      await provider.openOrCreateForDetection(ctx);

      // Two conversations because no detectionKey to match on.
      expect(provider.conversations, hasLength(2));
    });

    // -------------------------------------------------------------------------
    // deleteConversation
    // -------------------------------------------------------------------------

    test('deleteConversation removes it from the list', () async {
      await provider.createGeneral();
      final id = provider.current!.id!;

      await provider.deleteConversation(id);

      expect(provider.conversations, isEmpty);
      expect(provider.current, isNull);
    });

    test('deleteConversation of non-current leaves current intact', () async {
      final c1 = await provider.createGeneral();
      await provider.createGeneral(); // becomes current
      final id1 = c1.id!;

      await provider.deleteConversation(id1);

      expect(provider.conversations, hasLength(1));
      expect(provider.current, isNotNull); // still open
    });

    // -------------------------------------------------------------------------
    // deleteAll
    // -------------------------------------------------------------------------

    test('deleteAll clears everything', () async {
      await provider.createGeneral();
      await provider.createGeneral();

      await provider.deleteAll();

      expect(provider.conversations, isEmpty);
      expect(provider.current, isNull);
    });

    // -------------------------------------------------------------------------
    // Backward-compat shims
    // -------------------------------------------------------------------------

    test('messages shim returns empty list when no current conversation', () {
      expect(provider.messages, isEmpty);
    });

    test('messages shim reflects current conversation messages after send', () async {
      await provider.createGeneral();
      await provider.send('Hola');

      expect(provider.messages, hasLength(2));
      expect(provider.messages.first.role, AssistantRole.user);
    });

    test('context shim returns null when no conversation is open', () {
      expect(provider.context, isNull);
    });

    test('context shim returns detection context of current conversation', () async {
      const ctx = AssistantContext(
        diseaseType: 'healthy',
        imagePath: '/img.jpg',
      );
      await provider.openOrCreateForDetection(ctx);

      expect(provider.context, isNotNull);
      expect(provider.context!.diseaseType, 'healthy');
    });

    test('loadConversations populates conversations list', () async {
      await repo.create(
        Conversation(
          title: 'Seeded',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await provider.loadConversations();

      expect(provider.conversations, hasLength(1));
      expect(provider.conversations.first.title, 'Seeded');
    });
  });
}
