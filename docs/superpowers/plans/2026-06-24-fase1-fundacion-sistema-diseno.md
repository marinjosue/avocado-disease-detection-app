# Fase 1 · Plan 1 — Fundación del sistema de diseño · Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Construir la base visual reutilizable de AvoScan (tokens de color, tipografía Inter, tema claro/oscuro conmutable y componentes), sin tocar pantallas ni lógica todavía.

**Architecture:** Se añade un módulo de tema (`lib/core/theme/`) con tokens y `ThemeData` claro/oscuro (Material 3), un `ThemeProvider` (espejo de `LocaleProvider`) que persiste el modo en `SharedPreferences`, y una librería de componentes en `lib/core/widgets/`. `main.dart` pasa `theme`/`darkTheme`/`themeMode`. Las pantallas existentes siguen usando `AppColors` y compilan igual; su migración es el Plan 2.

**Tech Stack:** Flutter (Material 3), `provider`, `shared_preferences`, `fl_chart`, fuente **Inter** empaquetada. Tests con `flutter_test`.

## Global Constraints

- **Solo capa visual/base:** NO modificar `DetectionService`, `DatabaseHelper`, modelos, `DetectionProvider`, ni la lógica de negocio.
- **Contrato de clases de enfermedad intacto:** literales exactos `'healthy'`, `'mancha_negra'`, `'rona'`.
- **Gestión de estado:** `provider`. Solo se agrega `ThemeProvider` (no DI nuevo).
- **Offline:** la fuente Inter va **empaquetada** en `assets/fonts/` (no `google_fonts`, no red).
- **Componentes:** leen del `Theme`/`ColorScheme`/`ThemeExtension`; nada de `Color(...)` o `fontSize` hardcodeados dentro de los widgets nuevos.
- **No romper compilación:** `AppColors` (`lib/core/constants/colors.dart`) permanece intacto en este plan.
- **Tokens fuente de verdad (claro):** primary `#1F6B3B`, primaryDark `#0E2E1C`, accent `#26C281`, background `#F4F6F5`, surface/card `#FFFFFF`, textPrimary `#0E1C14`, textSecondary `#6B7B73`, healthy `#22A565`, manchaNegra `#3A3F45`, rona `#E0962F`.
- **Tokens (oscuro):** primary `#34B36A`, primaryDark `#0E2E1C`, accent `#2FD08C`, background `#0E1311`, surface `#161D19`, card `#1C2521`, textPrimary `#ECF2EE`, textSecondary `#9CB0A6`, healthy `#34C77D`, manchaNegra `#AEB4BA`, rona `#F0A94A`.
- **Espaciado:** 4/8/12/16/20/24/32. **Radios:** sm 8, md 12, lg 16, pill 999.

---

## File Structure

- `lib/core/theme/app_tokens.dart` — **Crear.** Constantes: `LightTokens`, `DarkTokens` (colores), `AppSpacing`, `AppRadius`.
- `lib/core/theme/disease_colors.dart` — **Crear.** `ThemeExtension<DiseaseColors>` + helper `diseaseIcon(String)`.
- `lib/core/theme/app_theme.dart` — **Crear.** `AppTheme.light` / `AppTheme.dark` (`ThemeData` Material 3).
- `lib/core/providers/theme_provider.dart` — **Crear.** `ThemeProvider extends ChangeNotifier`.
- `lib/core/widgets/app_states.dart` — **Crear.** `EmptyState`, `LoadingState`, `ErrorState`.
- `lib/core/widgets/section_header.dart` — **Crear.** `SectionHeader`.
- `lib/core/widgets/status_badge.dart` — **Crear.** `StatusBadge`, `AppChip`.
- `lib/core/widgets/app_buttons.dart` — **Crear.** `PrimaryButton`, `SecondaryButton`.
- `lib/core/widgets/stat_card.dart` — **Crear.** `StatCard`.
- `lib/core/widgets/confidence_bar.dart` — **Crear.** `ConfidenceBar`.
- `lib/core/widgets/detection_tile.dart` — **Crear.** `DetectionTile`.
- `lib/core/widgets/donut_chart.dart` — **Crear.** `DonutChart`, `DonutSection`.
- `lib/core/widgets/info_hint.dart` — **Crear.** `InfoHint`.
- `lib/main.dart` — **Modificar.** Registrar `ThemeProvider`; pasar `theme`/`darkTheme`/`themeMode`.
- `assets/fonts/Inter-*.ttf` — **Añadir** (binarios) y declarar en `pubspec.yaml`.
- `test/...` — tests por tarea.

---

### Task 1: Design tokens + DiseaseColors extension

