# Integración del Modelo de Machine Learning

**Estado: integrado y funcionando.** Este documento describe cómo quedó conectado el
modelo real, no cómo conectarlo. Si reentrenas el modelo, lee la sección
"Si reentrenas" al final: hay un detalle que rompe la app en silencio.

## 1. El modelo

Entrenado en [Entrenamiento_Aguacate_final.ipynb](https://drive.google.com/) (Colab),
MobileNetV2 con transfer learning + fine-tuning:

| | |
|---|---|
| Archivo | `assets/models/avocado_disease_model.tflite` (3.16 MB) |
| Arquitectura | MobileNetV2 (base ImageNet congelada, luego fine-tuning desde la capa 100) |
| Entrada | `[1, 224, 224, 3]` float32, RGB escalado a **[0, 1]** |
| Salida | `[1, 3]` float32, probabilidades softmax (suman 1) |
| Cuantización | Dinámica (`tf.lite.Optimize.DEFAULT`); pesos int8, E/S float32 |
| Dataset | 2 999 imágenes (≈1 000 por clase), split estratificado 70/15/15 |
| Exactitud (test, Keras) | 96.23 % |
| Exactitud (test, TFLite) | 96.01 % |

## 2. El orden de las clases (lee esto)

El notebook fija el orden con `CLASS_NAMES = ["mancha_negra", "ronia", "sana"]`, lo que
produce `class_indices = {'mancha_negra': 0, 'ronia': 1, 'sana': 2}`.

La app usa otras claves (`'healthy'`, `'mancha_negra'`, `'rona'`), así que el mapeo
índice → clave **no** es el orden "natural" que uno escribiría:

```dart
// lib/features/detection/data/services/detection_service.dart
static const List<String> _labels = ['mancha_negra', 'rona', 'healthy'];
//                                     ^index 0        ^1      ^2
```

Si se usara el orden alfabético/intuitivo `['healthy', 'mancha_negra', 'rona']`, el
modelo seguiría funcionando sin lanzar ningún error, pero **acertaría el 1.7 % de las
veces** en lugar del 98 %: llamaría "sano" a un fruto con mancha negra. Verificado
ejecutando el `.tflite` sobre 120 imágenes reales del dataset.

## 3. Preprocesamiento

`DetectionService._preprocessImage()` replica exactamente lo que hizo
`ImageDataGenerator(rescale=1./255)` con `target_size=(224, 224)`:

1. `img.bakeOrientation()` — aplica la rotación EXIF de las fotos de cámara.
2. `img.copyResize(224, 224, interpolation: linear)`.
3. Cada canal RGB dividido entre 255 → `Float32List` de 224×224×3.

No uses `mobilenet_v2.preprocess_input` ([-1, 1]): el modelo **no** se entrenó así.
Medido sobre el dataset, [-1, 1] baja la exactitud del 98 % al 92 %.

## 4. Dependencia y build

```yaml
tflite_flutter: ^0.12.0   # usa LiteRT 1.4.0 (com.google.ai.edge.litert)
```

`tflite_flutter` 0.12.1 declara Java 11 en su `compileOptions` pero no fija
`kotlinOptions.jvmTarget`, así que bajo el Kotlin integrado de Flutter sus tareas de
Kotlin heredan el JDK por defecto (21) y Gradle aborta el build por desajuste de
target. [android/build.gradle.kts](android/build.gradle.kts) fija el target de Kotlin
de ese módulo a 11. Sin ese bloque, `flutter build apk` falla.

### Google Play — páginas de 16 KB

Las librerías nativas que aporta LiteRT (`libtensorflowlite_jni.so`,
`libtensorflowlite_gpu_jni.so`) están alineadas a 16 KB en las tres ABI. Verificado
leyendo los segmentos `LOAD` del ELF dentro del APK release: las 32 librerías
empaquetadas cumplen. No hace falta excluir nada nuevo.

## 5. Verificación en el dispositivo

[integration_test/detection_model_test.dart](integration_test/detection_model_test.dart)
ejecuta el modelo **en el teléfono** sobre imágenes con diagnóstico conocido y falla si
el mapeo de clases se rompe. Las imágenes se nombran con su clase real como prefijo
(`mancha_negra_0.jpg`, `rona_0.jpg`, `healthy_0.jpg`):

```bash
adb push <imagenes> /sdcard/Android/data/com.example.aplication_tesis/files/test_images/
flutter test integration_test/detection_model_test.dart -d <device-id>
```

Resultado en un Pixel 8 (Android 17) con 30 imágenes, 10 por clase:

```
healthy:      10/10
mancha_negra:  9/10
rona:         10/10
EXACTITUD GLOBAL: 29/30 (96.7%)
```

Coincide con el 96.23 % del conjunto de prueba del notebook, así que la app en el
dispositivo reproduce el rendimiento medido en Colab.

## 6. Si reentrenas el modelo

Antes de reemplazar el `.tflite`, comprueba estos tres puntos — cambiar cualquiera sin
tocar el código Dart produce predicciones incorrectas **sin ningún error visible**:

1. **`print(train_generator.class_indices)`** → si el orden cambia, actualiza
   `DetectionService._labels`.
2. **La normalización** → si dejas de usar `rescale=1./255`, actualiza
   `_preprocessImage()`.
3. **El tamaño de entrada** → si no es 224×224, actualiza `_inputSize`.

La forma de entrada/salida real siempre se puede leer en tiempo de ejecución:
`loadModel()` imprime `input:` y `output:` en el log al arrancar.
