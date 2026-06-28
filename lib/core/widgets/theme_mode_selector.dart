import 'package:flutter/material.dart';

/// A themed Card containing three [RadioListTile]s for selecting [ThemeMode].
///
/// Labels and [onChanged] callback are provided by the caller so the widget
/// stays i18n-agnostic and free of hard-coded colours / font sizes.
class ThemeModeSelector extends StatelessWidget {
  const ThemeModeSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.lightLabel,
    required this.darkLabel,
    required this.systemLabel,
  });

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;
  final String lightLabel;
  final String darkLabel;
  final String systemLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: RadioGroup<ThemeMode>(
        groupValue: value,
        onChanged: (picked) {
          if (picked != null) onChanged(picked);
        },
        child: Column(
          children: [
            _tile(
              context,
              icon: Icons.brightness_auto,
              label: systemLabel,
              tileValue: ThemeMode.system,
            ),
            const Divider(height: 1),
            _tile(
              context,
              icon: Icons.light_mode,
              label: lightLabel,
              tileValue: ThemeMode.light,
            ),
            const Divider(height: 1),
            _tile(
              context,
              icon: Icons.dark_mode,
              label: darkLabel,
              tileValue: ThemeMode.dark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required ThemeMode tileValue,
  }) {
    final cs = Theme.of(context).colorScheme;
    return RadioListTile<ThemeMode>(
      value: tileValue,
      title: Row(
        children: [
          Icon(icon, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
      activeColor: cs.primary,
    );
  }
}
