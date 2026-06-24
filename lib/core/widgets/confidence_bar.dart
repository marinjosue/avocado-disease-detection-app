import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({super.key, required this.value, this.color});
  final double value; // 0.0 - 1.0
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    final clamped = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Confianza', style: theme.textTheme.bodySmall),
            Text('${(clamped * 100).round()}%',
                style: theme.textTheme.bodyMedium?.copyWith(color: c, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 8,
            backgroundColor: c.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(c),
          ),
        ),
      ],
    );
  }
}
