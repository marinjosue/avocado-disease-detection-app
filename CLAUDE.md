# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

AvoScan AI — Flutter mobile app for early detection of two avocado diseases (Mancha Negra / "black spot" and Roña / "scab") plus a healthy class, via an on-device CNN. ESPE thesis project. The package name is `aplication_tesis` (used in imports, e.g. `package:aplication_tesis/main.dart`). UI is Spanish-first with English support. Targets Android/iOS but also has desktop/web embedders scaffolded.

## Commands

```bash
flutter pub get                       # install deps (run after any pubspec change)
flutter run                           # run on connected device/emulator
flutter analyze                       # static analysis / lint (flutter_lints)
flutter test                          # run all tests
flutter test test/widget_test.dart    # run a single test file
flutter test --plain-name "smoke"     # run tests matching a name
flutter gen-l10n                       # regenerate localization Dart from lib/l10n/*.arb
flutter build apk                      # Android release build
```

Note: `test/widget_test.dart` is still the **default Flutter counter test** and does not match `AvoScanApp`, so `flutter test` currently fails out of the box. Replace it before relying on the suite.

## Architecture

Feature-first layout. `lib/core/` holds shared infrastructure; `lib/features/<feature>/` holds vertical slices, most using a `presentation/{pages,providers}` (and `data/services` for detection) sub-structure.

State management is **Provider**. The three app-wide `ChangeNotifier`s are registered in `MultiProvider` in [main.dart](lib/main.dart): `LocaleProvider`, `ConnectivityProvider`, `DetectionProvider`. There is no DI container wired up despite `get_it` being a dependency.

Navigation: [MainPage](lib/features/main/presentation/pages/main_page.dart) is the shell — a `BottomNavigationBar` with 5 tabs (Dashboard, Calculator, Camera, History, Settings) swapped by index from a `_pages` list. These tabs are **not** named routes; `main.dart` only declares `/` and `/main` → `MainPage`. An offline banner overlays all tabs when `ConnectivityProvider.isOnline` is false.

### Disease-class string contract

The three classes are the literal strings `'healthy'`, `'mancha_negra'`, `'rona'`. These keys flow end-to-end: `DetectionService` produces them → stored in `DetectionResult.diseaseType` → persisted in SQLite → aggregated by `DatabaseHelper.getStatistics()` (which seeds the same three keys) → surfaced via `DashboardStatistics`. Changing or adding a class means updating **all** of these sites plus the display-name/recommendation switches in [detection_result.dart](lib/core/models/detection_result.dart).

**The model's output order is not the app's key order.** The CNN was trained with `class_indices = {'mancha_negra': 0, 'ronia': 1, 'sana': 2}`, so `DetectionService._labels` is `['mancha_negra', 'rona', 'healthy']` — index 2, not index 0, is healthy. This is deliberate and verified against the dataset (98% agreement); the "natural-looking" alphabetical order would silently mislabel nearly every prediction.

### Persistence

Local-only SQLite via the `DatabaseHelper` singleton ([database_helper.dart](lib/core/database/database_helper.dart)), db file `avoscan.db`, schema version 1. Two tables: `workspaces` and `detection_results` (FK to workspace). A `'default'` workspace ("Mi Huerto") is inserted on create; `DetectionProvider` defaults `currentWorkspaceId` to `'default'`. There is no schema migration path yet — bumping the version requires adding an `onUpgrade`. No cloud sync exists despite README mentions.

### Localization

ARB-based. Source strings live in `lib/l10n/app_en.arb` (template, per [l10n.yaml](l10n.yaml)) and `app_es.arb`. Generated `app_localizations*.dart` are committed under `lib/l10n/` and `pubspec.yaml` has `generate: true`. Default locale is Spanish; the choice persists in `SharedPreferences` under key `languageCode`. Access in widgets via `AppLocalizations.of(context)` (nullable — code falls back to hardcoded English defaults). Note: disease display names and treatment recommendations are **not** localized through ARB; they are hardcoded `getDiseaseNameES/EN` / `getRecommendationES/EN` methods on `DetectionResult`.

## Critical gotchas (code diverges from docs)

The README/README_APP describe several features that are **not actually implemented** — treat the docs as aspirational:

- **Firebase / Google Sign-In are not wired up.** `firebase_core`, `firebase_auth`, `cloud_firestore`, `google_sign_in` are in `pubspec.yaml`, but `main.dart` never calls `Firebase.initializeApp()`, there is no `google-services.json`, and there is **no `auth` feature folder** at all. Authentication described in the READMEs does not exist in code.
