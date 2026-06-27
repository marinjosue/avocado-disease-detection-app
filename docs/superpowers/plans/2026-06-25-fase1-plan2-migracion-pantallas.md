# Fase 1 · Plan 2 — Migración de pantallas al sistema de diseño · Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`) syntax.

**Goal:** Aplicar el sistema de diseño (estilo C, tema claro/oscuro, componentes) a las 6 pantallas + BottomNav, añadir el toggle de tema en Configuración, el onboarding de primer uso y las cadenas l10n — sin cambiar la lógica.

**Architecture:** Cada pantalla deja de usar `AppColors`/estilos inline y pasa a leer del `Theme` (de Plan 1) y a usar los componentes de `lib/core/widgets/`. Se agrega `OnboardingPage` + flag en SharedPreferences, y un selector de tema en Configuración conectado a `ThemeProvider`. Lógica, modelos, DB y servicios quedan intactos.

**Tech Stack:** Flutter 3.44 Material 3, provider, componentes de Plan 1, l10n ARB.

## Global Constraints

- **Solo capa visual/UX.** NO tocar `DetectionService`, `DatabaseHelper`, modelos, `DetectionProvider`, ni la lógica (cálculos de calculadora, flujo de cámara, operaciones de historial).
- **Contrato de clases intacto:** `'healthy'`, `'mancha_negra'`, `'rona'`.
- **Sin `Color(...)`/`fontSize` hardcodeados** en las pantallas: todo del `Theme`/componentes. `withValues(alpha:)`, nunca `withOpacity`.
- **Estilo C (tokens ya en el tema):** primary `#1F6B3B`, accent `#26C281`, etc. (ver `app_tokens.dart`).
- **i18n:** todo texto visible nuevo va por ARB (ES + EN). Componentes reciben el texto del caller (no hardcodear español).
- **Cada pantalla debe compilar y conservar su funcionalidad;** `flutter analyze` sin issues y `flutter test` verde tras cada tarea.
- **Componentes disponibles** (Plan 1): `StatCard`, `SectionHeader`, `DetectionTile`, `ConfidenceBar`, `StatusBadge`/`AppChip`, `DonutChart`/`DonutSection`, `PrimaryButton`/`SecondaryButton`, `EmptyState`/`LoadingState`/`ErrorState`, `InfoHint`.

---

## File Structure

- `lib/l10n/app_en.arb`, `app_es.arb` — **Modificar.** Nuevas claves (Task 1).
- `lib/core/widgets/theme_mode_selector.dart` — **Crear.** Selector Claro/Oscuro/Automático (Task 2).
- `lib/features/onboarding/presentation/pages/onboarding_page.dart` — **Crear.** (Task 9)
- `lib/core/services/onboarding_service.dart` — **Crear.** Flag `onboarding_seen` (Task 9).
- `lib/main.dart` — **Modificar.** Ruta inicial condicional a onboarding (Task 9).
- `lib/features/*/presentation/pages/*.dart` — **Modificar.** Migración (Tasks 3-8).

---

### Task 1: Cadenas l10n (ES/EN) para el rediseño

**Files:** Modify `lib/l10n/app_es.arb`, `lib/l10n/app_en.arb`. Then run `flutter gen-l10n`.

**Interfaces — Produces (nuevas claves `AppLocalizations`):**
`appearance`, `themeLight`, `themeDark`, `themeSystem`, `analyzing`, `emptyDashboardTitle`, `emptyDashboardMessage`, `emptyHistoryTitle`, `emptyHistoryMessage`, `confidenceHint`, `viewTutorial`, `confirmDeleteTitle`, `confirmDeleteMessage`, `confirmClearTitle`, `confirmClearMessage`, `save`, `newDetection`, `onbWelcomeTitle`, `onbWelcomeBody`, `onbPhotoTitle`, `onbPhotoBody`, `onbResultsTitle`, `onbResultsBody`, `onbSkip`, `onbNext`, `onbStart`, `distribution`, `takeFirstPhoto`.

- [ ] **Step 1:** Add to `lib/l10n/app_en.arb` (and matching `app_es.arb` with Spanish), each key with a value. English values (sample):

