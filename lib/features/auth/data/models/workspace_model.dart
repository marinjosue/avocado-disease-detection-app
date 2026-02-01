class WorkspaceModel {
  final String id;
  final String name;
  final String type; // farm, greenhouse, laboratory, home, other
  final String? description;
  final DateTime createdAt;

  WorkspaceModel({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    required this.createdAt,
  });

  factory WorkspaceModel.fromJson(Map<String, dynamic> json) {
    return WorkspaceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      type: json['type'] ?? 'other',
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  WorkspaceModel copyWith({
    String? id,
    String? name,
    String? type,
    String? description,
    DateTime? createdAt,
  }) {
    return WorkspaceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
