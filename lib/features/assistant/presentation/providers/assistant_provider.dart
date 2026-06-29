import 'package:flutter/foundation.dart';

import '../../data/conversation_repository.dart';
import '../../domain/assistant_context.dart';
import '../../domain/assistant_message.dart';
import '../../domain/assistant_service.dart';
import '../../domain/conversation.dart';

class AssistantProvider extends ChangeNotifier {
  AssistantProvider(this._service, {ConversationRepository? repository})
      : _repo = repository ?? ConversationRepository();

  final AssistantService _service;
  final ConversationRepository _repo;

  List<Conversation> _conversations = [];
  Conversation? _current;
  bool _isThinking = false;

  // ---------------------------------------------------------------------------
  // New public API
  // ---------------------------------------------------------------------------

  /// All persisted conversations (ordered by updatedAt DESC, no messages).
  List<Conversation> get conversations => List.unmodifiable(_conversations);

  /// The currently open conversation (with messages loaded).
  Conversation? get current => _current;

  /// True while the service is still streaming a reply.
  bool get isThinking => _isThinking;

  /// Loads the conversation list from the repository.
  Future<void> loadConversations() async {
    _conversations = await _repo.getAll();
    notifyListeners();
  }

  /// Opens the existing conversation linked to [ctx.imagePath] (by detectionKey),
  /// or creates a new one if none exists yet.
  Future<Conversation> openOrCreateForDetection(AssistantContext ctx) async {
    if (ctx.imagePath != null) {
      final existing = await _repo.getByDetectionKey(ctx.imagePath!);
      if (existing != null) {
        _current = existing;
        notifyListeners();
        return existing;
      }
    }

    final now = DateTime.now();
    final created = await _repo.create(
      Conversation(
        title: _detectionTitle(ctx),
        detectionKey: ctx.imagePath,
        context: ctx,
        createdAt: now,
        updatedAt: now,
      ),
    );
    _current = created;
    await _refreshList();
    return created;
  }

  /// Creates a new general (non-detection) conversation and opens it.
  Future<Conversation> createGeneral() async {
    final now = DateTime.now();
    final created = await _repo.create(
      Conversation(
        title: 'Conversación',
        createdAt: now,
        updatedAt: now,
      ),
    );
    _current = created;
    await _refreshList();
    return created;
  }

  /// Opens a conversation by id (loads its messages).
  Future<Conversation> openConversation(int id) async {
    final conv = await _repo.getById(id);
    _current = conv;
    notifyListeners();
    return conv!;
  }

  /// Sends a user message, streams the assistant reply, and persists both.
  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    // Ensure a current conversation exists.
    if (_current == null) {
      await createGeneral();
    }

    // Snapshot history BEFORE adding the new user message.
    final history = List<AssistantMessage>.from(_current!.messages);

    final now = DateTime.now();
    final userMsg = AssistantMessage(
      role: AssistantRole.user,
      text: text.trim(),
      timestamp: now,
    );

    // Add to in-memory list and notify.
    final msgs = List<AssistantMessage>.from(_current!.messages)..add(userMsg);
    _current = _current!.copyWith(messages: msgs);
    notifyListeners();

    // Persist the user message.
    await _repo.addMessage(_current!.id!, userMsg);

    // Auto-title: if no detectionKey and this is the first user turn, use the
    // message text (truncated to 40 chars) as the conversation title.
    if (_current!.detectionKey == null) {
      final userMessages =
          _current!.messages.where((m) => m.role == AssistantRole.user);
      if (userMessages.length == 1) {
        final autoTitle =
            text.length > 40 ? '${text.substring(0, 40)}…' : text;
        _current = _current!.copyWith(title: autoTitle);
        await _repo.updateConversation(_current!.id!, title: autoTitle);
        notifyListeners();
      }
    }

    _isThinking = true;
    notifyListeners();

