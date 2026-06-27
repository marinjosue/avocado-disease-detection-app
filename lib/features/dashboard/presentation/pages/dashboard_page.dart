import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/models/detection_result.dart';
import '../../../detection/presentation/providers/detection_provider.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<DetectionProvider>().loadDetections();
            },
          ),
        ],
      ),
      body: Consumer<DetectionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.statistics;

          return RefreshIndicator(
            onRefresh: () => provider.loadDetections(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Statistics Cards
                  _buildStatisticsCards(context, stats, l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Pie Chart
                  Text(
                    l10n.statistics,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildPieChart(stats, l10n),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Activity
                  Text(
                    l10n.recentActivity,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecentActivity(context, provider, l10n),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatisticsCards(BuildContext context, dynamic stats, AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.totalAnalyses,
                stats.totalAnalyses.toString(),
                Icons.analytics,
                AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.healthyFruits,
                stats.healthyFruits.toString(),
                Icons.check_circle,
                AppColors.healthy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                l10n.manchaNegra,
                stats.manchaNegraCount.toString(),
                Icons.warning,
                AppColors.manchaNegra,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                l10n.rona,
                stats.ronaCount.toString(),
                Icons.error,
                AppColors.rona,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(dynamic stats, AppLocalizations l10n) {
    if (stats.totalAnalyses == 0) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text(l10n.noDataToShow),
      );
    }

    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: stats.healthyPercentage,
              title: '${stats.healthyPercentage.toStringAsFixed(1)}%',
              color: AppColors.healthy,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: stats.manchaNegraPercentage,
              title: '${stats.manchaNegraPercentage.toStringAsFixed(1)}%',
              color: AppColors.manchaNegra,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            PieChartSectionData(
              value: stats.ronaPercentage,
              title: '${stats.ronaPercentage.toStringAsFixed(1)}%',
              color: AppColors.rona,
              radius: 50,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context, DetectionProvider provider, AppLocalizations l10n) {
    final recentDetections = provider.getRecentDetections(limit: 5);

    if (recentDetections.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        child: Text(
          l10n.noHistoryFound,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentDetections.length,
      itemBuilder: (context, index) {
        final detection = recentDetections[index];
        return _buildDetectionCard(detection, l10n);
      },
    );
  }

  Widget _buildDetectionCard(DetectionResult detection, AppLocalizations l10n) {
    Color statusColor;
    switch (detection.diseaseType) {
      case 'healthy':
        statusColor = AppColors.healthy;
        break;
      case 'mancha_negra':
        statusColor = AppColors.manchaNegra;
        break;
      case 'rona':
        statusColor = AppColors.rona;
        break;
      default:
        statusColor = AppColors.grey;
    }

    // Obtener nombre de enfermedad según idioma
    String diseaseName;
    if (l10n.localeName == 'es') {
      diseaseName = detection.getDiseaseNameES();
    } else {
      diseaseName = detection.getDiseaseNameEN();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              detection.isHealthy ? Icons.check_circle : Icons.warning,
              color: statusColor,
              size: 32,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diseaseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${l10n.confidence}: ${(detection.confidence * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  _formatDateTime(detection.timestamp, l10n),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textHint,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      final days = difference.inDays;
      if (l10n.localeName == 'es') {
        return 'Hace $days día${days > 1 ? 's' : ''}';
      } else {
        return '$days day${days > 1 ? 's' : ''} ago';
      }
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      if (l10n.localeName == 'es') {
        return 'Hace $hours hora${hours > 1 ? 's' : ''}';
      } else {
        return '$hours hour${hours > 1 ? 's' : ''} ago';
      }
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      if (l10n.localeName == 'es') {
        return 'Hace $minutes minuto${minutes > 1 ? 's' : ''}';
      } else {
        return '$minutes minute${minutes > 1 ? 's' : ''} ago';
      }
    } else {
      return l10n.agoMoment;
    }
  }
}
