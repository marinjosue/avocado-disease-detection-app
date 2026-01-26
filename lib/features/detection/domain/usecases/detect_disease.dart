import '../entities/detection_result.dart';
import '../repositories/detection_repository.dart';

class DetectDisease {
  final DetectionRepository repository;

  DetectDisease({required this.repository});

  Future<DetectionResult> call(String imagePath) async {
    return await repository.detectDisease(imagePath);
  }
}
