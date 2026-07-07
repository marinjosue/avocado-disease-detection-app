import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/theme/disease_colors.dart';
import '../../../assistant/presentation/pages/ai_gate.dart';
import '../../../assistant/presentation/pages/conversations_list_page.dart';
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

    // Pages list — rebuilt each build so l10n is current.
    final pages = [
      const DashboardPage(),
      const CalculatorPage(),
      const AiGate(child: ConversationsListPage()),
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

    // Bottom bar: 6 evenly-sized destinations with the Camera highlighted
    // (icon inside a green circle). Index map: 0 Panel · 1 Calc · 2 Assistant ·
    // 3 Camera · 4 History · 5 Settings.
    final bottomBar = Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.dashboard),
            label: dashboardLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calculate),
            label: calculatorLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.smart_toy),
            label: assistantLabel,
          ),
          BottomNavigationBarItem(
            // Highlighted Camera (the primary action).
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(Icons.camera_alt, color: colorScheme.onPrimary, size: 22),
            ),
            label: cameraLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.history),
            label: historyLabel,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
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
    );
  }
}
