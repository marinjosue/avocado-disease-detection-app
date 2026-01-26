import 'package:flutter/material.dart';
import '../../domain/entities/detection_result.dart';
import '../../domain/repositories/detection_repository.dart';
import '../../domain/usecases/detect_disease.dart';

class DetectionController extends ChangeNotifier {
  final DetectionRepository repository;
  late DetectDisease detectDiseaseUseCase;

  DetectionResult? _currentResult;
  List<DetectionResult> _history = [];
  bool _isLoading = false;
  String? _error;

  DetectionController({required this.repository}) {
    detectDiseaseUseCase = DetectDisease(repository: repository);
    _loadHistory();
  }

  // Getters
  DetectionResult? get currentResult => _currentResult;
  List<DetectionResult> get history => _history;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Detect disease from image
  Future<bool> detectDisease(String imagePath) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentResult = await detectDiseaseUseCase.call(imagePath);
      _history.insert(0, _currentResult!);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Load history
  Future<void> _loadHistory() async {
    try {
      _history = await repository.getHistory();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete result
  Future<bool> deleteResult(String resultId) async {
    try {
      final success = await repository.deleteDetectionResult(resultId);
      if (success) {
        _history.removeWhere((result) => result.id == resultId);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear history
  Future<bool> clearHistory() async {
    try {
      final success = await repository.clearHistory();
      if (success) {
        _history.clear();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Save result
  Future<bool> saveResult(DetectionResult result) async {
    try {
      return await repository.saveDetectionResult(result);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear current result
  void clearCurrentResult() {
    _currentResult = null;
    notifyListeners();
  }
}
