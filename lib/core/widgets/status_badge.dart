import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/disease_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.diseaseType, required this.label});
  final String diseaseType;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).extension<DiseaseColors>()!.forType(diseaseType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(diseaseIcon(diseaseType), size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.icon, this.color});
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: c), const SizedBox(width: 6)],
          Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
