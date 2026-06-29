# Fase 2C — Voz (dictado + lectura) · Design Spec

**Date:** 2026-06-29 · **App:** avocadoIA (`aplication_tesis`) · **Branch:** main

## Goal
Make the AI assistant **hands-free**:
1. **Dictado (STT):** the user speaks; speech is transcribed and, when dictation ends, the message is **auto-sent**.
2. **Lectura automática (TTS):** when an assistant reply completes, it is **spoken aloud** (es-ES), with a **mute toggle** (remembered).
3. **Reproducir cualquier mensaje:** every assistant message has a ▶️/⏹️ button to play/stop its text via TTS.

All on-device (consistent with the offline/edge-AI thesis angle). The Gemma/stub inference and the persistent-conversations feature are NOT changed — voice wraps around them.

## Stack
- `speech_to_text` — dictation; uses the system speech recognizer (on-device on many Pixels; some devices need network — documented, not a blocker).
- `flutter_tts` — text-to-speech; 100% on-device system TTS engine; Spanish (es-ES) default, follows app locale (es/en).

## Permissions
- **Android** (`android/app/src/main/AndroidManifest.xml`): `<uses-permission android:name="android.permission.RECORD_AUDIO"/>`; Android 11+ `<queries>` for `android.speech.RecognitionService` and `android.intent.action.TTS_SERVICE`.
- **iOS** (`ios/Runner/Info.plist`): `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription`.
- Microphone is requested **on first use**. If denied: a clear localized message; the chat keeps working by text.

## Architecture (Approach A — thin services + a controller)
Three small, independently-testable units behind interfaces, composed by one observable controller:

- **`SpeechToTextService`** (interface + `RealSpeechToTextService`): `Future<bool> init()` (availability + permission), `Future<void> startListening({required void Function(String) onPartial, required void Function(String) onFinal, String localeId})`, `Future<void> stop()`, `bool get isAvailable`.
- **`TtsService`** (interface + `RealTtsService`): `Future<void> init()`, `Future<void> speak(String text, {String languageTag})`, `Future<void> stop()`, exposes `isSpeaking` (state + callback), sets language from locale.
- **`VoicePrefs`**: `Future<bool> getAutoSpeak()` / `setAutoSpeak(bool)` via SharedPreferences, key `assistant_auto_speak` (default **true**).
- **`VoiceController`** (`ChangeNotifier`, registered as the 6th provider in `main.dart`): composes the three. State: `isAvailable`, `isListening`, `isSpeaking`, `autoSpeak`, `partialText`. Methods: `init()`, `toggleAutoSpeak()`, `startDictation({required void Function(String) onFinal})`, `stopDictation()`, `speak(String)`, `stopSpeaking()`. Owns permission handling and language selection (from the app `Locale`).

`ChatPage` consumes `VoiceController` (via Provider) — it is the only UI that uses voice.

## UX / data flow (ChatPage)
- **Mic button** in the input row (replaces the `// Fase 2C: micrófono` placeholder): tap → `startDictation(onFinal: (text) => provider.send(text))`. While listening: animated mic + the live `partialText` shown in/above the input. On final result → dictation stops → `onFinal` auto-sends. Tap again to cancel.
- **🔊/🔇 toggle** in the chat AppBar → `toggleAutoSpeak()` (persisted; default ON).
- **Auto-read:** ChatPage detects when an assistant reply **completes** (the provider's `isThinking` transitions true→false with a new assistant message). If `autoSpeak` is on → `voice.speak(lastAssistantText)`. To fire **exactly once per reply** (not on every Consumer rebuild), ChatPage remembers the `timestamp` of the last assistant message it spoke and only speaks when the newest completed assistant message differs. Auto-read is canceled when the user starts dictation, taps a play button, or leaves the page.
- **Per-message ▶️/⏹️** on each assistant bubble → `voice.speak(text)` / `voice.stopSpeaking()`; reflects `isSpeaking`.
- **Language:** TTS language tag and STT localeId follow the app locale (es-ES / en-US).

## Error handling
- STT unavailable / permission denied → mic button shows disabled state + a localized snackbar; text chat unaffected.
- TTS engine missing/empty text → no-op, no crash.
- Starting dictation stops any ongoing TTS; starting TTS does not start dictation.

## Testing
- Fakes for `SpeechToTextService` + `TtsService` (+ in-memory `VoicePrefs`).
- `VoiceController` unit tests: toggleAutoSpeak persists; startDictation forwards onFinal; speak sets isSpeaking; permission-denied path.
- ChatPage widget tests (with fakes injected): mic button visible; AppBar toggle flips state; assistant bubble shows a play control; dictation final → calls provider.send. Keep all existing 99 tests green.

## Out of scope (YAGNI)
- No voice selection UI, no speech rate/pitch settings (use sensible defaults), no waveform visualizer (a simple animated mic indicator suffices), no wake-word, no continuous conversation loop.

## Risks / notes
- `speech_to_text` may require network on some devices (system recognizer) — documented; `flutter_tts` is on-device.
- **16 KB Play compliance:** both are thin wrappers over system services (no heavy bundled `.so`); verify the release `.so` LOAD-segment alignment still holds after adding them, and that the APK still builds.
- Re-run on device after adding permissions (manifest change needs a full rebuild + reinstall).

## Tasks (for the plan)
1. Deps + permissions (Android manifest + iOS plist) + `VoicePrefs`; verify build.
2. `SpeechToTextService` + `TtsService` (interfaces + impls) + `VoiceController` + register in `main`; unit tests with fakes.
3. ChatPage integration: mic dictation (auto-send), AppBar mute toggle, per-message play, auto-read on reply completion; l10n; widget tests.
