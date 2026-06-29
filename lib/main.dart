import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gemma/flutter_gemma.dart';

import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/onboarding_service.dart';
import 'features/main/presentation/pages/main_page.dart';
import 'features/onboarding/presentation/pages/onboarding_page.dart';
import 'features/detection/presentation/providers/detection_provider.dart';
import 'features/assistant/data/assistant_service_router.dart';
import 'features/assistant/presentation/providers/assistant_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Registra los engines de IA on-device (Fase 2B). El token de HuggingFace
  // se configura en la app antes de descargar el modelo.
  FlutterGemma.initialize();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const AvoScanApp());
}

class AvoScanApp extends StatelessWidget {
  const AvoScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => DetectionProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) => AssistantProvider(AssistantServiceRouter()),
        ),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'avocadoIA',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const _OnboardingBootstrap(),
              '/main': (context) => const MainPage(),
            },
          );
        },
      ),
    );
  }
}

/// Bootstrap widget for the `'/'` route.
///
/// Checks [OnboardingService.hasSeen()] and routes accordingly:
/// - loading  → themed [CircularProgressIndicator]
/// - not seen → [OnboardingPage] (navigates to `/main` on finish)
/// - seen     → [MainPage] directly
class _OnboardingBootstrap extends StatefulWidget {
  const _OnboardingBootstrap();

  @override
  State<_OnboardingBootstrap> createState() => _OnboardingBootstrapState();
}

class _OnboardingBootstrapState extends State<_OnboardingBootstrap> {
  late final Future<bool> _future;

  @override
  void initState() {
    super.initState();
    _future = OnboardingService().hasSeen();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        if (snapshot.data == true) {
          return const MainPage();
        }
        return OnboardingPage(
          onFinish: () =>
              Navigator.of(context).pushReplacementNamed('/main'),
        );
      },
    );
  }
}
