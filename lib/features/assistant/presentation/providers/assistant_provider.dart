import 'package:flutter/foundation.dart';

import '../../domain/assistant_context.dart';
import '../../domain/assistant_message.dart';
import '../../domain/assistant_service.dart';

class AssistantProvider extends ChangeNotifier {
  AssistantProvider(this._service);

  final AssistantService _service;

  final List<AssistantMessage> _messages = [];
  bool _isThinking = false;
  AssistantContext? _context;

  /// Unmodifiable view of the current conversation.
  List<AssistantMessage> get messages => List.unmodifiable(_messages);

  /// True while the service is still streaming a reply.
  bool get isThinking => _isThinking;

  /// The [AssistantContext] set by [startSession], if any.
  AssistantContext? get context => _context;

  /// Resets the conversation. Optionally seeds an assistant [greeting] message
  /// and sets the active [context].
  void startSession({AssistantContext? context, String? greeting}) {
    _messages.clear();
    _context = context;
    if (greeting != null) {
      _messages.add(
        AssistantMessage(
          role: AssistantRole.assistant,
          text: greeting,
          timestamp: DateTime.now(),
        ),
      );
    }
    notifyListeners();
  }

  /// Appends [text] as a user message, then streams the service reply into a
  /// growing assistant message, notifying listeners on every chunk.
  Future<void> send(String text) async {
    if (text.trim().isEmpty) return;

    _messages.add(
      AssistantMessage(
        role: AssistantRole.user,
        text: text.trim(),
        timestamp: DateTime.now(),
      ),
    );
    _isThinking = true;
    notifyListeners();

    // Seed an empty assistant message that we grow chunk-by-chunk.
    _messages.add(
      AssistantMessage(
        role: AssistantRole.assistant,
        text: '',
        timestamp: DateTime.now(),
      ),
    );

    var accumulated = '';
    try {
      await for (final chunk in _service.reply(
        prompt: text.trim(),
        context: _context,
        history: List.unmodifiable(_messages),
      )) {
        accumulated += chunk;
        _messages[_messages.length - 1] =
            _messages.last.copyWith(text: accumulated);
        notifyListeners();
      }
    } finally {
      _isThinking = false;
      notifyListeners();
    }
  }

  /// Clears all messages and resets context.
  void clear() {
    _messages.clear();
    _context = null;
    _isThinking = false;
    notifyListeners();
  }
}
