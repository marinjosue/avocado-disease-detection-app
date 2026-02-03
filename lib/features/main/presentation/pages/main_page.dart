import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../calculator/presentation/pages/calculator_page.dart';
import '../../../detection/presentation/pages/camera_page.dart';
import '../../../detection/presentation/pages/history_list_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    CalculatorPage(),
    CameraPage(),
    HistoryListPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);

    // Valores por defecto si las localizaciones no están disponibles
    final dashboardLabel = l10n?.dashboard ?? 'Dashboard';
    final calculatorLabel = l10n?.calculator ?? 'Calculator';
    final cameraLabel = l10n?.camera ?? 'Camera';
    final historyLabel = l10n?.history ?? 'History';
    final settingsLabel = l10n?.settings ?? 'Settings';
    final offlineModeText = l10n?.offlineMode ?? 'Offline mode - Using local model';

    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          
          // Offline Banner
          if (!connectivityProvider.isOnline)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.orange[700],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.cloud_off, color: Colors.white, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        offlineModeText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF2E7D32),
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          backgroundColor: Colors.white,
          elevation: 0,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.dashboard),
              activeIcon: const Icon(Icons.dashboard, size: 28),
              label: dashboardLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.calculate),
              activeIcon: const Icon(Icons.calculate, size: 28),
              label: calculatorLabel,
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2E7D32).withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 24),
              ),
              label: cameraLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              activeIcon: const Icon(Icons.history, size: 28),
              label: historyLabel,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings),
              activeIcon: const Icon(Icons.settings, size: 28),
              label: settingsLabel,
            ),
          ],
        ),
      ),
    );
  }
}
