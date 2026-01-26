class DetectionResult {
  final String id;
  final String imagePath;
  final String disease;
  final double confidence;
  final String description;
  final DateTime timestamp;
  final Map<String, dynamic> details;

  DetectionResult({
    required this.id,
    required this.imagePath,
    required this.disease,
    required this.confidence,
    required this.description,
    required this.timestamp,
    this.details = const {},
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      id: json['id'] ?? '',
      imagePath: json['imagePath'] ?? '',
      disease: json['disease'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      details: json['details'] ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'disease': disease,
        'confidence': confidence,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'details': details,
      };

  @override
  String toString() =>
      'DetectionResult(id: $id, disease: $disease, confidence: $confidence)';
}