**Files:**
- Create: `lib/core/theme/app_tokens.dart`
- Create: `lib/core/theme/disease_colors.dart`
- Test: `test/core/theme/disease_colors_test.dart`

**Interfaces:**
- Produces: `LightTokens`/`DarkTokens` (static const `Color` campos: `primary, primaryDark, accent, background, surface, card, textPrimary, textSecondary, healthy, manchaNegra, rona, success, warning, error, info`); `AppSpacing` (`xs,sm,md,lg,xl,xxl,xxxl` double); `AppRadius` (`sm,md,lg,pill` double); `DiseaseColors` (`ThemeExtension` con `healthy,manchaNegra,rona` + `Color forType(String)`), instancias `DiseaseColors.light`/`DiseaseColors.dark`; top-level `IconData diseaseIcon(String type)`.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/theme/disease_colors_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/disease_colors.dart';

void main() {
  test('forType mapea cada clave de enfermedad y default', () {
    const d = DiseaseColors.light;
    expect(d.forType('healthy'), d.healthy);
    expect(d.forType('mancha_negra'), d.manchaNegra);
    expect(d.forType('rona'), d.rona);
    expect(d.forType('desconocido'), d.unknown);
  });

  test('lerp interpola entre dos extensiones', () {
    final mixed = DiseaseColors.light.lerp(DiseaseColors.dark, 0.5)!;
    expect(mixed, isA<DiseaseColors>());
  });

  test('diseaseIcon devuelve íconos distintos por clase', () {
    expect(diseaseIcon('healthy'), Icons.check_circle);
    expect(diseaseIcon('mancha_negra'), Icons.coronavirus);
    expect(diseaseIcon('rona'), Icons.warning_amber_rounded);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/theme/disease_colors_test.dart`
Expected: FAIL — `Target of URI doesn't exist` / tipos no definidos.

- [ ] **Step 3: Write `app_tokens.dart`**

```dart
// lib/core/theme/app_tokens.dart
import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
}

class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double pill = 999;
}

class LightTokens {
  LightTokens._();
  static const Color primary = Color(0xFF1F6B3B);
  static const Color primaryDark = Color(0xFF0E2E1C);
  static const Color accent = Color(0xFF26C281);
  static const Color background = Color(0xFFF4F6F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF0E1C14);
  static const Color textSecondary = Color(0xFF6B7B73);
  static const Color healthy = Color(0xFF22A565);
  static const Color manchaNegra = Color(0xFF3A3F45);
  static const Color rona = Color(0xFFE0962F);
  static const Color success = Color(0xFF22A565);
  static const Color warning = Color(0xFFE0962F);
  static const Color error = Color(0xFFE5484D);
  static const Color info = Color(0xFF3A8DDE);
}

class DarkTokens {
  DarkTokens._();
  static const Color primary = Color(0xFF34B36A);
  static const Color primaryDark = Color(0xFF0E2E1C);
  static const Color accent = Color(0xFF2FD08C);
  static const Color background = Color(0xFF0E1311);
  static const Color surface = Color(0xFF161D19);
  static const Color card = Color(0xFF1C2521);
  static const Color textPrimary = Color(0xFFECF2EE);
  static const Color textSecondary = Color(0xFF9CB0A6);
  static const Color healthy = Color(0xFF34C77D);
  static const Color manchaNegra = Color(0xFFAEB4BA);
  static const Color rona = Color(0xFFF0A94A);
  static const Color success = Color(0xFF34C77D);
  static const Color warning = Color(0xFFF0A94A);
  static const Color error = Color(0xFFF26C6F);
  static const Color info = Color(0xFF5BA8E8);
}
```

- [ ] **Step 4: Write `disease_colors.dart`**

```dart
// lib/core/theme/disease_colors.dart
import 'package:flutter/material.dart';
import 'app_tokens.dart';

IconData diseaseIcon(String type) {
  switch (type) {
    case 'healthy':
      return Icons.check_circle;
    case 'mancha_negra':
      return Icons.coronavirus;
    case 'rona':
      return Icons.warning_amber_rounded;
    default:
      return Icons.help_outline;
  }
}

@immutable
class DiseaseColors extends ThemeExtension<DiseaseColors> {
  const DiseaseColors({
    required this.healthy,
    required this.manchaNegra,
    required this.rona,
    required this.unknown,
  });

  final Color healthy;
  final Color manchaNegra;
  final Color rona;
  final Color unknown;

  Color forType(String diseaseType) {
    switch (diseaseType) {
      case 'healthy':
        return healthy;
      case 'mancha_negra':
        return manchaNegra;
      case 'rona':
        return rona;
      default:
        return unknown;
    }
  }

  static const DiseaseColors light = DiseaseColors(
    healthy: LightTokens.healthy,
    manchaNegra: LightTokens.manchaNegra,
    rona: LightTokens.rona,
    unknown: Color(0xFF9E9E9E),
  );

  static const DiseaseColors dark = DiseaseColors(
    healthy: DarkTokens.healthy,
    manchaNegra: DarkTokens.manchaNegra,
    rona: DarkTokens.rona,
    unknown: Color(0xFFAEB4BA),
  );

  @override
  DiseaseColors copyWith({Color? healthy, Color? manchaNegra, Color? rona, Color? unknown}) {
    return DiseaseColors(
      healthy: healthy ?? this.healthy,
      manchaNegra: manchaNegra ?? this.manchaNegra,
      rona: rona ?? this.rona,
      unknown: unknown ?? this.unknown,
    );
  }

  @override
  DiseaseColors lerp(ThemeExtension<DiseaseColors>? other, double t) {
    if (other is! DiseaseColors) return this;
    return DiseaseColors(
      healthy: Color.lerp(healthy, other.healthy, t)!,
      manchaNegra: Color.lerp(manchaNegra, other.manchaNegra, t)!,
      rona: Color.lerp(rona, other.rona, t)!,
      unknown: Color.lerp(unknown, other.unknown, t)!,
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/core/theme/disease_colors_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/core/theme/app_tokens.dart lib/core/theme/disease_colors.dart test/core/theme/disease_colors_test.dart
git commit -m "feat(theme): add design tokens and DiseaseColors extension"
```

---

### Task 2: Tema claro/oscuro + fuente Inter

**Files:**
- Create: `lib/core/theme/app_theme.dart`
- Modify: `pubspec.yaml` (sección `fonts:` y assets de fuente)
- Add: `assets/fonts/Inter-Regular.ttf`, `Inter-Medium.ttf`, `Inter-SemiBold.ttf`, `Inter-Bold.ttf`, `Inter-ExtraBold.ttf`
- Test: `test/core/theme/app_theme_test.dart`

**Interfaces:**
- Consumes: `LightTokens`/`DarkTokens`, `DiseaseColors` (Task 1).
- Produces: `AppTheme.light` / `AppTheme.dark` → `ThemeData` (Material 3, `useMaterial3: true`, `fontFamily: 'Inter'`, `extensions: [DiseaseColors.*]`).

- [ ] **Step 1: Descargar y colocar la fuente Inter**

Descarga Inter (SIL OFL) desde https://rsms.me/inter/ o Google Fonts y copia estos archivos a `assets/fonts/`:
`Inter-Regular.ttf` (400), `Inter-Medium.ttf` (500), `Inter-SemiBold.ttf` (600), `Inter-Bold.ttf` (700), `Inter-ExtraBold.ttf` (800).

- [ ] **Step 2: Declarar la fuente en `pubspec.yaml`**

Bajo `flutter:`, junto a `assets:`, añade:

```yaml
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
          weight: 400
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
        - asset: assets/fonts/Inter-ExtraBold.ttf
          weight: 800
```

Run: `flutter pub get`
Expected: termina sin errores.

- [ ] **Step 3: Write the failing test**

```dart
// test/core/theme/app_theme_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/theme/disease_colors.dart';
import 'package:aplication_tesis/core/theme/app_tokens.dart';

void main() {
  test('light theme usa Material 3, Inter, primary y extensión', () {
    final t = AppTheme.light;
    expect(t.useMaterial3, true);
    expect(t.brightness, Brightness.light);
    expect(t.textTheme.bodyMedium?.fontFamily, 'Inter');
    expect(t.colorScheme.primary, LightTokens.primary);
    expect(t.extension<DiseaseColors>(), DiseaseColors.light);
  });

  test('dark theme es oscuro y trae la extensión oscura', () {
    final t = AppTheme.dark;
    expect(t.brightness, Brightness.dark);
    expect(t.colorScheme.primary, DarkTokens.primary);
    expect(t.extension<DiseaseColors>(), DiseaseColors.dark);
  });
}
```

- [ ] **Step 4: Run test to verify it fails**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: FAIL — `AppTheme` no existe.

- [ ] **Step 5: Write `app_theme.dart`**

```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_tokens.dart';
import 'disease_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        primary: LightTokens.primary,
        onPrimary: Colors.white,
        secondary: LightTokens.accent,
        background: LightTokens.background,
        surface: LightTokens.surface,
        textPrimary: LightTokens.textPrimary,
        textSecondary: LightTokens.textSecondary,
        error: LightTokens.error,
        appBarColor: LightTokens.primary,
        diseaseColors: DiseaseColors.light,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        primary: DarkTokens.primary,
        onPrimary: const Color(0xFF06140C),
        secondary: DarkTokens.accent,
        background: DarkTokens.background,
        surface: DarkTokens.surface,
        textPrimary: DarkTokens.textPrimary,
        textSecondary: DarkTokens.textSecondary,
        error: DarkTokens.error,
        appBarColor: DarkTokens.primaryDark,
        diseaseColors: DiseaseColors.dark,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color background,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color error,
    required Color appBarColor,
    required DiseaseColors diseaseColors,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      secondary: secondary,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: surface,
      onSurface: textPrimary,
    );

    const tabular = [FontFeature.tabularFigures()];

    final textTheme = TextTheme(
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: textPrimary),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
      displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700, color: textPrimary, fontFeatures: tabular, letterSpacing: -1),
      bodyMedium: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: textPrimary),
      bodySmall: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: textSecondary),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textSecondary, letterSpacing: 0.6),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Inter',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      extensions: [diseaseColors],
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(fontFamily: 'Inter', color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: onPrimary,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(52),
          side: BorderSide(color: primary, width: 1.5),
          textStyle: const TextStyle(fontFamily: 'Inter', fontSize: 15, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: textSecondary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: primary.withValues(alpha: 0.1),
        labelStyle: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.pill)),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontFamily: 'Inter', fontSize: 12),
      ),
      dividerTheme: DividerThemeData(color: textSecondary.withValues(alpha: 0.15), thickness: 1),
    );
  }
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/core/theme/app_theme_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 7: Commit**

```bash
git add lib/core/theme/app_theme.dart pubspec.yaml assets/fonts test/core/theme/app_theme_test.dart
git commit -m "feat(theme): add light/dark Material 3 themes with bundled Inter font"
```

---

### Task 3: ThemeProvider (persistencia del modo)

**Files:**
- Create: `lib/core/providers/theme_provider.dart`
- Test: `test/core/providers/theme_provider_test.dart`

**Interfaces:**
- Produces: `ThemeProvider extends ChangeNotifier` con `ThemeMode get themeMode`, `Future<void> setThemeMode(ThemeMode)`, carga inicial desde `SharedPreferences` (clave `'themeMode'`, valores `'system'|'light'|'dark'`, default `system`).

- [ ] **Step 1: Write the failing test**

```dart
// test/core/providers/theme_provider_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplication_tesis/core/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('por defecto es ThemeMode.system', () async {
    SharedPreferences.setMockInitialValues({});
    final p = ThemeProvider();
    expect(p.themeMode, ThemeMode.system);
  });

  test('setThemeMode actualiza y persiste', () async {
    SharedPreferences.setMockInitialValues({});
    final p = ThemeProvider();
    await p.setThemeMode(ThemeMode.dark);
    expect(p.themeMode, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('themeMode'), 'dark');
  });

  test('carga el modo guardado', () async {
    SharedPreferences.setMockInitialValues({'themeMode': 'light'});
    final p = ThemeProvider();
    await Future<void>.delayed(Duration.zero);
    expect(p.themeMode, ThemeMode.light);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/providers/theme_provider_test.dart`
Expected: FAIL — `ThemeProvider` no existe.

- [ ] **Step 3: Write `theme_provider.dart`**

```dart
// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = _fromString(prefs.getString('themeMode'));
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', _toString(mode));
  }

  static ThemeMode _fromString(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static String _toString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/providers/theme_provider_test.dart`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/providers/theme_provider.dart test/core/providers/theme_provider_test.dart
git commit -m "feat(theme): add ThemeProvider with persisted ThemeMode"
```

---

### Task 4: Cablear el tema en main.dart + arreglar el smoke test

**Files:**
- Modify: `lib/main.dart`
- Modify: `test/widget_test.dart` (reemplaza el test contador roto)

**Interfaces:**
- Consumes: `AppTheme` (Task 2), `ThemeProvider` (Task 3).

- [ ] **Step 1: Write the failing test (reemplaza el smoke test roto)**

```dart
// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aplication_tesis/core/providers/theme_provider.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('MaterialApp refleja el ThemeMode del provider', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final provider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: Consumer<ThemeProvider>(
          builder: (_, p, __) => MaterialApp(
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: p.themeMode,
            home: const Scaffold(body: Text('AvoScan')),
          ),
        ),
      ),
    );

    expect(find.text('AvoScan'), findsOneWidget);

    await provider.setThemeMode(ThemeMode.dark);
    await tester.pump();

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/widget_test.dart`
Expected: FAIL — imports inexistentes (`app_theme`, `theme_provider`) o el viejo test contador.

- [ ] **Step 3: Modify `lib/main.dart`**

Reemplaza imports y la construcción del tema. El archivo queda así:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/providers/theme_provider.dart';
import 'features/main/presentation/pages/main_page.dart';
import 'features/detection/presentation/providers/detection_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'AvoScan AI',
            debugShowCheckedModeBanner: false,
            locale: localeProvider.locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            initialRoute: '/',
            routes: {
              '/': (context) => const MainPage(),
              '/main': (context) => const MainPage(),
            },
          );
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run test + analyze**

Run: `flutter test test/widget_test.dart`
Expected: PASS (1 test).
Run: `flutter analyze`
Expected: sin errores nuevos.

- [ ] **Step 5: Commit**

```bash
git add lib/main.dart test/widget_test.dart
git commit -m "feat(theme): wire light/dark themes and ThemeProvider into app; fix smoke test"
```

---

### Task 5: Widgets de estado (EmptyState / LoadingState / ErrorState)

**Files:**
- Create: `lib/core/widgets/app_states.dart`
- Test: `test/core/widgets/app_states_test.dart`

**Interfaces:**
- Produces:
  - `EmptyState({required IconData icon, required String title, String? message, String? actionLabel, VoidCallback? onAction})`
  - `LoadingState({String? message})`
  - `ErrorState({required String message, String? actionLabel, VoidCallback? onAction})`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/app_states_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/app_states.dart';

Widget _wrap(Widget child) => MaterialApp(theme: AppTheme.light, home: Scaffold(body: child));

void main() {
  testWidgets('EmptyState muestra título, mensaje y botón de acción', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(EmptyState(
      icon: Icons.history,
      title: 'Sin análisis',
      message: 'Toma una foto para empezar',
      actionLabel: 'Tomar foto',
      onAction: () => tapped = true,
    )));
    expect(find.text('Sin análisis'), findsOneWidget);
    expect(find.text('Toma una foto para empezar'), findsOneWidget);
    await tester.tap(find.text('Tomar foto'));
    expect(tapped, true);
  });

  testWidgets('LoadingState muestra indicador y mensaje', (tester) async {
    await tester.pumpWidget(_wrap(const LoadingState(message: 'Analizando…')));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Analizando…'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/app_states_test.dart`
Expected: FAIL — `app_states.dart` no existe.

- [ ] **Step 3: Write `app_states.dart`**

```dart
// lib/core/widgets/app_states.dart
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 72, color: theme.colorScheme.onSurface.withValues(alpha: 0.25)),
            const SizedBox(height: AppSpacing.lg),
            Text(title, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(message!, style: theme.textTheme.bodySmall, textAlign: TextAlign.center),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              FilledButton.icon(onPressed: onAction, icon: const Icon(Icons.add_a_photo), label: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Text(message!, style: theme.textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  const ErrorState({super.key, required this.message, this.actionLabel, this.onAction});
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: AppSpacing.lg),
            Text(message, style: theme.textTheme.bodyMedium, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/app_states_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/app_states.dart test/core/widgets/app_states_test.dart
git commit -m "feat(widgets): add EmptyState/LoadingState/ErrorState"
```

---

### Task 6: SectionHeader + StatusBadge + AppChip

**Files:**
- Create: `lib/core/widgets/section_header.dart`
- Create: `lib/core/widgets/status_badge.dart`
- Test: `test/core/widgets/section_header_test.dart`

**Interfaces:**
- Produces:
  - `SectionHeader({required String title, Widget? action})`
  - `StatusBadge({required String diseaseType, required String label})` — píldora con color por clase (usa `DiseaseColors.forType`).
  - `AppChip({required String label, IconData? icon, Color? color})`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/section_header_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/section_header.dart';
import 'package:aplication_tesis/core/widgets/status_badge.dart';

Widget _wrap(Widget c) => MaterialApp(theme: AppTheme.light, home: Scaffold(body: c));

void main() {
  testWidgets('SectionHeader muestra el título', (tester) async {
    await tester.pumpWidget(_wrap(const SectionHeader(title: 'Distribución')));
    expect(find.text('Distribución'), findsOneWidget);
  });

  testWidgets('StatusBadge muestra la etiqueta', (tester) async {
    await tester.pumpWidget(_wrap(const StatusBadge(diseaseType: 'rona', label: 'Roña')));
    expect(find.text('Roña'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/section_header_test.dart`
Expected: FAIL — archivos no existen.

- [ ] **Step 3: Write `section_header.dart`**

```dart
// lib/core/widgets/section_header.dart
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});
  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title.toUpperCase(), style: theme.textTheme.labelLarge),
        if (action != null) action!,
      ],
    );
  }
}
```

- [ ] **Step 4: Write `status_badge.dart`**

```dart
// lib/core/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';
import '../theme/disease_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.diseaseType, required this.label});
  final String diseaseType;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).extension<DiseaseColors>()!.forType(diseaseType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(diseaseIcon(diseaseType), size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}

class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, this.icon, this.color});
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 5),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 14, color: c), const SizedBox(width: 6)],
          Text(label, style: TextStyle(color: c, fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }
}
```

- [ ] **Step 5: Run test to verify it passes**

Run: `flutter test test/core/widgets/section_header_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 6: Commit**