```json
"appearance": "Appearance",
"themeLight": "Light",
"themeDark": "Dark",
"themeSystem": "System",
"distribution": "Distribution",
"analyzing": "Analyzing…",
"emptyDashboardTitle": "No analyses yet",
"emptyDashboardMessage": "Take a photo of a fruit to start.",
"takeFirstPhoto": "Take a photo",
"emptyHistoryTitle": "No history yet",
"emptyHistoryMessage": "Your detections will appear here.",
"confidenceHint": "How sure the analysis is (0–100%).",
"viewTutorial": "View tutorial again",
"confirmDeleteTitle": "Delete record?",
"confirmDeleteMessage": "This detection will be permanently removed.",
"confirmClearTitle": "Clear history?",
"confirmClearMessage": "All detections will be permanently removed.",
"save": "Save result",
"newDetection": "New detection",
"onbWelcomeTitle": "Welcome to avocadoIA",
"onbWelcomeBody": "Detect Black Spot and Scab in avocado from a photo.",
"onbPhotoTitle": "Take a good photo",
"onbPhotoBody": "Good light, get close to the fruit, keep it in focus.",
"onbResultsTitle": "See results and tips",
"onbResultsBody": "Review the diagnosis, recommendations and your history.",
"onbSkip": "Skip",
"onbNext": "Next",
"onbStart": "Get started"
```

Spanish (`app_es.arb`) — same keys, e.g. `"appearance": "Apariencia"`, `"themeLight": "Claro"`, `"themeDark": "Oscuro"`, `"themeSystem": "Automático"`, `"distribution": "Distribución"`, `"analyzing": "Analizando…"`, `"emptyDashboardTitle": "Aún no hay análisis"`, `"emptyDashboardMessage": "Toma una foto de un fruto para empezar."`, `"takeFirstPhoto": "Tomar foto"`, `"emptyHistoryTitle": "Aún no hay historial"`, `"emptyHistoryMessage": "Tus detecciones aparecerán aquí."`, `"confidenceHint": "Qué tan seguro está el análisis (0–100%)."`, `"viewTutorial": "Ver tutorial de nuevo"`, `"confirmDeleteTitle": "¿Eliminar registro?"`, `"confirmDeleteMessage": "Esta detección se eliminará permanentemente."`, `"confirmClearTitle": "¿Limpiar historial?"`, `"confirmClearMessage": "Se eliminarán todas las detecciones."`, `"save": "Guardar resultado"`, `"newDetection": "Nueva detección"`, `"onbWelcomeTitle": "Bienvenido a avocadoIA"`, `"onbWelcomeBody": "Detecta Mancha Negra y Roña en aguacate desde una foto."`, `"onbPhotoTitle": "Toma una buena foto"`, `"onbPhotoBody": "Buena luz, acerca el fruto y mantenlo enfocado."`, `"onbResultsTitle": "Mira resultados y consejos"`, `"onbResultsBody": "Revisa el diagnóstico, las recomendaciones y tu historial."`, `"onbSkip": "Saltar"`, `"onbNext": "Siguiente"`, `"onbStart": "Empezar"`.

- [ ] **Step 2:** Run `flutter gen-l10n`. Expected: regenerates `lib/l10n/app_localizations*.dart` with the new getters, no errors.
- [ ] **Step 3:** Run `flutter analyze` → no issues. Commit: `git add lib/l10n && git commit -m "feat(l10n): add strings for redesign (appearance, onboarding, empty states)"`.

---

### Task 2: ThemeModeSelector + sección Apariencia en Configuración

**Files:** Create `lib/core/widgets/theme_mode_selector.dart`; Modify `lib/features/main/presentation/pages/settings_page.dart`; Test `test/core/widgets/theme_mode_selector_test.dart`.

**Interfaces:** Consumes `ThemeProvider`. Produces `ThemeModeSelector({required ThemeMode value, required ValueChanged<ThemeMode> onChanged, required String lightLabel, required String darkLabel, required String systemLabel})`.

- [ ] **Step 1: Failing test**

