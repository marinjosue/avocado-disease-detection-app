class DashboardStatistics {
  final int totalAnalyses;
  final int healthyFruits;
  final int manchaNegraCount;
  final int ronaCount;
  final double healthyPercentage;
  final double manchaNegraPercentage;
  final double ronaPercentage;
  final Map<DateTime, int> analysesPerDay;

  DashboardStatistics({
    required this.totalAnalyses,
    required this.healthyFruits,
    required this.manchaNegraCount,
    required this.ronaCount,
    required this.healthyPercentage,
    required this.manchaNegraPercentage,
    required this.ronaPercentage,
    required this.analysesPerDay,
  });

  factory DashboardStatistics.empty() {
    return DashboardStatistics(
      totalAnalyses: 0,
      healthyFruits: 0,
      manchaNegraCount: 0,
      ronaCount: 0,
      healthyPercentage: 0.0,
      manchaNegraPercentage: 0.0,
      ronaPercentage: 0.0,
      analysesPerDay: {},
    );
  }

  int get diseaseCount => manchaNegraCount + ronaCount;
  
  double get diseasePercentage => manchaNegraPercentage + ronaPercentage;
}
