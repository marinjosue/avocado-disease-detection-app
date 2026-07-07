import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import '../../../../core/models/detection_result.dart';

/// Service for detecting avocado diseases using ML model
class DetectionService {
  static final DetectionService instance = DetectionService._init();

  bool _isModelLoaded = false;
  // Interpreter? _interpreter;

  DetectionService._init();

  /// Initialize the ML model
  Future<void> loadModel() async {
    try {
      // Example:
      // _interpreter = await Interpreter.fromAsset('assets/models/avocado_disease_model.tflite');

      _isModelLoaded = true;
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Error loading model: $e');
      _isModelLoaded = false;
      rethrow;
    }
  }

  /// Detect disease in avocado image
  Future<DetectionResult> detectDisease(String imagePath) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    try {
      // Load and preprocess image
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Unable to decode image');
      }

      // Preprocess image for model
      final preprocessedImage = _preprocessImage(image);

      // For now, using mock detection
      final prediction = await _runInference(preprocessedImage);

      // Create detection result
      final result = DetectionResult(
        diseaseType: prediction['diseaseType'],
        confidence: prediction['confidence'],
        imagePath: imagePath,
        timestamp: DateTime.now(),
        workspaceId: 'default',
      );

      return result;
    } catch (e) {
      debugPrint('Error detecting disease: $e');
      rethrow;
    }
  }

  /// Preprocess image for model input
  /// Adjust size and normalization according to your model requirements
  Uint8List _preprocessImage(img.Image image) {
    // Resize image to model input size (example: 224x224)
    final resizedImage = img.copyResize(
      image,
      width: 224,
      height: 224,
      interpolation: img.Interpolation.linear,
    );

    // Convert to normalized float values
    final imageData = Float32List(224 * 224 * 3);
    int pixelIndex = 0;

    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);

        // Normalize RGB values to [0, 1] or [-1, 1] based on your model
        imageData[pixelIndex++] = pixel.r / 255.0;
        imageData[pixelIndex++] = pixel.g / 255.0;
        imageData[pixelIndex++] = pixel.b / 255.0;
      }
    }

    return imageData.buffer.asUint8List();
  }

  Future<Map<String, dynamic>> _runInference(Uint8List imageData) async {
    // Example with TFLite:
    // var input = imageData.reshape([1, 224, 224, 3]);
    // var output = List.filled(1 * 3, 0).reshape([1, 3]);
    // _interpreter.run(input, output);

    // Mock prediction for demonstration
    await Future.delayed(
      const Duration(seconds: 1),
    ); // Simulate processing time

    // Simulate random prediction
    final predictions = [
      {'diseaseType': 'healthy', 'confidence': 0.95},
      {'diseaseType': 'mancha_negra', 'confidence': 0.87},
      {'diseaseType': 'rona', 'confidence': 0.82},
    ];

    // Return random prediction (replace with actual model output)
    predictions.shuffle();
    return predictions.first;
  }

  /// Dispose resources
  void dispose() {
    // _interpreter?.close();
    _isModelLoaded = false;
  }

  bool get isModelLoaded => _isModelLoaded;
}
