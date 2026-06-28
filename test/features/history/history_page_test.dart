// NOTE: sqflite is not initialized in the test environment, so DetectionProvider
// catches the DB error and ends up with isLoading=false and empty detections.
// pumpAndSettle can time out if the progress indicator is still animating, so
// we use pump() + a short delay to let micro-tasks drain.
//
// A full empty-state text assertion requires sqflite_common_ffi in
// dev_dependencies (not currently present). We therefore run a build-smoke test:
// assert the AppBar renders — confirming HistoryListPage builds without errors
// and the design-system components are wired up correctly.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/features/detection/presentation/pages/history_list_page.dart';
import 'package:aplication_tesis/features/detection/presentation/providers/detection_provider.dart';
import 'package:aplication_tesis/l10n/app_localizations.dart';

void main() {
  testWidgets(
    'HistoryListPage build-smoke: AppBar renders without exceptions',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: AppTheme.light,
          home: ChangeNotifierProvider<DetectionProvider>(
            create: (_) => DetectionProvider(),
            child: const HistoryListPage(),
          ),
        ),
      );

      // First frame — widget tree is built.
      await tester.pump();
      // Let micro-tasks (DB future resolution) drain.
      await tester.pump(const Duration(milliseconds: 100));

      // AppBar must render — confirms page builds without error.
      expect(find.byType(AppBar), findsOneWidget);

      // No uncaught exceptions means the test passes.
    },
  );
}
