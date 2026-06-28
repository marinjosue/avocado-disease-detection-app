import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/theme/disease_colors.dart';
import '../../../assistant/presentation/pages/chat_page.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../calculator/presentation/pages/calculator_page.dart';
import '../../../detection/presentation/pages/camera_page.dart';
import '../../../detection/presentation/pages/history_list_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Page indices:
  //   0 → Dashboard  1 → Calculator  2 → Assistant
  //   3 → Camera     4 → History     5 → Settings
  int _currentIndex = 0;
  bool _offlineDismissed = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final diseaseColors = Theme.of(context).extension<DiseaseColors>();

    // Labels — short for the bottom bar.
    final dashboardLabel = l10n?.navDashboard ?? 'Panel';
    final calculatorLabel = l10n?.navCalculator ?? 'Calc.';
    final assistantLabel = l10n?.navAssistant ?? 'Asistente';
    final cameraLabel = l10n?.camera ?? 'Cámara';
    final historyLabel = l10n?.history ?? 'Historial';
    final settingsLabel = l10n?.navSettings ?? 'Ajustes';
    final offlineModeText = l10n?.offlineMode ?? 'Offline mode - Using local model';

    // Warning color for offline banner.
    final warningColor = diseaseColors?.rona ?? colorScheme.secondary;

    // Build pages here (in build) so we can pass l10n to ChatPage.
    final pages = [
      const DashboardPage(),
      const CalculatorPage(),
      ChatPage(greeting: l10n?.assistantGeneralGreeting),
      const CameraPage(),
      const HistoryListPage(),
      const SettingsPage(),
    ];

    // Reset offline-dismissed state when connectivity is restored.
    if (connectivityProvider.isOnline && _offlineDismissed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _offlineDismissed = false);
      });
    }

    // Helper: bar item selected state.
    // Bar items map to page indices [0, 1, 2, 4, 5]; camera (3) is the FAB.
    Widget barItem({
      required int pageIndex,
      required IconData icon,
      required String label,
    }) {
      final selected = _currentIndex == pageIndex;
      final color = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;
      return Expanded(
        child: InkWell(
          onTap: () => setState(() => _currentIndex = pageIndex),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: selected ? 26 : 22),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.normal,
                      ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bottomBar = BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 6,
      child: Row(
        children: [
          // Left side: Dashboard, Calculator, Assistant
          barItem(
            pageIndex: 0,
            icon: Icons.dashboard,
            label: dashboardLabel,
          ),
          barItem(
            pageIndex: 1,
            icon: Icons.calculate,
            label: calculatorLabel,
          ),
          barItem(
            pageIndex: 2,
            icon: Icons.smart_toy,
            label: assistantLabel,
          ),
          // Gap for the FAB notch
          const SizedBox(width: 56),
          // Right side: History, Settings
          barItem(
            pageIndex: 4,
            icon: Icons.history,
            label: historyLabel,
          ),
          barItem(
            pageIndex: 5,
            icon: Icons.settings,
            label: settingsLabel,
          ),
        ],
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          pages[_currentIndex],

          // Offline Banner (with close button).
          if (!connectivityProvider.isOnline && !_offlineDismissed)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Material(
                  color: warningColor,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4, bottom: 4),
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off,
                            color: colorScheme.onPrimary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            offlineModeText,
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close,
                              color: colorScheme.onPrimary, size: 18),
                          tooltip: l10n?.close ?? 'Cerrar',
                          visualDensity: VisualDensity.compact,
                          onPressed: () =>
                              setState(() => _offlineDismissed = true),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: bottomBar,
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _currentIndex = 3),
        tooltip: cameraLabel,
        backgroundColor: _currentIndex == 3
            ? colorScheme.primary
            : colorScheme.primaryContainer,
        foregroundColor: _currentIndex == 3
            ? colorScheme.onPrimary
            : colorScheme.onPrimaryContainer,
        elevation: _currentIndex == 3 ? 6 : 4,
        child: const Icon(Icons.camera_alt, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
