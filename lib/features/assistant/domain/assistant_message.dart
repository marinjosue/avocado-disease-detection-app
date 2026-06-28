enum AssistantRole { user, assistant }

class AssistantMessage {
  final AssistantRole role;
  final String text;
  final DateTime timestamp;

  const AssistantMessage({
    required this.role,
    required this.text,
    required this.timestamp,
  });

  AssistantMessage copyWith({String? text}) {
    return AssistantMessage(
      role: role,
      text: text ?? this.text,
      timestamp: timestamp,
    );
  }
}
