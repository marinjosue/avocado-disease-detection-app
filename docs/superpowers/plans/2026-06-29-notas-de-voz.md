# Notas de voz (audio + transcripción) — Implementation Plan

> Subagent-driven. Builds on Fase 2C voice. Best-effort: if the device can't record while the recognizer uses the mic, degrade gracefully to text-only (no crash, no data loss).

**Goal:** Dictated messages are saved as a **playable voice note** (recorded audio) with the **transcription shown below in smaller text** (WhatsApp-style). The text remains what the AI receives.

**Key constraint / risk:** `speech_to_text` uses the mic for recognition; recording audio simultaneously (`record` package) may contend for the mic on some devices. Implementation is **best-effort**: try to record alongside STT; if recording fails to start/produces nothing, send text-only (audioPath = null). Verify on the Pixel 8.

**Tech:** `record` (capture) + `audioplayers` (playback) — both pure-platform, pure-Dart APIs (verify 16 KB after).

## Global Constraints
- Package `aplication_tesis`. No `Co-Authored-By: Claude`. Spanish-first, Theme-only styling. Disease-class contract intact. Keep all existing tests green. analyze clean. Migration must be **non-destructive** (only ADD a column).

---

### VTask 1: Data layer — audioPath on messages
**Files:** `lib/features/assistant/domain/assistant_message.dart`, `lib/core/database/database_helper.dart`, `lib/features/assistant/data/conversation_repository.dart`, `lib/features/assistant/presentation/providers/assistant_provider.dart`, `pubspec.yaml`; tests.
- Add deps `record` + `audioplayers` (latest stable); `flutter pub get`.
- `AssistantMessage`: add nullable `String? audioPath`; include in constructor, `copyWith`, `toJson`/`fromJson`.
- DB **migration v2→v3**: bump `version` to 3; in `_onUpgrade` `if (oldV < 3) await db.execute('ALTER TABLE conversation_messages ADD COLUMN audioPath TEXT');`; also add the column to the `conversation_messages` CREATE for fresh installs. Do NOT touch other tables.
- `ConversationRepository.addMessage` persists `audioPath`; `getById`/`getByDetectionKey` map it back.
- `AssistantProvider.send(String text, {String? audioPath})` — attach `audioPath` to the persisted user message (keep existing behavior when null).
- Tests: AssistantMessage json round-trip with audioPath; repository persists/loads audioPath (ffi); provider.send stores audioPath. Commit `feat(voice): audioPath on messages + db v3 migration`.

### VTask 2: Recorder service + VoiceController integration
**Files:** `lib/features/assistant/domain/voice_services.dart` (add `VoiceRecorderService`), `lib/features/assistant/data/real_voice_recorder_service.dart`, `lib/features/assistant/presentation/providers/voice_controller.dart`; tests.
- `abstract class VoiceRecorderService { Future<bool> start(); Future<String?> stop(); Future<void> cancel(); }` — impl with `record`: `start()` checks permission + `hasPermission()`, starts recording to `<appDocs>/voice_notes/<ts>.m4a` (use a path passed in or `path_provider`), returns true on success / false on failure (catch). `stop()` returns the file path (or null). 
- `VoiceController.startDictation` signature → `{required void Function(String text, String? audioPath) onFinal, String localeId}`. Flow: `final recording = await _recorder.start();` (best-effort), `await _tts.stop()`, set listening, then STT; in the STT onFinal: `final path = recording ? await _recorder.stop() : null; onFinal(text, path);`. `stopDictation()` also cancels/stops the recorder.
- Tests (fakes): startDictation starts the recorder and, on final, returns the recorder's path via onFinal; if recorder.start() returns false, onFinal gets null. Commit `feat(voice): record audio during dictation (best-effort)`.

### VTask 3: Voice-note bubble UI + playback
**Files:** `lib/features/assistant/presentation/pages/chat_page.dart` (+ a small `VoiceNoteBubble` widget, possibly its own file), l10n; tests.
- An `AudioPlayer` (audioplayers) owned by ChatPage state (one reusable player; dispose it). A `VoiceNoteBubble` for **user** messages that have `audioPath != null`: a play/pause `IconButton` + a thin progress/duration line (Theme-styled, on the green user bubble) + the transcription text **below in a smaller, slightly muted style**. Messages without audioPath render as plain text (current behavior).
- Wire dictation: `onFinalDictation: (text, audioPath) { if (text.trim().isNotEmpty) provider.send(text, audioPath: audioPath); }`.
- l10n: `voiceNote` ("Voice note"/"Nota de voz"), `voiceNotePlay`/`voiceNotePause` if needed. gen-l10n.
- Tests: a user message with a fake audioPath renders the play control + the transcription text; without audioPath renders plain text. Keep existing green.
- `flutter build apk --debug` succeeds. Commit `feat(voice): voice-note bubble with audio playback + transcription`.

## Device verification (user, after VTask 3)
- Dictate a message → it should appear as a **voice note** you can play, with the text below. Play it back.
- If no audio appears (device couldn't record while recognizing) → the text still sends fine (best-effort fallback). Report which happened so we tune the recorder (audio source) or accept text-only on that device.
