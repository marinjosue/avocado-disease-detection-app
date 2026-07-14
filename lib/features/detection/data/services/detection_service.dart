import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../../../core/models/detection_result.dart';

/// Service for detecting avocado diseases using the on-device CNN.
///
/// Model: MobileNetV2 (transfer learning) exported to TensorFlow Lite.
/// Input : [1, 224, 224, 3] float32, RGB scaled to [0, 1]
/// Output: [1, 3] float32 softmax probabilities.
class DetectionService {
  static final DetectionService instance = DetectionService._init();

  static const String _modelAsset = 'assets/models/avocado_disease_model.tflite';
  static const int _inputSize = 224;

  /// Output index -> disease key, taken verbatim from the training notebook:
  /// `Indices de clase: {'mancha_negra': 0, 'ronia': 1, 'sana': 2}`.
  /// The notebook's 'ronia'/'sana' map to the app's 'rona'/'healthy' keys.
  /// This order is NOT alphabetical in the app's terms — do not "fix" it.
  static const List<String> _labels = ['mancha_negra', 'rona', 'healthy'];

  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  DetectionService._init();

  /// Initialize the ML model
  Future<void> loadModel() async {
    if (_isModelLoaded) return;

    try {
      _interpreter = await Interpreter.fromAsset(_modelAsset);
      _isModelLoaded = true;

      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      debugPrint('Model loaded — input: $inputShape, output: $outputShape');
    } catch (e) {
      debugPrint('Error loading model: $e');
      _interpreter = null;
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
      final imageFile = File(imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final decoded = img.decodeImage(imageBytes);

      if (decoded == null) {
        throw Exception('Unable to decode image');
      }

      // Photos from the camera carry EXIF rotation; apply it so the model sees
      // the picture the way the user framed it.
      final image = img.bakeOrientation(decoded);

      final input = _preprocessImage(image);
      final prediction = _runInference(input);

      return DetectionResult(
        diseaseType: prediction['diseaseType'] as String,
        confidence: prediction['confidence'] as double,
        imagePath: imagePath,
        timestamp: DateTime.now(),
        workspaceId: 'default',
      );
    } catch (e) {
      debugPrint('Error detecting disease: $e');
      rethrow;
    }
  }

  /// Resize to 224x224 and scale RGB to [0, 1].
  ///
  /// Matches the training pipeline exactly:
  /// `ImageDataGenerator(rescale=1./255)` with `target_size=(224, 224)`.
  Float32List _preprocessImage(img.Image image) {
    final resized = img.copyResize(
      image,
      width: _inputSize,
      height: _inputSize,
      interpolation: img.Interpolation.linear,
    );

    final imageData = Float32List(_inputSize * _inputSize * 3);
    int i = 0;

    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        imageData[i++] = pixel.r / 255.0;
        imageData[i++] = pixel.g / 255.0;
        imageData[i++] = pixel.b / 255.0;
      }
    }

    return imageData;
  }

  Map<String, dynamic> _runInference(Float32List input) {
    final interpreter = _interpreter;
    if (interpreter == null) {
      throw Exception('Model not loaded');
    }

    final output = List.generate(1, (_) => List<double>.filled(_labels.length, 0.0));

    interpreter.run(
      input.reshape([1, _inputSize, _inputSize, 3]),
      output,
    );

    final probabilities = output.first;

    var bestIndex = 0;
    for (int i = 1; i < probabilities.length; i++) {
      if (probabilities[i] > probabilities[bestIndex]) {
        bestIndex = i;
      }
    }

    debugPrint(
      'Inference — ${[
        for (int i = 0; i < _labels.length; i++)
          '${_labels[i]}: ${(probabilities[i] * 100).toStringAsFixed(1)}%',
      ].join(', ')}',
    );

    return {
      'diseaseType': _labels[bestIndex],
      'confidence': probabilities[bestIndex],
    };
  }

  /// Dispose resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isModelLoaded = false;
  }

  bool get isModelLoaded => _isModelLoaded;
}
