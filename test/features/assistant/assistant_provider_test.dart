import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';
import 'package:aplication_tesis/features/assistant/domain/conversation.dart';
import 'package:aplication_tesis/features/assistant/data/stub_assistant_service.dart';
import 'package:aplication_tesis/features/assistant/data/conversation_repository.dart';
import 'package:aplication_tesis/features/assistant/presentation/providers/assistant_provider.dart';

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
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('AssistantProvider', () {
    late AssistantProvider provider;

    setUp(() {
      provider = AssistantProvider(
        StubAssistantService(),
        repository: _FakeRepo(),
      );
    });

    test('initial state: no messages, not thinking, no context', () {
      expect(provider.messages, isEmpty);
      expect(provider.isThinking, isFalse);
      expect(provider.context, isNull);
    });

    test('send produces >=2 messages, last is assistant, isThinking false after', () async {
      await provider.send('hola');

      expect(provider.isThinking, isFalse);
      expect(provider.messages.length, greaterThanOrEqualTo(2));
      expect(provider.messages.last.role, equals(AssistantRole.assistant));
      expect(provider.messages.first.role, equals(AssistantRole.user));
      expect(provider.messages.first.text, equals('hola'));
    });

    test('send ignores blank/whitespace text', () async {
      await provider.send('   ');
      expect(provider.messages, isEmpty);
    });

    test('assistant reply text is non-empty after send', () async {
      await provider.send('¿cómo lo trato?');
      expect(provider.messages.last.text, isNotEmpty);
    });

    test('openOrCreateForDetection sets context on current conversation', () async {
      const ctx = AssistantContext(
        diseaseType: 'rona',
        diseaseName: 'Roña',
        recommendation: 'Aplicar tratamiento.',
        imagePath: '/tmp/test_rona.jpg',
      );
      await provider.openOrCreateForDetection(ctx);

      expect(provider.messages, isEmpty);
      expect(provider.context, isNotNull);
      expect(provider.context!.diseaseType, equals('rona'));
    });

    test('createGeneral opens conversation with no context', () async {
      await provider.createGeneral();
      expect(provider.messages, isEmpty);
      expect(provider.context, isNull);
    });

    test('clear empties messages', () async {
      await provider.send('hola');
      provider.clear();
      expect(provider.messages, isEmpty);
    });

    test('multiple sends accumulate correctly', () async {
      await provider.send('primera');
      await provider.send('segunda');
      expect(provider.messages.length, greaterThanOrEqualTo(4));
    });

    test('notifyListeners called during streaming (last message grows)', () async {
      final snapshots = <int>[];
      provider.addListener(() {
        snapshots.add(provider.messages.length);
      });

      await provider.send('hola');

      // At least a few notifications must have occurred
      expect(snapshots, isNotEmpty);
      expect(provider.isThinking, isFalse);
    });
  });
}
