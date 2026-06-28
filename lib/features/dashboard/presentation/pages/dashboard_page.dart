import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/disease_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/widgets/donut_chart.dart';
import '../../../../core/widgets/detection_tile.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../detection/presentation/providers/detection_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard),
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

          if (stats.totalAnalyses == 0) {
            return RefreshIndicator(
              onRefresh: () => provider.loadDetections(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: EmptyState(
                    icon: Icons.insights,
                    title: l10n.emptyDashboardTitle,
                    message: l10n.emptyDashboardMessage,
                  ),
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDetections(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCards(context, stats, l10n),
                  const SizedBox(height: 24),
                  SectionHeader(title: l10n.distribution),
                  const SizedBox(height: 12),
                  _buildDonutChart(context, stats, l10n),
                  const SizedBox(height: 24),
                  SectionHeader(title: l10n.recentActivity),
                  const SizedBox(height: 12),
                  _buildRecentActivity(context, provider, l10n),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards(BuildContext context, dynamic stats, AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final dc = Theme.of(context).extension<DiseaseColors>()!;
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.analytics,
                label: l10n.totalAnalyses,
                value: stats.totalAnalyses.toString(),
                accentColor: cs.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.check_circle,
                label: l10n.healthyFruits,
                value: stats.healthyFruits.toString(),
                accentColor: dc.healthy,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                icon: Icons.coronavirus,
                label: l10n.manchaNegra,
                value: stats.manchaNegraCount.toString(),
                accentColor: dc.manchaNegra,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                icon: Icons.warning_amber_rounded,
                label: l10n.rona,
                value: stats.ronaCount.toString(),
                accentColor: dc.rona,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDonutChart(BuildContext context, dynamic stats, AppLocalizations l10n) {
    final dc = Theme.of(context).extension<DiseaseColors>()!;
    return DonutChart(
      centerValue: stats.totalAnalyses.toString(),
      centerLabel: l10n.totalAnalyses,
      sections: [
        DonutSection(
          value: stats.healthyPercentage,
          label: l10n.healthy,
          color: dc.healthy,
        ),
        DonutSection(
          value: stats.manchaNegraPercentage,
          label: l10n.manchaNegra,
          color: dc.manchaNegra,
        ),
        DonutSection(
          value: stats.ronaPercentage,
          label: l10n.rona,
          color: dc.rona,
        ),
      ],
    );
  }

  Widget _buildRecentActivity(BuildContext context, DetectionProvider provider, AppLocalizations l10n) {
    final recentDetections = provider.getRecentDetections(limit: 5);

    if (recentDetections.isEmpty) {
      return EmptyState(
        icon: Icons.history,
        title: l10n.noHistoryFound,
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentDetections.length,
      itemBuilder: (context, index) {
        final d = recentDetections[index];
        final diseaseName = l10n.localeName == 'es' ? d.getDiseaseNameES() : d.getDiseaseNameEN();
        final timeLabel = _formatDateTime(d.timestamp, l10n);
        return DetectionTile(
          result: d,
          diseaseName: diseaseName,
          timeLabel: timeLabel,
          onTap: null,
        );
      },
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
