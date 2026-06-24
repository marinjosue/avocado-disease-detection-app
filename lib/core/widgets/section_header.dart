import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title.toUpperCase(), style: theme.textTheme.labelLarge),
        if (action != null) action!,
      ],
    );
  }
}
