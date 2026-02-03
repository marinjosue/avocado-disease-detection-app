import 'package:flutter/material.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/models/detection_result.dart';
import '../../../../core/models/dashboard_statistics.dart';

class DetectionProvider extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  
  List<DetectionResult> _detections = [];
  DashboardStatistics _statistics = DashboardStatistics.empty();
  bool _isLoading = false;
  String? _currentWorkspaceId = 'default';

  List<DetectionResult> get detections => _detections;
  DashboardStatistics get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get currentWorkspaceId => _currentWorkspaceId;

  DetectionProvider() {
    loadDetections();
  }

  void setCurrentWorkspace(String? workspaceId) {
    _currentWorkspaceId = workspaceId;
    loadDetections();
  }

  Future<void> loadDetections() async {
    _isLoading = true;
    notifyListeners();

    try {
      _detections = await _dbHelper.getAllDetectionResults(
        workspaceId: _currentWorkspaceId,
      );
      await _calculateStatistics();
    } catch (e) {
      debugPrint('Error loading detections: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addDetection(DetectionResult detection) async {
    try {
      final savedDetection = await _dbHelper.createDetectionResult(detection);
      _detections.insert(0, savedDetection);
      await _calculateStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding detection: $e');
      rethrow;
    }
  }

  Future<void> updateDetection(DetectionResult detection) async {
    try {
      await _dbHelper.updateDetectionResult(detection);
      final index = _detections.indexWhere((d) => d.id == detection.id);
      if (index != -1) {
        _detections[index] = detection;
        await _calculateStatistics();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating detection: $e');
      rethrow;
    }
  }

  Future<void> deleteDetection(int id) async {
    try {
      await _dbHelper.deleteDetectionResult(id);
      _detections.removeWhere((d) => d.id == id);
      await _calculateStatistics();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting detection: $e');
      rethrow;
    }
  }

  Future<void> _calculateStatistics() async {
    try {
      final stats = await _dbHelper.getStatistics(
        workspaceId: _currentWorkspaceId,
      );

      final total = stats.values.fold<int>(0, (sum, count) => sum + count);
      final healthy = stats['healthy'] ?? 0;
      final manchaNegra = stats['mancha_negra'] ?? 0;
      final rona = stats['rona'] ?? 0;

      final healthyPercentage = total > 0 ? (healthy / total) * 100 : 0.0;
      final manchaNegraPercentage = total > 0 ? (manchaNegra / total) * 100 : 0.0;
      final ronaPercentage = total > 0 ? (rona / total) * 100 : 0.0;

      // Get analyses per day for the last 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      final recentDetections = await _dbHelper.getDetectionsByDateRange(
        startDate: sevenDaysAgo,
        endDate: now,
        workspaceId: _currentWorkspaceId,
      );

      final Map<DateTime, int> analysesPerDay = {};
      for (var detection in recentDetections) {
        final date = DateTime.parse(detection['timestamp']);
        final dateKey = DateTime(date.year, date.month, date.day);
        analysesPerDay[dateKey] = (analysesPerDay[dateKey] ?? 0) + 1;
      }

      _statistics = DashboardStatistics(
        totalAnalyses: total,
        healthyFruits: healthy,
        manchaNegraCount: manchaNegra,
        ronaCount: rona,
        healthyPercentage: healthyPercentage,
        manchaNegraPercentage: manchaNegraPercentage,
        ronaPercentage: ronaPercentage,
        analysesPerDay: analysesPerDay,
      );
    } catch (e) {
      debugPrint('Error calculating statistics: $e');
      _statistics = DashboardStatistics.empty();
    }
  }

  List<DetectionResult> getRecentDetections({int limit = 10}) {
    return _detections.take(limit).toList();
  }

  List<DetectionResult> getDetectionsByType(String diseaseType) {
    return _detections.where((d) => d.diseaseType == diseaseType).toList();
  }

  Future<void> clearAllDetections() async {
    try {
      await _dbHelper.deleteAllDetectionResults();
      _detections.clear();
      _statistics = DashboardStatistics.empty();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing detections: $e');
      rethrow;
    }
  }
}
