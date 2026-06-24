// lib/core/widgets/donut_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class DonutSection {
  const DonutSection({required this.value, required this.label, required this.color});
  final double value;
  final String label;
  final Color color;
}

class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.sections, this.centerValue, this.centerLabel});
  final List<DonutSection> sections;
  final String? centerValue;
  final String? centerLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = sections.fold<double>(0, (s, e) => s + e.value);
    return Row(
      children: [
        SizedBox(
          width: 120, height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 34,
                sections: sections
                    .map((s) => PieChartSectionData(
                          value: s.value, color: s.color, radius: 18, showTitle: false))
                    .toList(),
              )),
              if (centerValue != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(centerValue!, style: theme.textTheme.titleLarge),
                    if (centerLabel != null) Text(centerLabel!, style: theme.textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            children: sections.map((s) {
              final pct = total == 0 ? 0 : (s.value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(s.label, style: theme.textTheme.bodyMedium)),
                    Text('$pct%', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