```dart
// test/core/widgets/theme_mode_selector_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplication_tesis/core/theme/app_theme.dart';
import 'package:aplication_tesis/core/widgets/theme_mode_selector.dart';

void main() {
  testWidgets('ThemeModeSelector emite el modo elegido', (tester) async {
    ThemeMode? picked;
    await tester.pumpWidget(MaterialApp(theme: AppTheme.light, home: Scaffold(
      body: ThemeModeSelector(value: ThemeMode.system, onChanged: (m) => picked = m,
        lightLabel: 'Claro', darkLabel: 'Oscuro', systemLabel: 'Automático'),
    )));
    await tester.tap(find.text('Oscuro'));
    expect(picked, ThemeMode.dark);
  });
}
```

- [ ] **Step 2:** Run test → FAIL.
- [ ] **Step 3: Implement** `theme_mode_selector.dart` — three `RadioListTile<ThemeMode>` inside a `RadioGroup<ThemeMode>` (values `system`/`light`/`dark`), wrapped in a themed `Card`. Each tile shows an icon (`Icons.brightness_auto`/`Icons.light_mode`/`Icons.dark_mode`) + the provided label. No hardcoded colors/fontSize.
- [ ] **Step 4: Wire into Settings** — in `settings_page.dart`, add an "Apariencia" section ABOVE "Idioma" using `SectionHeader(title: l10n.appearance)` and `ThemeModeSelector(value: context.watch<ThemeProvider>().themeMode, onChanged: (m) => context.read<ThemeProvider>().setThemeMode(m), lightLabel: l10n.themeLight, darkLabel: l10n.themeDark, systemLabel: l10n.themeSystem)`. Import `ThemeProvider`. Migrate the rest of Settings to read from `Theme` (remove `AppColors`/inline styles; cards use `theme.cardTheme`/`SectionHeader`). Add a "Ver tutorial" `ListTile` (`l10n.viewTutorial`) that resets the onboarding flag and pushes `OnboardingPage` (wire after Task 9 — leave a `// TODO Task 9` if needed, but prefer ordering Task 9 before final Settings commit).
- [ ] **Step 5:** Run `flutter test test/core/widgets/theme_mode_selector_test.dart` + `flutter analyze`. Commit: `feat(settings): appearance theme toggle + Settings redesign`.

**Acceptance:** Cambiar el modo en Configuración actualiza toda la app al instante y persiste tras reiniciar; Configuración no usa `AppColors`.

---

### Task 3: Dashboard

**Files:** Modify `lib/features/dashboard/presentation/pages/dashboard_page.dart`. Test `test/features/dashboard/dashboard_page_test.dart`.

Migrate to the design system, preserving the `Consumer<DetectionProvider>` logic and the same data (`provider.statistics`, `getRecentDetections`).

- [ ] **Step 1: Failing widget test** — pump `DashboardPage` inside `MaterialApp(theme: AppTheme.light)` + a `ChangeNotifierProvider<DetectionProvider>` (use a real provider; with an empty DB it shows the empty state). Assert the empty-state title (`l10n.emptyDashboardTitle` text "Aún no hay análisis") renders. (Wrap with localization delegates.)
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3: Implement the migration:**
  - Replace the 4 stat `Container`s with `StatCard(icon:, label:, value:, accentColor:)` — colors from `Theme.of(context).extension<DiseaseColors>()!` (healthy/manchaNegra/rona) and `colorScheme.primary` for "Análisis totales".
  - Section titles → `SectionHeader(title: l10n.distribution)` and `SectionHeader(title: l10n.recentActivity)`.
  - Pie chart → `DonutChart(centerValue: total, centerLabel: ..., sections: [DonutSection(value: healthy%, label: l10n.healthy, color: diseaseColors.healthy), ...])`.
  - Recent list → `DetectionTile(result:, diseaseName: (es? getDiseaseNameES():getDiseaseNameEN()), timeLabel: <relative>, onTap: ...)`.
  - Empty (total==0) → `EmptyState(icon: Icons.insights, title: l10n.emptyDashboardTitle, message: l10n.emptyDashboardMessage)`.
  - AppBar: remove hardcoded `backgroundColor: AppColors.primary` (inherits `appBarTheme`). Keep the refresh action.
  - Remove all `AppColors`/inline `fontSize`/`withOpacity`.
- [ ] **Step 4:** Run the test + `flutter analyze`. Commit: `feat(dashboard): redesign with design-system components`.