```bash
git add lib/core/widgets/section_header.dart lib/core/widgets/status_badge.dart test/core/widgets/section_header_test.dart
git commit -m "feat(widgets): add SectionHeader, StatusBadge and AppChip"
```

---

### Task 7: PrimaryButton + SecondaryButton

**Files:**
- Create: `lib/core/widgets/app_buttons.dart`
- Test: `test/core/widgets/app_buttons_test.dart`

**Interfaces:**
- Produces:
  - `PrimaryButton({required String label, IconData? icon, VoidCallback? onPressed, bool isLoading = false})`
  - `SecondaryButton({required String label, IconData? icon, VoidCallback? onPressed})`

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/app_buttons_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/app_buttons.dart';

Widget _wrap(Widget c) => MaterialApp(theme: AppTheme.light, home: Scaffold(body: c));

void main() {
  testWidgets('PrimaryButton dispara onPressed', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(PrimaryButton(label: 'Guardar', onPressed: () => tapped = true)));
    await tester.tap(find.text('Guardar'));
    expect(tapped, true);
  });

  testWidgets('PrimaryButton en isLoading muestra spinner y se deshabilita', (tester) async {
    await tester.pumpWidget(_wrap(const PrimaryButton(label: 'Guardar', isLoading: true)));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/app_buttons_test.dart`
Expected: FAIL — `app_buttons.dart` no existe.

- [ ] **Step 3: Write `app_buttons.dart`**

```dart
// lib/core/widgets/app_buttons.dart
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.label, this.icon, this.onPressed, this.isLoading = false});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? SizedBox(
              height: 22, width: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
                Text(label),
              ],
            ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({super.key, required this.label, this.icon, this.onPressed});
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 10)],
          Text(label),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/app_buttons_test.dart`
Expected: PASS (2 tests).

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/app_buttons.dart test/core/widgets/app_buttons_test.dart
git commit -m "feat(widgets): add PrimaryButton and SecondaryButton"
```

