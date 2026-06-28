import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/disease_colors.dart';
import '../../../../core/widgets/app_buttons.dart';
import '../../../../core/widgets/info_hint.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../detection/presentation/providers/detection_provider.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final TextEditingController _totalFruitsController = TextEditingController();
  final TextEditingController _healthyController = TextEditingController();
  final TextEditingController _manchaNegraController = TextEditingController();
  final TextEditingController _ronaController = TextEditingController();

  double _healthyPercentage = 0.0;
  double _manchaNegraPercentage = 0.0;
  double _ronaPercentage = 0.0;
  double _diseaseIncidence = 0.0;

  @override
  void dispose() {
    _totalFruitsController.dispose();
    _healthyController.dispose();
    _manchaNegraController.dispose();
    _ronaController.dispose();
    super.dispose();
  }

  void _calculate() {
    final total = int.tryParse(_totalFruitsController.text) ?? 0;
    final healthy = int.tryParse(_healthyController.text) ?? 0;
    final manchaNegra = int.tryParse(_manchaNegraController.text) ?? 0;
    final rona = int.tryParse(_ronaController.text) ?? 0;

    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingrese el total de frutos')),
      );
      return;
    }

    final sum = healthy + manchaNegra + rona;
    if (sum != total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La suma de frutos no coincide con el total'),
        ),
      );
      return;
    }

    setState(() {
      _healthyPercentage = (healthy / total) * 100;
      _manchaNegraPercentage = (manchaNegra / total) * 100;
      _ronaPercentage = (rona / total) * 100;
      _diseaseIncidence = ((manchaNegra + rona) / total) * 100;
    });
  }

  void _loadFromHistory() {
    final provider = context.read<DetectionProvider>();
    final stats = provider.statistics;

    setState(() {
      _totalFruitsController.text = stats.totalAnalyses.toString();
      _healthyController.text = stats.healthyFruits.toString();
      _manchaNegraController.text = stats.manchaNegraCount.toString();
      _ronaController.text = stats.ronaCount.toString();
    });

    _calculate();
  }

  void _reset() {
    setState(() {
      _totalFruitsController.clear();
      _healthyController.clear();
      _manchaNegraController.clear();
      _ronaController.clear();
      _healthyPercentage = 0.0;
      _manchaNegraPercentage = 0.0;
      _ronaPercentage = 0.0;
      _diseaseIncidence = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dc = theme.extension<DiseaseColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculator),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: l10n.loadFromHistory,
            onPressed: _loadFromHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.healthCalculator,
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Ingrese los datos manualmente o cárguelos desde su historial de detecciones',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Input Fields
            _buildTextField(
              controller: _totalFruitsController,
              label: l10n.totalFruits,
              icon: Icons.numbers,
              iconColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTextField(
              controller: _healthyController,
              label: l10n.healthyFruits,
              icon: Icons.check_circle,
              iconColor: dc.healthy,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTextField(
              controller: _manchaNegraController,
              label: l10n.manchaNegra,
              icon: Icons.warning,
              iconColor: dc.manchaNegra,
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildTextField(
              controller: _ronaController,
              label: l10n.rona,
              icon: Icons.error,
              iconColor: dc.rona,
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: l10n.calculateHealthScore,
                    onPressed: _calculate,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                IconButton.outlined(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset',
                  onPressed: _reset,
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xxxl),

            // Results
            if (_healthyPercentage > 0 || _manchaNegraPercentage > 0 || _ronaPercentage > 0) ...[
              const Divider(),
              const SizedBox(height: AppSpacing.xxl),
              SectionHeader(title: l10n.results),
              const SizedBox(height: AppSpacing.lg),

              _buildResultCard(
                label: l10n.healthyPercentage,
                percentage: _healthyPercentage,
                color: dc.healthy,
                icon: Icons.check_circle,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildResultCard(
                label: l10n.manchaNegra,
                percentage: _manchaNegraPercentage,
                color: dc.manchaNegra,
                icon: Icons.warning,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildResultCard(
                label: l10n.rona,
                percentage: _ronaPercentage,
                color: dc.rona,
                icon: Icons.error,
              ),
              const SizedBox(height: AppSpacing.md),
              _buildResultCard(
                label: l10n.diseaseIncidence,
                percentage: _diseaseIncidence,
                color: theme.colorScheme.secondary,
                icon: Icons.analytics,
                trailing: InfoHint(
                  term: l10n.diseaseIncidence,
                  explanation: l10n.confidenceHint,
                ),
              ),

              const SizedBox(height: AppSpacing.xxl),
              _buildRecommendations(l10n, theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color iconColor,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor),
      ),
    );
  }

  Widget _buildResultCard({
    required String label,
    required double percentage,
    required Color color,
    required IconData icon,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: theme.textTheme.headlineSmall?.copyWith(color: color),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildRecommendations(AppLocalizations l10n, ThemeData theme) {
    String recommendation;
    Color color;
    IconData icon;

    if (_diseaseIncidence < 10) {
      recommendation = '''✓ Excelente estado fitosanitario
✓ Continuar con las prácticas actuales de manejo
✓ Mantener monitoreo preventivo regular
✓ Documentar las prácticas exitosas''';
      color = theme.extension<DiseaseColors>()!.healthy;
      icon = Icons.check_circle;
    } else if (_diseaseIncidence < 25) {
      recommendation = '''⚠ Nivel de alerta temprana
⚠ Incrementar frecuencia de monitoreo
⚠ Considerar aplicación preventiva de fungicidas
⚠ Revisar prácticas de manejo cultural
⚠ Mejorar ventilación y drenaje''';
      color = theme.extension<DiseaseColors>()!.rona;
      icon = Icons.warning;
    } else {
      recommendation = '''✗ Nivel crítico - Acción inmediata requerida
✗ Aplicar tratamiento fungicida urgente
✗ Eliminar frutos y material vegetal infectado
✗ Mejorar condiciones ambientales
✗ Consultar con especialista agronómico
✗ Implementar plan de manejo integrado''';
      color = theme.colorScheme.error;
      icon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: AppSpacing.md),
              Text(
                l10n.recommendations,
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            recommendation,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
        ],
      ),
    );
  }
}
