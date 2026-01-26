import '../../domain/entities/detection_result.dart';

class DetectionModel extends DetectionResult {
  DetectionModel({
    required String id,
    required String imagePath,
    required String disease,
    required double confidence,
    required String description,
    required DateTime timestamp,
    Map<String, dynamic> details = const {},
  }) : super(
        id: id,
        imagePath: imagePath,
        disease: disease, 
        confidence: confidence,
        description: description,
        timestamp: timestamp,
        details: details,
      );

  factory DetectionModel.fromJson(Map<String, dynamic> json) {
    return DetectionModel(
      id: json['id'] ?? '',
      imagePath: json['imagePath'] ?? '',
      disease: json['disease'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      details: json['details'] ?? {},
    );
  }

  factory DetectionModel.fromEntity(DetectionResult entity) {
    return DetectionModel(
      id: entity.id,
      imagePath: entity.imagePath,
      disease: entity.disease,
      confidence: entity.confidence,
      description: entity.description,
      timestamp: entity.timestamp,
      details: entity.details,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'disease': disease,
        'confidence': confidence,
        'description': description,
        'timestamp': timestamp.toIso8601String(),
        'details': details,
      };
}
