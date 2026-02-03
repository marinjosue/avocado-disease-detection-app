# Integración del Modelo de Machine Learning

## 1. Convertir tu modelo de .ckpt a TensorFlow Lite (.tflite)

Tu modelo actual está en formato `.ckpt` (checkpoint de TensorFlow). Para usarlo en Flutter, necesitas convertirlo a TensorFlow Lite.

### Pasos para la conversión:

```python
import tensorflow as tf

# 1. Cargar tu modelo desde el checkpoint
# (Asume que tienes la arquitectura del modelo definida)
model = tf.keras.models.load_model('tu_modelo.h5')  # o reconstruir desde .ckpt

# 2. Convertir a TensorFlow Lite
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

# 3. Guardar el modelo
with open('avocado_disease_model.tflite', 'wb') as f:
    f.write(tflite_model)
```

## 2. Agregar el modelo a tu proyecto Flutter

1. Copia el archivo `.tflite` a la carpeta `assets/models/`
2. El archivo `pubspec.yaml` ya está configurado para incluir esta carpeta

## 3. Instalar dependencias de TensorFlow Lite

Agrega al `pubspec.yaml`:

```yaml
dependencies:
  tflite_flutter: ^0.10.4
  tflite_flutter_helper: ^0.3.1
```

Luego ejecuta:
```bash
flutter pub get
```

## 4. Actualizar el DetectionService

Edita el archivo `lib/features/detection/data/services/detection_service.dart`:

```dart
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class DetectionService {
  static final DetectionService instance = DetectionService._init();
  
  Interpreter? _interpreter;
  bool _isModelLoaded = false;

  DetectionService._init();

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/models/avocado_disease_model.tflite',
      );
      _isModelLoaded = true;
      debugPrint('Model loaded successfully');
    } catch (e) {
      debugPrint('Error loading model: $e');
      _isModelLoaded = false;
      rethrow;
    }
  }

  Future<Map<String, dynamic>> _runInference(Uint8List imageData) async {
    if (_interpreter == null) {
      throw Exception('Model not loaded');
    }

    // Preparar input (ajusta según tu modelo)
    var input = imageData.buffer.asFloat32List().reshape([1, 224, 224, 3]);
    
    // Preparar output (3 clases: healthy, mancha_negra, rona)
    var output = List.filled(1 * 3, 0.0).reshape([1, 3]);
    
    // Ejecutar inferencia
    _interpreter!.run(input, output);
    
    // Procesar resultados
    final probabilities = output[0] as List<double>;
    final maxProb = probabilities.reduce((a, b) => a > b ? a : b);
    final maxIndex = probabilities.indexOf(maxProb);
    
    final diseaseTypes = ['healthy', 'mancha_negra', 'rona'];
    
    return {
      'diseaseType': diseaseTypes[maxIndex],
      'confidence': maxProb,
    };
  }

  void dispose() {
    _interpreter?.close();
    _isModelLoaded = false;
  }
}
```

## 5. Configuración del modelo

### Parámetros importantes a ajustar según tu modelo:

- **Tamaño de entrada**: El código asume 224x224, ajusta si tu modelo usa otro tamaño
- **Normalización**: Actualmente normaliza a [0, 1], ajusta si tu modelo requiere [-1, 1] o ImageNet normalization
- **Número de clases**: Configurado para 3 clases (healthy, mancha_negra, rona)
- **Orden de clases**: Asegúrate que coincida con el orden en que tu modelo fue entrenado

## 6. Permisos necesarios

### Android (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

### iOS (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>Necesitamos acceso a la cámara para detectar enfermedades</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Necesitamos acceso a la galería para analizar imágenes</string>
```

## 7. Probar la aplicación

```bash
# Limpiar y obtener dependencias
flutter clean
flutter pub get

# Ejecutar en dispositivo/emulador
flutter run
```

## 8. Optimizaciones adicionales (opcional)

### Para mejor rendimiento:

1. **Cuantización del modelo**:
```python
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
```

2. **GPU Delegate** (para dispositivos compatibles):
```dart
final gpuDelegateV2 = GpuDelegateV2();
final options = InterpreterOptions()..addDelegate(gpuDelegateV2);
_interpreter = await Interpreter.fromAsset(
  'assets/models/avocado_disease_model.tflite',
  options: options,
);
```

## Notas importantes

- El servicio actual usa un modelo mock para que puedas probar la aplicación
- Una vez integres tu modelo real, reemplaza la función `_runInference()`
- Asegúrate de que las clases de salida coincidan con los valores en `DetectionResult`
- Prueba primero con imágenes de validación para verificar la precisión
