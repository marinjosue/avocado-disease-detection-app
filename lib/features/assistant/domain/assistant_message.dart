enum AssistantRole { user, assistant }

class AssistantMessage {
  final AssistantRole role;
  final String text;
  final DateTime timestamp;
  final String? audioPath;

  const AssistantMessage({
    required this.role,
    required this.text,
    required this.timestamp,
    this.audioPath,
  });

  AssistantMessage copyWith({String? text, String? audioPath}) {
    return AssistantMessage(
      role: role,
      text: text ?? this.text,
      timestamp: timestamp,
      audioPath: audioPath ?? this.audioPath,
    );
  }

  Map<String, dynamic> toJson() => {
        'role': role.name,
        'text': text,
        'timestamp': timestamp.toIso8601String(),
        'audioPath': audioPath,
      };

  factory AssistantMessage.fromJson(Map<String, dynamic> j) {
    return AssistantMessage(
      role: AssistantRole.values.byName(j['role'] as String),
      text: j['text'] as String,
      timestamp: DateTime.parse(j['timestamp'] as String),
      audioPath: j['audioPath'] as String?,
    );
  }
}
