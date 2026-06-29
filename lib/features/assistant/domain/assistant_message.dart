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

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
      };

  factory AssistantMessage.fromJson(Map<String, dynamic> j) {
    return AssistantMessage(
      role: AssistantRole.values.byName(j['role'] as String),
      text: j['text'] as String,
      timestamp: DateTime.parse(j['timestamp'] as String),
    );
  }
}