**Acceptance:** Dashboard se ve como el mockup C en claro y oscuro; misma data; estado vacío con mensaje.

---

### Task 4: Resultado de detección (en camera_page)

**Files:** Modify `lib/features/detection/presentation/pages/camera_page.dart` (the `_buildResultCard` + the `_showResultDialog`). Test optional widget test for the result card.

- [ ] **Step 1:** Implement: rework `_buildResultCard` into a themed result panel: result banner using `StatusBadge(diseaseType:, label: diseaseName)` + big disease name, `ConfidenceBar(value: result.confidence, label: l10n.confidence)`, a "Recomendaciones" card (`SectionHeader(l10n.recommendations)` + the bullet text), and actions `PrimaryButton(label: l10n.save, ...)` / `SecondaryButton(label: l10n.newDetection, onPressed: _reset)`. **Reserve a commented placeholder** `// Fase 2: botón "Preguntar a la IA"` — do NOT implement. Colors from `DiseaseColors`. Keep `_showResultDialog` but restyle (or replace its body with the same panel). Preserve all detection logic (`_analyzeImage`, save to provider).
- [ ] **Step 2:** `flutter analyze` + `flutter test`. Commit: `feat(detection): redesign result panel`.

**Acceptance:** El resultado muestra banner por enfermedad + barra de confianza + recomendaciones + botones; lógica intacta.

---

### Task 5: Cámara

**Files:** Modify `lib/features/detection/presentation/pages/camera_page.dart` (capture UI).

- [ ] **Step 1:** Migrate: the image placeholder Container → themed (surface + dashed/`dividerColor` border + icon + `l10n.selectImage`). Action buttons → `PrimaryButton(icon: Icons.camera_alt, label: l10n.takePhoto)` / `SecondaryButton(icon: Icons.photo_library, label: l10n.chooseFromGallery)`. Analyzing state → `LoadingState(message: l10n.analyzing)` (or PrimaryButton `isLoading`). Remove `AppColors`/inline styles. Preserve `_pickImage`/`_analyzeImage`.
- [ ] **Step 2:** `flutter analyze` + `flutter test`. Commit: `feat(camera): redesign capture screen`.

---

### Task 6: Calculadora

**Files:** Modify `lib/features/calculator/presentation/pages/calculator_page.dart`.

- [ ] **Step 1:** Migrate visuals ONLY (keep `_calculate`/`_loadFromHistory`/`_reset` and the math exactly): inputs use `InputDecorationTheme` (drop inline border colors; keep the per-field accent via `prefixIcon` color from `DiseaseColors`). Result cards → reuse `StatCard` or a themed card; buttons → `PrimaryButton`/`SecondaryButton`. Recommendations block uses themed `success`/`warning`/`error` from the colorScheme. Add an `InfoHint(term: l10n.diseaseIncidence, explanation: ...)` next to the incidence result. Remove `AppColors`/inline `fontSize`/`withOpacity`.
- [ ] **Step 2:** `flutter analyze` + `flutter test`. Commit: `feat(calculator): redesign with design system`.

**Acceptance:** Los cálculos dan idénticos resultados; UI con tema/componentes.

---

### Task 7: Historial

**Files:** Modify `lib/features/detection/presentation/pages/history_list_page.dart`. Test `test/features/history/history_page_test.dart` (empty state).

- [ ] **Step 1: Failing test** — empty provider → assert `l10n.emptyHistoryTitle` ("Aún no hay historial") renders.
- [ ] **Step 2: Implement:** list items → `DetectionTile(result:, diseaseName:, timeLabel:, onTap: _showDetectionDetails, onDelete: () => _showDeleteConfirmation(...))`. Empty → `EmptyState(icon: Icons.history, title: l10n.emptyHistoryTitle, message: l10n.emptyHistoryMessage)`. Delete/clear dialogs use `l10n.confirmDeleteTitle/Message` and `confirmClearTitle/Message`. Detail dialog restyled with theme. Preserve all DB ops (`deleteDetection`, `clearAllDetections`).
- [ ] **Step 3:** Run test + `flutter analyze`. Commit: `feat(history): redesign list with DetectionTile + EmptyState`.

---

### Task 8: BottomNav (main_page)

