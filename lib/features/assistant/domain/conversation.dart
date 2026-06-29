import 'assistant_message.dart';
import 'assistant_context.dart';

class Conversation {
  final int? id;
  final String title;
  final String? detectionKey;
  final AssistantContext? context;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<AssistantMessage> messages;

  const Conversation({
    this.id,
    required this.title,
    this.detectionKey,
    this.context,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
  });

  Conversation copyWith({
    int? id,
    String? title,
    String? detectionKey,
    AssistantContext? context,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<AssistantMessage>? messages,
  }) {
    return Conversation(
      id: id ?? this.id,
      title: title ?? this.title,
      detectionKey: detectionKey ?? this.detectionKey,
      context: context ?? this.context,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
    );
  }
}
