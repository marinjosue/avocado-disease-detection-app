import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.icon, this.onPressed, this.isLoading = false});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 22, width: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
                Text(label),
              ],
            ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.icon, this.onPressed});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
          Text(label),
        ],
      ),
    );
  }
}
