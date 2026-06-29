import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/domain/conversation.dart';
import 'package:aplication_tesis/features/assistant/data/conversation_repository.dart';

// Creates the two conversation tables in an in-memory database.
Future<void> _createSchema(Database db, int version) async {
  await db.execute('''
    CREATE TABLE conversations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT NOT NULL,
      detectionKey TEXT,
      contextJson TEXT,
      createdAt TEXT NOT NULL,
      updatedAt TEXT NOT NULL
    )
  ''');
  await db.execute('''
    CREATE TABLE conversation_messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      conversationId INTEGER NOT NULL,
      role TEXT NOT NULL,
      text TEXT NOT NULL,
      timestamp TEXT NOT NULL,
      FOREIGN KEY (conversationId) REFERENCES conversations (id)
    )
  ''');
}

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  late Database db;
  late ConversationRepository repo;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(version: 2, onCreate: _createSchema),
    );
    repo = ConversationRepository(db: db);
  });

  tearDown(() async {
    await db.close();
  });

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Conversation makeConv({
    String title = 'Test Conv',
    String? detectionKey,
  }) {
    final now = DateTime.utc(2026, 1, 1);
    return Conversation(
      title: title,
      detectionKey: detectionKey,
      createdAt: now,
      updatedAt: now,
    );
  }

  AssistantMessage makeMsg(String text, {AssistantRole role = AssistantRole.user}) {
    return AssistantMessage(
      role: role,
      text: text,
      timestamp: DateTime.utc(2026, 1, 1, 10, 0),
    );
  }

  // -------------------------------------------------------------------------
  // Tests
  // -------------------------------------------------------------------------

  group('ConversationRepository', () {
    test('create → getAll returns the conversation', () async {
      await repo.create(makeConv(title: 'My conv'));

      final all = await repo.getAll();

      expect(all, hasLength(1));
      expect(all.first.title, 'My conv');
      expect(all.first.id, isNotNull);
    });

    test('getAll returns conversations ordered by updatedAt DESC', () async {
      final t1 = DateTime.utc(2026, 1, 1);
      final t2 = DateTime.utc(2026, 1, 2);
      await repo.create(Conversation(title: 'Older', createdAt: t1, updatedAt: t1));
      await repo.create(Conversation(title: 'Newer', createdAt: t2, updatedAt: t2));

      final all = await repo.getAll();

      expect(all.first.title, 'Newer');
      expect(all.last.title, 'Older');
    });

    test('addMessage → getById returns messages in order', () async {
      final conv = await repo.create(makeConv());

      final m1 = AssistantMessage(
        role: AssistantRole.user,
        text: 'first',
        timestamp: DateTime.utc(2026, 1, 1, 9, 0),
      );
      final m2 = AssistantMessage(
        role: AssistantRole.assistant,
        text: 'second',
        timestamp: DateTime.utc(2026, 1, 1, 9, 1),
      );
      await repo.addMessage(conv.id!, m1);
      await repo.addMessage(conv.id!, m2);

      final loaded = await repo.getById(conv.id!);

      expect(loaded, isNotNull);
      expect(loaded!.messages, hasLength(2));
      expect(loaded.messages[0].text, 'first');
      expect(loaded.messages[0].role, AssistantRole.user);
      expect(loaded.messages[1].text, 'second');
      expect(loaded.messages[1].role, AssistantRole.assistant);
    });

    test('getById returns null for unknown id', () async {
      final result = await repo.getById(9999);
      expect(result, isNull);
    });

    test('getByDetectionKey finds conversation by key with messages', () async {
      final conv = await repo.create(
        makeConv(title: 'Disease conv', detectionKey: 'det-42'),
      );
      await repo.addMessage(conv.id!, makeMsg('hello'));

      final found = await repo.getByDetectionKey('det-42');

      expect(found, isNotNull);
      expect(found!.detectionKey, 'det-42');
      expect(found.messages, hasLength(1));
      expect(found.messages.first.text, 'hello');
    });

    test('getByDetectionKey returns null when no match', () async {
      final result = await repo.getByDetectionKey('no-such-key');
      expect(result, isNull);
    });

    test('getAll does not load messages (empty list)', () async {
      final conv = await repo.create(makeConv());
      await repo.addMessage(conv.id!, makeMsg('msg'));

      final all = await repo.getAll();

      expect(all.first.messages, isEmpty);
    });

    test('updateConversation changes title and updatedAt', () async {
      final conv = await repo.create(makeConv(title: 'Old title'));
      final newTime = DateTime.utc(2026, 6, 1);

      await repo.updateConversation(conv.id!, title: 'New title', updatedAt: newTime);

      final updated = await repo.getById(conv.id!);
      expect(updated!.title, 'New title');
      expect(updated.updatedAt, newTime);
    });

    test('delete removes conversation and its messages', () async {
      final conv = await repo.create(makeConv());
      await repo.addMessage(conv.id!, makeMsg('bye'));

      await repo.delete(conv.id!);

      final all = await repo.getAll();
      expect(all, isEmpty);

      // Also verify messages were deleted
      final msgs = await db.query(
        'conversation_messages',
        where: 'conversationId = ?',
        whereArgs: [conv.id],
      );
      expect(msgs, isEmpty);
    });

    test('deleteAll clears all conversations and messages', () async {
      final c1 = await repo.create(makeConv(title: 'A'));
      final c2 = await repo.create(makeConv(title: 'B'));
      await repo.addMessage(c1.id!, makeMsg('m1'));
      await repo.addMessage(c2.id!, makeMsg('m2'));

      await repo.deleteAll();

      expect(await repo.getAll(), isEmpty);
      final msgs = await db.query('conversation_messages');
      expect(msgs, isEmpty);
    });
  });
}
