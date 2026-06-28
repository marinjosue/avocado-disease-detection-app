// lib/core/widgets/detection_tile.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/detection_result.dart';
import '../theme/app_tokens.dart';
import '../theme/disease_colors.dart';

class DetectionTile extends StatelessWidget {
  const DetectionTile({
    super.key,
    required this.result,
    required this.diseaseName,
    required this.timeLabel,
    this.onTap,
    this.onDelete,
  });

  final DetectionResult result;
  final String diseaseName;
  final String timeLabel;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = (theme.extension<DiseaseColors>() ?? DiseaseColors.light).forType(result.diseaseType);
    final file = File(result.imagePath);
    final hasImage = file.existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: 56, height: 56,
                  child: hasImage
                      ? Image.file(file, fit: BoxFit.cover)
                      : Container(
                          color: color.withValues(alpha: 0.12),
                          child: Icon(diseaseIcon(result.diseaseType), color: color),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(diseaseName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(timeLabel, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('${(result.confidence * 100).round()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
