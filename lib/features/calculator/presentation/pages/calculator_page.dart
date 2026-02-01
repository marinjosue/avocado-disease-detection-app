import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../l10n/app_localizations.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  final _totalFruitsController = TextEditingController();
  final _healthyController = TextEditingController();
  final _manchaNegraController = TextEditingController();
  final _ronaController = TextEditingController();

  double _healthPercentage = 0;
  double _diseaseIncidence = 0;
  bool _hasCalculated = false;

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
        const SnackBar(content: Text('Please enter total number of fruits')),
      );
      return;
    }

    final counted = healthy + manchaNegra + rona;
    if (counted > total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Counted fruits cannot exceed total')),
      );
      return;
    }

    setState(() {
      _healthPercentage = (healthy / total) * 100;
      _diseaseIncidence = ((manchaNegra + rona) / total) * 100;
      _hasCalculated = true;
    });
  }

  void _reset() {
    setState(() {
      _totalFruitsController.clear();
      _healthyController.clear();
      _manchaNegraController.clear();
      _ronaController.clear();
      _healthPercentage = 0;
      _diseaseIncidence = 0;
      _hasCalculated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    // Definir valores por defecto para las traducciones
    final healthCalculatorLabel = l10n?.healthCalculator ?? 'Health Calculator';
    final totalFruitsLabel = l10n?.totalFruits ?? 'Total Fruits';
    final healthyFruitsLabel = l10n?.healthyFruits ?? 'Healthy Fruits';
    final manchaNegraLabel = l10n?.manchaNegra ?? 'Black Spot';
    final ronaLabel = l10n?.rona ?? 'Scab';
    final calculateHealthScoreLabel = l10n?.calculateHealthScore ?? 'Calculate Health Score';
    final healthyPercentageLabel = l10n?.healthyPercentage ?? 'Healthy Percentage';
    final diseaseIncidenceLabel = l10n?.diseaseIncidence ?? 'Disease Incidence';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(healthCalculatorLabel),
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF2E7D32).withOpacity(0.1),
                      const Color(0xFF66BB6A).withOpacity(0.05),
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.calculate,
                      size: 64,
                      color: const Color(0xFF2E7D32),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      healthCalculatorLabel,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Calculate the health status of your avocado crop based on detected diseases',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Input Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Enter Data',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Total Fruits
                    TextField(
                      controller: _totalFruitsController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: totalFruitsLabel,
                        prefixIcon: const Icon(Icons.agriculture),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Healthy Fruits
                    TextField(
                      controller: _healthyController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: healthyFruitsLabel,
                        prefixIcon: const Icon(Icons.check_circle, color: Color(0xFF388E3C)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF388E3C).withOpacity(0.05),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Mancha Negra
                    TextField(
                      controller: _manchaNegraController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: manchaNegraLabel,
                        prefixIcon: const Icon(Icons.warning, color: Color(0xFFF57C00)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF57C00).withOpacity(0.05),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Roña
                    TextField(
                      controller: _ronaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: ronaLabel,
                        prefixIcon: const Icon(Icons.error, color: Color(0xFFD32F2F)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: const Color(0xFFD32F2F).withOpacity(0.05),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _calculate,
                            icon: const Icon(Icons.calculate),
                            label: Text(calculateHealthScoreLabel),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2E7D32),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: _reset,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(Icons.refresh),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            if (_hasCalculated) ...[
              const SizedBox(height: 24),
              
              // Results Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Results',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Health Percentage
                      _buildResultItem(
                        healthyPercentageLabel,
                        '${_healthPercentage.toStringAsFixed(1)}%',
                        const Color(0xFF388E3C),
                        Icons.check_circle,
                      ),
                      const SizedBox(height: 16),
                      
                      // Disease Incidence
                      _buildResultItem(
                        diseaseIncidenceLabel,
                        '${_diseaseIncidence.toStringAsFixed(1)}%',
                        const Color(0xFFD32F2F),
                        Icons.error,
                      ),
                      const SizedBox(height: 24),
                      
                      // Chart
                      SizedBox(
                        height: 200,
                        child: _buildPieChart(),
                      ),
                      const SizedBox(height: 20),
                      
                      // Recommendation
                      _buildRecommendation(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
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

  Widget _buildPieChart() {
    final healthy = int.tryParse(_healthyController.text) ?? 0;
    final manchaNegra = int.tryParse(_manchaNegraController.text) ?? 0;
    final rona = int.tryParse(_ronaController.text) ?? 0;
    final total = healthy + manchaNegra + rona;

    if (total == 0) return const SizedBox();

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          if (healthy > 0)
            PieChartSectionData(
              value: healthy.toDouble(),
              title: '${((healthy / total) * 100).toStringAsFixed(1)}%',
              color: const Color(0xFF388E3C),
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (manchaNegra > 0)
            PieChartSectionData(
              value: manchaNegra.toDouble(),
              title: '${((manchaNegra / total) * 100).toStringAsFixed(1)}%',
              color: const Color(0xFFF57C00),
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          if (rona > 0)
            PieChartSectionData(
              value: rona.toDouble(),
              title: '${((rona / total) * 100).toStringAsFixed(1)}%',
              color: const Color(0xFFD32F2F),
              radius: 60,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendation() {
    String recommendation;
    Color color;
    IconData icon;

    if (_healthPercentage >= 80) {
      recommendation = 'Excellent crop health! Continue with current practices. Your avocados show minimal disease presence.';
      color = const Color(0xFF388E3C);
      icon = Icons.thumb_up;
    } else if (_healthPercentage >= 60) {
      recommendation = 'Good crop health. Monitor affected areas and implement preventive measures to maintain quality.';
      color = const Color(0xFF66BB6A);
      icon = Icons.check;
    } else if (_healthPercentage >= 40) {
      recommendation = 'Moderate disease incidence detected. Increase monitoring and apply targeted treatments to affected areas.';
      color = const Color(0xFFF57C00);
      icon = Icons.warning;
    } else {
      recommendation = 'Critical: High disease incidence! Immediate intervention required. Consult with agricultural specialists for comprehensive treatment plan.';
      color = const Color(0xFFD32F2F);
      icon = Icons.error;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.2), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommendation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