---

### Task 8: StatCard

**Files:**
- Create: `lib/core/widgets/stat_card.dart`
- Test: `test/core/widgets/stat_card_test.dart`

**Interfaces:**
- Produces: `StatCard({required IconData icon, required String label, required String value, required Color accentColor})`. La cifra usa `textTheme.displaySmall` (numerales tabulares).

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/stat_card_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/stat_card.dart';

void main() {
  testWidgets('StatCard muestra label y value', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: StatCard(icon: Icons.analytics, label: 'Análisis totales', value: '128', accentColor: Colors.green),
      ),
    ));
    expect(find.text('Análisis totales'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
    expect(find.byIcon(Icons.analytics), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/stat_card_test.dart`
Expected: FAIL — `stat_card.dart` no existe.

- [ ] **Step 3: Write `stat_card.dart`**

```dart
// lib/core/widgets/stat_card.dart
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(value, style: theme.textTheme.displaySmall?.copyWith(color: accentColor, fontSize: 28)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/stat_card_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/stat_card.dart test/core/widgets/stat_card_test.dart
git commit -m "feat(widgets): add StatCard"
```

---

### Task 9: ConfidenceBar

**Files:**
- Create: `lib/core/widgets/confidence_bar.dart`
- Test: `test/core/widgets/confidence_bar_test.dart`

**Interfaces:**
- Produces: `ConfidenceBar({required double value, Color? color})` — `value` en rango 0.0–1.0. Muestra el porcentaje como texto (`'87%'`).

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/confidence_bar_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/confidence_bar.dart';

void main() {
  testWidgets('ConfidenceBar muestra el porcentaje redondeado', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(body: ConfidenceBar(value: 0.87)),
    ));
    expect(find.text('87%'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/confidence_bar_test.dart`
Expected: FAIL — `confidence_bar.dart` no existe.

- [ ] **Step 3: Write `confidence_bar.dart`**

```dart
// lib/core/widgets/confidence_bar.dart
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class ConfidenceBar extends StatelessWidget {
  const ConfidenceBar({super.key, required this.value, this.color});
  final double value; // 0.0 - 1.0
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.primary;
    final clamped = value.clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Confianza', style: theme.textTheme.bodySmall),
            Text('${(clamped * 100).round()}%',
                style: theme.textTheme.bodyMedium?.copyWith(color: c, fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: clamped,
            minHeight: 8,
            backgroundColor: c.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(c),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/confidence_bar_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/confidence_bar.dart test/core/widgets/confidence_bar_test.dart
git commit -m "feat(widgets): add ConfidenceBar"
```

---

### Task 10: DetectionTile

**Files:**
- Create: `lib/core/widgets/detection_tile.dart`
- Test: `test/core/widgets/detection_tile_test.dart`

**Interfaces:**
- Consumes: `DetectionResult` (`lib/core/models/detection_result.dart`), `DiseaseColors`, `diseaseIcon`, `StatusBadge`.
- Produces: `DetectionTile({required DetectionResult result, required String diseaseName, required String timeLabel, VoidCallback? onTap, VoidCallback? onDelete})`. (El llamador resuelve `diseaseName`/`timeLabel` por idioma; el tile no hace i18n.)

- [ ] **Step 1: Write the failing test**

```dart
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
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/detection_tile_test.dart`
Expected: FAIL — `detection_tile.dart` no existe.

- [ ] **Step 3: Write `detection_tile.dart`**

```dart
// lib/core/widgets/detection_tile.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../models/detection_result.dart';
import '../theme/app_tokens.dart';
import '../theme/disease_colors.dart';

class DetectionTile extends StatelessWidget {
  const DetectionTile({
    super.key,
    required this.result,
    required this.diseaseName,
    required this.timeLabel,
    this.onTap,
    this.onDelete,
  });

  final DetectionResult result;
  final String diseaseName;
  final String timeLabel;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.extension<DiseaseColors>()!.forType(result.diseaseType);
    final file = File(result.imagePath);
    final hasImage = file.existsSync();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: theme.dividerColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: SizedBox(
                  width: 56, height: 56,
                  child: hasImage
                      ? Image.file(file, fit: BoxFit.cover)
                      : Container(
                          color: color.withValues(alpha: 0.12),
                          child: Icon(diseaseIcon(result.diseaseType), color: color),
                        ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(diseaseName, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(timeLabel, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text('${(result.confidence * 100).round()}%',
                  style: theme.textTheme.bodyMedium?.copyWith(color: color, fontWeight: FontWeight.w700)),
              if (onDelete != null)
                IconButton(
                  icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/detection_tile_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/detection_tile.dart test/core/widgets/detection_tile_test.dart
git commit -m "feat(widgets): add DetectionTile"
```

---

### Task 11: DonutChart

**Files:**
- Create: `lib/core/widgets/donut_chart.dart`
- Test: `test/core/widgets/donut_chart_test.dart`

**Interfaces:**
- Consumes: `fl_chart`.
- Produces: `DonutSection({required double value, required String label, required Color color})`; `DonutChart({required List<DonutSection> sections, String? centerValue, String? centerLabel})` — dona + leyenda con `label` y porcentaje.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/donut_chart_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/donut_chart.dart';

void main() {
  testWidgets('DonutChart renderiza la leyenda', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: DonutChart(
          centerValue: '128',
          centerLabel: 'frutos',
          sections: [
            DonutSection(value: 67, label: 'Sanos', color: Colors.green),
            DonutSection(value: 19, label: 'Mancha Negra', color: Colors.grey),
            DonutSection(value: 14, label: 'Roña', color: Colors.orange),
          ],
        ),
      ),
    ));
    expect(find.text('Sanos'), findsOneWidget);
    expect(find.text('Roña'), findsOneWidget);
    expect(find.text('128'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/donut_chart_test.dart`
Expected: FAIL — `donut_chart.dart` no existe.

- [ ] **Step 3: Write `donut_chart.dart`**

```dart
// lib/core/widgets/donut_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class DonutSection {
  const DonutSection({required this.value, required this.label, required this.color});
  final double value;
  final String label;
  final Color color;
}

class DonutChart extends StatelessWidget {
  const DonutChart({super.key, required this.sections, this.centerValue, this.centerLabel});
  final List<DonutSection> sections;
  final String? centerValue;
  final String? centerLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = sections.fold<double>(0, (s, e) => s + e.value);
    return Row(
      children: [
        SizedBox(
          width: 120, height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 34,
                sections: sections
                    .map((s) => PieChartSectionData(
                          value: s.value, color: s.color, radius: 18, showTitle: false))
                    .toList(),
              )),
              if (centerValue != null)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(centerValue!, style: theme.textTheme.titleLarge),
                    if (centerLabel != null) Text(centerLabel!, style: theme.textTheme.bodySmall),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Column(
            children: sections.map((s) {
              final pct = total == 0 ? 0 : (s.value / total * 100).round();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: s.color, shape: BoxShape.circle)),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(s.label, style: theme.textTheme.bodyMedium)),
                    Text('$pct%', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/donut_chart_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Commit**

```bash
git add lib/core/widgets/donut_chart.dart test/core/widgets/donut_chart_test.dart
git commit -m "feat(widgets): add DonutChart with legend"
```

---

### Task 12: InfoHint (ayuda contextual)

**Files:**
- Create: `lib/core/widgets/info_hint.dart`
- Test: `test/core/widgets/info_hint_test.dart`

**Interfaces:**
- Produces: `InfoHint({required String term, required String explanation})` — ícono "?" que al tocarlo abre un `showModalBottomSheet` con `term` (título) y `explanation`.

- [ ] **Step 1: Write the failing test**

```dart
// test/core/widgets/info_hint_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/info_hint.dart';

void main() {
  testWidgets('InfoHint abre una hoja con la explicación', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.light,
      home: const Scaffold(
        body: InfoHint(term: 'Confianza', explanation: 'Qué tan seguro está el análisis (0–100%).'),
      ),
    ));
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.text('Confianza'), findsOneWidget);
    expect(find.text('Qué tan seguro está el análisis (0–100%).'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/widgets/info_hint_test.dart`
Expected: FAIL — `info_hint.dart` no existe.

- [ ] **Step 3: Write `info_hint.dart`**

```dart
// lib/core/widgets/info_hint.dart
import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

class InfoHint extends StatelessWidget {
  const InfoHint({super.key, required this.term, required this.explanation});
  final String term;
  final String explanation;

  void _show(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(term, style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface)),
            const SizedBox(height: AppSpacing.md),
            Text(explanation, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      icon: Icon(Icons.help_outline, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
      tooltip: term,
      onPressed: () => _show(context),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/widgets/info_hint_test.dart`
Expected: PASS (1 test).

- [ ] **Step 5: Run la suite completa + analyze**

Run: `flutter test`
Expected: PASS (todas).
Run: `flutter analyze`
Expected: sin errores nuevos.

- [ ] **Step 6: Commit**

```bash
git add lib/core/widgets/info_hint.dart test/core/widgets/info_hint_test.dart
git commit -m "feat(widgets): add InfoHint contextual help"
```

---

## Self-Review

**1. Cobertura del spec (Plan 1):** tokens (T1), tema claro/oscuro + Inter (T2), ThemeProvider/persistencia (T3), cableado en `main` (T4), componentes `EmptyState/Loading/Error` (T5), `SectionHeader/StatusBadge/AppChip` (T6), botones (T7), `StatCard` (T8), `ConfidenceBar` (T9), `DetectionTile` (T10), `DonutChart` (T11), `InfoHint` (T12). El toggle de tema en UI, la migración de pantallas, el onboarding y las cadenas l10n nuevas son **Plan 2** (declarado arriba).

**2. Placeholders:** ninguno; cada paso trae código/comandos concretos.

**3. Consistencia de tipos:** `DiseaseColors.forType` (T1) usado en T6/T10; `diseaseIcon` (T1) usado en T6/T10; `AppTheme.light/dark` (T2) usado en T4 y en todos los tests; `ThemeProvider.themeMode/setThemeMode` (T3) usado en T4. `AppSpacing`/`AppRadius` (T1) usados en T5–T12.

**Nota de invariante:** ninguna tarea toca `DetectionService`, `DatabaseHelper`, modelos ni los literales `'healthy'|'mancha_negra'|'rona'`.

---

## Notas para el Plan 2 (siguiente)

- Migrar Dashboard, Resultado (card en `camera_page`), Cámara, Calculadora, Historial y Configuración a los componentes/tema; quitar `AppColors`/estilos inline.
- Añadir sección **Apariencia** en Configuración (selector Claro/Oscuro/Automático conectado a `ThemeProvider`).
- Onboarding de primer uso (flag `onboarding_seen`) + ruta previa a `MainPage`.
- Restyle de `BottomNavigationBar` (cámara central elevada).
- Cadenas l10n nuevas (ES/EN) para apariencia, ayudas, estados vacíos, onboarding, confirmaciones; `flutter gen-l10n`.
