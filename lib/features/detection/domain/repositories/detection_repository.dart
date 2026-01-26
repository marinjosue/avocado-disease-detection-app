import '../entities/detection_result.dart';

abstract class DetectionRepository {
  /// Detect disease from image
  Future<DetectionResult> detectDisease(String imagePath);

  /// Get detection history
  Future<List<DetectionResult>> getHistory();

  /// Save detection result
  Future<bool> saveDetectionResult(DetectionResult result);

  /// Delete detection result
  Future<bool> deleteDetectionResult(String resultId);

  /// Clear all history
  Future<bool> clearHistory();
}
