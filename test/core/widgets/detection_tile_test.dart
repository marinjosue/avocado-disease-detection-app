// test/core/widgets/detection_tile_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/models/detection_result.dart';
import 'package:aplication_tesis/core/widgets/detection_tile.dart';

void main() {
  testWidgets('DetectionTile muestra nombre, confianza y tiempo; onTap funciona', (tester) async {
    var tapped = false;
    final r = DetectionResult(
      diseaseType: 'rona', confidence: 0.87, imagePath: '/no/existe.jpg', timestamp: DateTime(2026, 6, 24),
    );
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: DetectionTile(result: r, diseaseName: 'Roña', timeLabel: 'Hace 2 h', onTap: () => tapped = true),
      ),
    ));
    expect(find.text('Roña'), findsWidgets);
    expect(find.text('87%'), findsOneWidget);
    expect(find.text('Hace 2 h'), findsOneWidget);
    await tester.tap(find.byType(InkWell).first);
    expect(tapped, true);
  });
}
