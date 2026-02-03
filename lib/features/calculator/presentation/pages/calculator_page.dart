import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/constants/colors.dart';
import '../../../detection/presentation/providers/detection_provider.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

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

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.calculator),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Cargar desde historial',
            onPressed: _loadFromHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.healthCalculator,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ingrese los datos manualmente o cárguelos desde su historial de detecciones',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Input Fields
            _buildTextField(
              controller: _totalFruitsController,
              label: l10n.totalFruits,
              icon: Icons.numbers,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _healthyController,
              label: l10n.healthyFruits,
              icon: Icons.check_circle,
              color: AppColors.healthy,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _manchaNegraController,
              label: l10n.manchaNegra,
              icon: Icons.warning,
              color: AppColors.manchaNegra,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _ronaController,
              label: l10n.rona,
              icon: Icons.error,
              color: AppColors.rona,
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _calculate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.calculateHealthScore),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _reset,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greyLight,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Results
            if (_healthyPercentage > 0 || _manchaNegraPercentage > 0 || _ronaPercentage > 0) ...[
              const Divider(),
              const SizedBox(height: 24),
              Text(
                'Resultados',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              
              _buildResultCard(
                l10n.healthyPercentage,
                _healthyPercentage,
                AppColors.healthy,
                Icons.check_circle,
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                'Mancha Negra',
                _manchaNegraPercentage,
                AppColors.manchaNegra,
                Icons.warning,
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                'Roña',
                _ronaPercentage,
                AppColors.rona,
                Icons.error,
              ),
              const SizedBox(height: 12),
              _buildResultCard(
                l10n.diseaseIncidence,
                _diseaseIncidence,
                AppColors.warning,
                Icons.analytics,
              ),

              const SizedBox(height: 24),
              _buildRecommendations(),
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
    Color color = AppColors.primary,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color, width: 2),
        ),
      ),
    );
  }

  Widget _buildResultCard(String label, double percentage, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendations() {
    String recommendation;
    Color color;
    IconData icon;

    if (_diseaseIncidence < 10) {
      recommendation = '''✓ Excelente estado fitosanitario
✓ Continuar con las prácticas actuales de manejo
✓ Mantener monitoreo preventivo regular
✓ Documentar las prácticas exitosas''';
      color = AppColors.healthy;
      icon = Icons.check_circle;
    } else if (_diseaseIncidence < 25) {
      recommendation = '''⚠ Nivel de alerta temprana
⚠ Incrementar frecuencia de monitoreo
⚠ Considerar aplicación preventiva de fungicidas
⚠ Revisar prácticas de manejo cultural
⚠ Mejorar ventilación y drenaje''';
      color = AppColors.warning;
      icon = Icons.warning;
    } else {
      recommendation = '''✗ Nivel crítico - Acción inmediata requerida
✗ Aplicar tratamiento fungicida urgente
✗ Eliminar frutos y material vegetal infectado
✗ Mejorar condiciones ambientales
✗ Consultar con especialista agronómico
✗ Implementar plan de manejo integrado''';
      color = AppColors.error;
      icon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              const Text(
                'Recomendaciones',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            recommendation,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
