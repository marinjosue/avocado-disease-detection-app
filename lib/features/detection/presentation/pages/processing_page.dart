import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../domain/entities/detection_result.dart';
import 'result_page.dart';

class ProcessingPage extends StatefulWidget {
  final String imagePath;

  const ProcessingPage({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _processImage();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _processImage() async {
    // Simular procesamiento (mientras no hay modelo)
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Generar resultado mock
    final random = Random();
    final diseases = [
      AppStrings.healthy,
      AppStrings.manchaNegra,
      AppStrings.rona,
    ];
    final recommendations = [
      AppStrings.healthyRecommendation,
      AppStrings.manchaNegraRecommendation,
      AppStrings.ronaRecommendation,
    ];
    final index = random.nextInt(3);
    final confidence = 0.75 + random.nextDouble() * 0.24;

    final result = DetectionResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: widget.imagePath,
      disease: diseases[index],
      confidence: confidence,
      description: recommendations[index],
      timestamp: DateTime.now(),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(result: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.processing),
        backgroundColor: AppColors.primary,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Imagen en miniatura
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 48),
              // Animación de carga
              RotationTransition(
                turns: _animationController,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.accent,
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: AppColors.white,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Texto de procesamiento
              const Text(
                AppStrings.processingImage,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.greyDark,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Barra de progreso
              Container(
                width: 200,
                child: const LinearProgressIndicator(
                  backgroundColor: AppColors.greyLight,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
