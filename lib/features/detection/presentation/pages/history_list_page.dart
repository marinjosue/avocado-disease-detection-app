import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/models/detection_result.dart';
import '../../../../core/theme/disease_colors.dart';
import '../../../../core/widgets/app_states.dart';
import '../../../../core/widgets/confidence_bar.dart';
import '../../../../core/widgets/detection_tile.dart';
import '../../../../core/widgets/section_header.dart';
import '../providers/detection_provider.dart';

class HistoryListPage extends StatelessWidget {
  const HistoryListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showClearHistoryDialog(context, l10n),
          ),
        ],
      ),
      body: Consumer<DetectionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.detections.isEmpty) {
            return EmptyState(
              icon: Icons.history,
              title: l10n.emptyHistoryTitle,
              message: l10n.emptyHistoryMessage,
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadDetections(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.detections.length,
              itemBuilder: (context, index) {
                final d = provider.detections[index];
                final diseaseName = l10n.localeName == 'es'
                    ? d.getDiseaseNameES()
                    : d.getDiseaseNameEN();
                return DetectionTile(
                  result: d,
                  diseaseName: diseaseName,
                  timeLabel: _formatDateTime(d.timestamp),
                  onTap: () => _showDetectionDetails(context, d, l10n),
                  onDelete: () => _showDeleteConfirmation(context, d, l10n),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDetectionDetails(
      BuildContext context, DetectionResult detection, AppLocalizations l10n) {
    final diseaseColors = Theme.of(context).extension<DiseaseColors>()!;
    final statusColor = diseaseColors.forType(detection.diseaseType);
    final diseaseName = l10n.localeName == 'es'
        ? detection.getDiseaseNameES()
        : detection.getDiseaseNameEN();
    final recommendation = l10n.localeName == 'es'
        ? detection.getRecommendationES()
        : detection.getRecommendationEN();
    final file = File(detection.imagePath);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: file.existsSync()
                    ? Image.file(
                        file,
                        width: double.infinity,
                        height: 260,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: double.infinity,
                        height: 260,
                        color: statusColor.withValues(alpha: 0.08),
                        child: Icon(
                          diseaseIcon(detection.diseaseType),
                          size: 80,
                          color: statusColor.withValues(alpha: 0.5),
                        ),
                      ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diseaseName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatFullDateTime(detection.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ConfidenceBar(
                      value: detection.confidence,
                      color: statusColor,
                      label: l10n.confidence,
                    ),
                    const SizedBox(height: 20),
                    SectionHeader(title: l10n.recommendations),
                    const SizedBox(height: 8),
                    Text(
                      recommendation,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.close),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, DetectionResult detection, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmDeleteTitle),
        content: Text(l10n.confirmDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<DetectionProvider>().deleteDetection(detection.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.recordDeleted)),
              );
            },
            child: Text(
              l10n.delete,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmClearTitle),
        content: Text(l10n.confirmClearMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<DetectionProvider>().clearAllDetections();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.historyCleared)),
              );
            },
            child: Text(
              l10n.deleteAll,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else {
      return 'Hace un momento';
    }
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} '
        '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
