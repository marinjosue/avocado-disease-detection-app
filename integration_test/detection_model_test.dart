// Ejecuta el CNN real EN EL DISPOSITIVO sobre imágenes con diagnóstico conocido.
//
// Verifica lo único que el modelo no puede decirnos por sí solo: que el índice de
// salida se traduce a la clase correcta. Si `DetectionService._labels` se reordena,
// este test falla — que es exactamente lo que debe pasar.
//
// Uso:
//   adb push <imagenes> /sdcard/Android/data/com.example.aplication_tesis/files/test_images/
//   flutter test integration_test/detection_model_test.dart -d <device-id>
//
// Las imágenes deben nombrarse con su clase real como prefijo:
//   healthy_*.jpg   mancha_negra_*.jpg   rona_*.jpg

import 'dart:io';

import 'package:aplication_tesis/features/detection/data/services/detection_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final service = DetectionService.instance;

  test('el modelo carga en el dispositivo', () async {
    await service.loadModel();
    expect(service.isModelLoaded, isTrue);
  });

  test('clasifica correctamente las tres clases', () async {
    final root = await getExternalStorageDirectory();
    final dir = Directory(p.join(root!.path, 'test_images'));
    expect(
      dir.existsSync(),
      isTrue,
      reason: 'Sube las imágenes de prueba a ${dir.path}',
    );

    final images = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.jpg'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    expect(images, isNotEmpty, reason: 'No hay imágenes de prueba');

    final hits = <String, int>{};
    final total = <String, int>{};

    for (final image in images) {
      final name = p.basename(image.path);
      final expected = name.startsWith('mancha_negra')
          ? 'mancha_negra'
          : name.startsWith('rona')
              ? 'rona'
              : 'healthy';

      final result = await service.detectDisease(image.path);

      total[expected] = (total[expected] ?? 0) + 1;
      if (result.diseaseType == expected) {
        hits[expected] = (hits[expected] ?? 0) + 1;
      }

      // ignore: avoid_print
      print(
        '$name -> ${result.diseaseType} '
        '(${(result.confidence * 100).toStringAsFixed(1)}%) '
        '${result.diseaseType == expected ? 'OK' : 'FALLO (esperado $expected)'}',
      );
    }

    var aciertos = 0;
    for (final clase in total.keys) {
      final ok = hits[clase] ?? 0;
      aciertos += ok;
      // ignore: avoid_print
      print('$clase: $ok/${total[clase]}');
      // Cada clase debe acertar la mayoría. Un mapeo mal ordenado da 0 aquí.
      expect(
        ok / total[clase]!,
        greaterThan(0.5),
        reason: 'La clase $clase falla más de la mitad — revisa '
            'DetectionService._labels contra class_indices del notebook',
      );
    }

    final exactitud = aciertos / images.length;
    // ignore: avoid_print
    print('EXACTITUD GLOBAL: $aciertos/${images.length} '
        '(${(exactitud * 100).toStringAsFixed(1)}%)');
    expect(exactitud, greaterThan(0.85));
  });
}
