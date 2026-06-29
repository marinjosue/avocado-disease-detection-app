import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'package:aplication_tesis/core/database/database_helper.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_context.dart';
import 'package:aplication_tesis/features/assistant/domain/assistant_message.dart';
import 'package:aplication_tesis/features/assistant/domain/conversation.dart';

class ConversationRepository {
  final Database? _injected;

  ConversationRepository({Database? db}) : _injected = db;

  Future<Database> get _db async =>
      _injected ?? await DatabaseHelper.instance.database;

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  Future<Conversation> create(Conversation c) async {
    final db = await _db;
    final id = await db.insert('conversations', {
      'title': c.title,
      'detectionKey': c.detectionKey,
      'contextJson':
          c.context == null ? null : jsonEncode(c.context!.toJson()),
      'createdAt': c.createdAt.toIso8601String(),
      'updatedAt': c.updatedAt.toIso8601String(),
    });
    return c.copyWith(id: id);
  }

  // ---------------------------------------------------------------------------
  // Read (list — no messages)
  // ---------------------------------------------------------------------------

  Future<List<Conversation>> getAll() async {
    final db = await _db;
    final rows = await db.query(
      'conversations',
      orderBy: 'updatedAt DESC',
    );
    return rows.map(_rowToConversation).toList();
  }

  // ---------------------------------------------------------------------------
  // Read (single — with messages)
  // ---------------------------------------------------------------------------

  Future<Conversation?> getById(int id) async {
    final db = await _db;
    final rows = await db.query(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;

    final conv = _rowToConversation(rows.first);
    final messages = await _loadMessages(db, id);
    return conv.copyWith(messages: messages);
  }

  // ---------------------------------------------------------------------------
  // Read (by detectionKey — with messages)
  // ---------------------------------------------------------------------------

  Future<Conversation?> getByDetectionKey(String key) async {
    final db = await _db;
    final rows = await db.query(
      'conversations',
      where: 'detectionKey = ?',
      whereArgs: [key],
      orderBy: 'updatedAt DESC',
      limit: 1,
    );
    if (rows.isEmpty) return null;

    final conv = _rowToConversation(rows.first);
    final messages = await _loadMessages(db, conv.id!);
    return conv.copyWith(messages: messages);
  }

  // ---------------------------------------------------------------------------
  // Add message
  // ---------------------------------------------------------------------------

  Future<AssistantMessage> addMessage(
    int conversationId,
    AssistantMessage m,
  ) async {
    final db = await _db;
    await db.insert('conversation_messages', {
      'conversationId': conversationId,
      'role': m.role.name,
      'text': m.text,
      'timestamp': m.timestamp.toIso8601String(),
    });
    return m;
  }

  // ---------------------------------------------------------------------------
  // Update conversation metadata
  // ---------------------------------------------------------------------------

  Future<void> updateConversation(
    int id, {
    String? title,
    DateTime? updatedAt,
  }) async {
    final db = await _db;
    final values = <String, dynamic>{};
    if (title != null) values['title'] = title;
    if (updatedAt != null) values['updatedAt'] = updatedAt.toIso8601String();
    if (values.isEmpty) return;
    await db.update(
      'conversations',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // Delete single
  // ---------------------------------------------------------------------------

  Future<void> delete(int id) async {
    final db = await _db;
    await db.delete(
      'conversation_messages',
      where: 'conversationId = ?',
      whereArgs: [id],
    );
    await db.delete(
      'conversations',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ---------------------------------------------------------------------------
  // Delete all
  // ---------------------------------------------------------------------------

  Future<void> deleteAll() async {
    final db = await _db;
    await db.delete('conversation_messages');
    await db.delete('conversations');
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Conversation _rowToConversation(Map<String, dynamic> row) {
    AssistantContext? context;
    final contextJson = row['contextJson'] as String?;
    if (contextJson != null) {
      context = AssistantContext.fromJson(
        jsonDecode(contextJson) as Map<String, dynamic>,
      );
    }
    return Conversation(
      id: row['id'] as int,
      title: row['title'] as String,
      detectionKey: row['detectionKey'] as String?,
      context: context,
      createdAt: DateTime.parse(row['createdAt'] as String),
      updatedAt: DateTime.parse(row['updatedAt'] as String),
    );
  }

  Future<List<AssistantMessage>> _loadMessages(
    Database db,
    int conversationId,
  ) async {
    final rows = await db.query(
      'conversation_messages',
      where: 'conversationId = ?',
      whereArgs: [conversationId],
      orderBy: 'timestamp ASC',
    );
    return rows
        .map(
          (r) => AssistantMessage(
            role: AssistantRole.values.byName(r['role'] as String),
            text: r['text'] as String,
            timestamp: DateTime.parse(r['timestamp'] as String),
          ),
        )
        .toList();
  }
}