    // Seed an empty assistant message that grows token-by-token.
    final assistantSeed = AssistantMessage(
      role: AssistantRole.assistant,
      text: '',
      timestamp: DateTime.now(),
    );
    final msgsWithSeed =
        List<AssistantMessage>.from(_current!.messages)..add(assistantSeed);
    _current = _current!.copyWith(messages: msgsWithSeed);

    var accumulated = '';
    try {
      await for (final chunk in _service.reply(
        prompt: text.trim(),
        context: _current!.context,
        history: history,
      )) {
        accumulated += chunk;
        final updated = List<AssistantMessage>.from(_current!.messages);
        updated[updated.length - 1] = updated.last.copyWith(text: accumulated);
        _current = _current!.copyWith(messages: updated);
        notifyListeners();
      }
    } finally {
      _isThinking = false;

      // Persist the final assistant message.
      if (accumulated.isNotEmpty) {
        final finalMsg = AssistantMessage(
          role: AssistantRole.assistant,
          text: accumulated,
          timestamp: DateTime.now(),
        );
        await _repo.addMessage(_current!.id!, finalMsg);
      }

      // Update updatedAt on the conversation.
      final updatedAt = DateTime.now();
      _current = _current!.copyWith(updatedAt: updatedAt);
      await _repo.updateConversation(_current!.id!, updatedAt: updatedAt);

      await _refreshList();
      notifyListeners();
    }
  }

  /// Deletes a conversation by id.
  Future<void> deleteConversation(int id) async {
    await _repo.delete(id);
    if (_current?.id == id) {
      _current = null;
    }
    await _refreshList();
    notifyListeners();
  }

  /// Deletes all conversations.
  Future<void> deleteAll() async {
    await _repo.deleteAll();
    _current = null;
    _conversations = [];
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Backward-compat shims (ChatPage / camera_page / history compile unchanged)
  // ---------------------------------------------------------------------------

  /// Unmodifiable view of the current conversation's messages.
  /// Returns empty list if no conversation is open.
  List<AssistantMessage> get messages =>
      _current?.messages ?? const <AssistantMessage>[];

  /// The [AssistantContext] of the current conversation, if any.
  AssistantContext? get context => _current?.context;

  /// Backward-compat: resets/opens a conversation for [context], or creates a
  /// general one. A [greeting] message (if provided) is seeded into the
  /// in-memory message list synchronously so existing widget tests pass.
  ///
  /// Returns a [Future<void>] — callers that do not await it are safe; the
  /// synchronous greeting seed is visible immediately.
  Future<void> startSession({
    AssistantContext? context,
    String? greeting,
  }) async {
    if (context != null) {
      await openOrCreateForDetection(context);
    } else if (_current == null) {
      await createGeneral();
    } else {
      // Already has a general conversation open — clear its messages.
      final msgs = List<AssistantMessage>.from(_current!.messages)..clear();
      _current = _current!.copyWith(messages: msgs);
    }

    // Seed the greeting into the in-memory list (not persisted) for compat.
    if (greeting != null) {
      final greetingMsg = AssistantMessage(
        role: AssistantRole.assistant,
        text: greeting,
        timestamp: DateTime.now(),
      );
      final msgs =
          List<AssistantMessage>.from(_current!.messages)..insert(0, greetingMsg);
      _current = _current!.copyWith(messages: msgs);
    }

    notifyListeners();
  }

  /// Clears all messages and resets context (legacy compat).
  void clear() {
    if (_current != null) {
      _current = _current!.copyWith(messages: const []);
    }
    _isThinking = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  Future<void> _refreshList() async {
    _conversations = await _repo.getAll();
    notifyListeners();
  }

  String _detectionTitle(AssistantContext ctx) {
    final name = ctx.diseaseName ?? 'Detección';
    final conf = ctx.confidence != null
        ? ' · ${(ctx.confidence! * 100).round()}%'
        : '';
    return '$name$conf';
  }
}
