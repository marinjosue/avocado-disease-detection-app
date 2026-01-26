import 'dart:io';
import '../../domain/entities/detection_result.dart';
import '../../domain/repositories/detection_repository.dart';
import '../datasources/tflite_datasource.dart';
import '../models/detection_model.dart';

class DetectionRepositoryImpl implements DetectionRepository {
  final TfliteDatasource tfliteDatasource;
  final List<DetectionResult> _history = [];

  DetectionRepositoryImpl({
    required this.tfliteDatasource,
  });

  @override
  Future<DetectionResult> detectDisease(String imagePath) async {
    try {
      final result = await tfliteDatasource.runInference(
        File(imagePath),
      );

      final detectionResult = DetectionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: imagePath,
        disease: result['disease'] ?? 'Unknown',
        confidence: result['confidence'] ?? 0.0,
        description: result['description'] ?? '',
        timestamp: DateTime.now(),
        details: result['details'] ?? {},
      );

      _history.add(detectionResult);
      return detectionResult;
    } catch (e) {
      throw Exception('Error detecting disease: $e');
    }
  }

  @override
  Future<List<DetectionResult>> getHistory() async {
    return _history;
  }

  @override
  Future<bool> saveDetectionResult(DetectionResult result) async {
    try {
      _history.add(result);
      // TODO: Save to local database or file
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> deleteDetectionResult(String resultId) async {
    try {
      _history.removeWhere((result) => result.id == resultId);
      // TODO: Delete from local database or file
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clearHistory() async {
    try {
      _history.clear();
      // TODO: Clear local database or file
      return true;
    } catch (e) {
      return false;
    }
  }
}
