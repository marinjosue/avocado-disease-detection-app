import 'package:flutter/material.dart';
import 'dart:io';
import '../../domain/entities/detection_result.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/widgets/primary_button.dart';
import 'camera_page.dart';

class ResultPage extends StatelessWidget {
  final DetectionResult result;

  const ResultPage({
    Key? key,
    required this.result,
  }) : super(key: key);

  Color _getDiseaseColor() {
    if (result.disease == AppStrings.healthy) return AppColors.healthy;
    if (result.disease == AppStrings.manchaNegra) return AppColors.manchaNegra;
    if (result.disease == AppStrings.rona) return AppColors.rona;
    return AppColors.grey;
  }

  IconData _getDiseaseIcon() {
    if (result.disease == AppStrings.healthy) return Icons.check_circle;
    if (result.disease == AppStrings.manchaNegra) return Icons.warning;
    if (result.disease == AppStrings.rona) return Icons.warning_amber;
    return Icons.help;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.result),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Imagen analizada
              Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    File(result.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Card de diagnóstico
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Ícono del resultado
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _getDiseaseColor().withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getDiseaseIcon(),
                        size: 50,
                        color: _getDiseaseColor(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Título diagnóstico
                    const Text(
                      AppStrings.diagnosis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Resultado
                    Text(
                      result.disease,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: _getDiseaseColor(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Confianza
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _getDiseaseColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.confidence + ': ',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.greyDark,
                            ),
                          ),
                          Text(
                            '${(result.confidence * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getDiseaseColor(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Recomendación
              if (result.description.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey.withOpacity(0.1),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(
                            Icons.lightbulb_outline,
                            color: AppColors.accent,
                            size: 24,
                          ),
                          SizedBox(width: 8),
                          Text(
                            AppStrings.recommendation,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.greyDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        result.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.greyDark,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              // Botones de acción
              PrimaryButton(
                label: AppStrings.newAnalysis,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CameraPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  AppStrings.done,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
