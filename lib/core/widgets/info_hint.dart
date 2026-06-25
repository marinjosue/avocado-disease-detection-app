// lib/core/widgets/info_hint.dart
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class InfoHint extends StatelessWidget {
  const InfoHint({super.key, required this.term, required this.explanation});
  final String term;
  final String explanation;

  void _show(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(term, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.md),
            Text(explanation, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      icon: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
      tooltip: term,
      onPressed: () => _show(context),
    );
  }
}