**Files:** Modify `lib/features/main/presentation/pages/main_page.dart`.

- [ ] **Step 1:** Migrate the `BottomNavigationBar` to read from `bottomNavigationBarTheme` (remove hardcoded `Color(0xFF2E7D32)`/grey). Keep the elevated center camera button but source its gradient/colors from `colorScheme.primary`/`secondary` and `DiseaseColors`/tokens (no raw hex). Offline banner: use `colorScheme` (e.g. `warning`) instead of `Colors.orange`. Preserve the `_pages`/index logic and the offline `Consumer`.
- [ ] **Step 2:** `flutter analyze` + `flutter test`. Commit: `feat(nav): restyle bottom navigation from theme`.

---

### Task 9: Onboarding de primer uso

**Files:** Create `lib/core/services/onboarding_service.dart`, `lib/features/onboarding/presentation/pages/onboarding_page.dart`; Modify `lib/main.dart`; finalize the "Ver tutorial" action in `settings_page.dart`. Tests `test/core/services/onboarding_service_test.dart`.

**Interfaces:** `OnboardingService` — `Future<bool> hasSeen()`, `Future<void> markSeen()`, `Future<void> reset()` (SharedPreferences key `onboarding_seen`). `OnboardingPage({VoidCallback? onFinish})`.

- [ ] **Step 1: Failing test** for `OnboardingService` (default hasSeen=false; markSeen→true; reset→false) using `SharedPreferences.setMockInitialValues`.
- [ ] **Step 2:** Implement `OnboardingService`.
- [ ] **Step 3:** Implement `OnboardingPage` — a `PageView` of 3 slides (icon + `onbWelcome*`/`onbPhoto*`/`onbResults*` from l10n), a "Saltar" (`onbSkip`) text button always visible, page-dots indicator, and `onbNext`/`onbStart` `PrimaryButton`. On skip/finish → `OnboardingService.markSeen()` then call `onFinish` (navigate to `/main`). All from `Theme`.
- [ ] **Step 4:** Wire `main.dart` — make the initial widget decide: a small `FutureBuilder`/bootstrap that shows `OnboardingPage(onFinish: → MainPage)` when `!hasSeen`, else `MainPage`. Keep routes `/` and `/main`.
- [ ] **Step 5:** Finalize Settings "Ver tutorial" → `OnboardingService.reset()` then push `OnboardingPage`.
- [ ] **Step 6:** `flutter test` + `flutter analyze`. Commit: `feat(onboarding): first-run tutorial + replayable from settings`.

**Acceptance:** Primer arranque muestra onboarding (saltable), no reaparece; re-accesible desde Configuración.

---

### Task 10: Polish diferido (robustez)

**Files:** Modify `lib/core/widgets/status_badge.dart`, `lib/core/widgets/detection_tile.dart`.

- [ ] **Step 1:** Replace `theme.extension<DiseaseColors>()!` with a safe fallback: `(theme.extension<DiseaseColors>() ?? DiseaseColors.light)` in both widgets, so a missing extension can't crash. Keep tests green.
- [ ] **Step 2:** `flutter test` + `flutter analyze`. Commit: `refactor(widgets): defensive DiseaseColors lookup`.

---

## Self-Review

- **Spec coverage:** Dashboard (T3), Resultado (T4), Cámara (T5), Calculadora (T6), Historial (T7), Configuración (T2), BottomNav (T8), tema claro/oscuro toggle (T2), onboarding (T9), l10n (T1), accesibilidad (InfoHint/EmptyState across tasks), deferred polish (T10). ✔
- **Placeholders:** the only intentional "reserve" is the Fase 2 "Preguntar a la IA" comment in T4 — explicitly NOT implemented here.
- **Type consistency:** component signatures match Plan 1; `ThemeMode` selector matches `ThemeProvider.setThemeMode`.
- **Invariant:** no task edits services/DB/models/logic.

## Ordering note

Recommended order: T1 (l10n) → T9 (onboarding, so Settings can wire "Ver tutorial") → T2 (Settings + toggle) → T3–T8 (screens) → T10 (polish). Or keep numeric order and leave the Settings "Ver tutorial" wiring as the last step of T2 referencing T9's service (T9 done first is cleaner).
