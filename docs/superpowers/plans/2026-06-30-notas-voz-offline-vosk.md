# Notas de voz offline con Vosk (audio + transcripción + respuesta IA) — Plan

> Subagent-driven. HIGH integration risk (native Vosk plugin). De-risk in AVTask 1 before building the rest. If Vosk cannot be made to load a model + transcribe PCM on the device, STOP and report — fall back to Option B (record-only memo) or C (cloud).

**Goal:** A WhatsApp-style voice note that is **saved as playable audio** AND **transcribed on-device (offline)** so the assistant answers it — from a **single microphone capture** (no STT/record mic contention).

**Key technique:** `record.startStream()` yields raw PCM16 mono @16 kHz. Each chunk is (a) appended to a buffer that becomes a **.wav** file (the playable note) and (b) fed to a **Vosk** recognizer for offline transcription. One mic consumer → no contention.

**Tech:** `vosk_flutter` (offline STT, feed PCM bytes) + existing `record` (startStream) + existing `audioplayers`/`VoiceNoteBubble`/`audioPath` infra.

## Global Constraints
- Package `aplication_tesis`. No `Co-Authored-By: Claude`. Spanish-first, Theme-only. Keep all tests green (151). analyze clean. Non-destructive to existing features. Dictation (STT-only 🎤) stays as-is; voice notes are a NEW, separate flow.
- Vosk model: **download-on-demand** via the plugin's model loader (small Spanish model), cached on device — no APK/git bloat. Needs internet ONCE (like the Gemma model), offline after.

## AVTask 1 — Vosk integration + transcriber (DE-RISK)
**Files:** `pubspec.yaml`; `lib/features/assistant/data/vosk_transcriber.dart`; a tiny throwaway verification.
- Add `vosk_flutter` (verify the exact current package name/version on pub; if `vosk_flutter` is stale, use the maintained fork e.g. `vosk_flutter_2` — record which). `flutter pub get`.
- `VoskTranscriber`: 
  - `Future<void> ensureModel({void Function(double)? onProgress})` — loads the small Spanish model via the plugin's loader (network URL `https://alphacephei.com/vosk/models/vosk-model-small-es-0.42.zip` or the plugin's `loadFromNetwork`/assets API — use whatever the package supports), caches it. `bool get isReady`.
  - `Future<void> startUtterance()` — create/reset a `Recognizer` at 16000 Hz.
  - `Future<void> acceptPcm(Uint8List bytes)` — feed a chunk.
  - `Future<String> finishUtterance()` — return the final transcript text (parse the JSON `text` field).
  - `void disposeTranscriber()`.
  - Verify the EXACT vosk_flutter API against the installed package (class names like `VoskFlutterPlugin.instance()`, `createModel`, `createRecognizer`, `acceptWaveformBytes`, `getFinalResult`) and adapt.
- **Verify:** `flutter analyze` clean + `flutter build apk --debug` succeeds (native Vosk links). If the plugin fails to build/link on Android, STOP and report the exact error (do not fake it).
- Commit `feat(voice): integrate Vosk offline transcriber`.

## AVTask 2 — Single-capture voice-note service (PCM → WAV + Vosk)
**Files:** `lib/features/assistant/data/voice_note_recorder_service.dart`; wire into `VoiceController`; tests (fakes).
- `VoiceNoteRecorderService`:
  - `Future<bool> start()` — `record.startStream(RecordConfig(encoder: AudioEncoder.pcm16bits, sampleRate: 16000, numChannels: 1))`; `transcriber.startUtterance()`; subscribe to the PCM stream: for each chunk → `_pcm.addAll(chunk)` (accumulate) AND `transcriber.acceptPcm(chunk)`. Return true if started.
  - `Future<({String? audioPath, String text})> stop()` — stop the record stream; `final text = await transcriber.finishUtterance();`; write the accumulated PCM to `<appDocs>/voice_notes/<ts>.wav` with a correct 44-byte WAV header (16-bit, 16 kHz, mono); return (path, text). On error → (null, '').
  - `Future<void> cancel()`.
- `VoiceController`: add `bool get isRecordingNote`, `Future<void> ensureVoiceModel(...)` (delegates to transcriber, exposes progress), `Future<void> startVoiceNote()`, `Future<({String? audioPath, String text})> stopVoiceNote()`. These are SEPARATE from `startDictation` (which stays STT-only). Do NOT run the system recognizer here.
- Tests: fake transcriber + fake recorder → start/stop returns (path, text); WAV header bytes correct (unit-test the header writer). Keep existing tests green.
- Commit `feat(voice): single-capture voice-note recorder (WAV + Vosk transcript)`.

## AVTask 3 — ChatPage voice-note UI + send
**Files:** `chat_page.dart`; l10n; tests.
- Add a **voice-note button** (a mic/record button distinct from the 🎤 dictation one — e.g. a second round button, or long-press). Tap → if `!voice.isReady` show a one-time "Descargando voz…" progress (via `ensureVoiceModel`), else `startVoiceNote()`; show **"Grabando… mm:ss"** with a stop button. Stop → `final r = await voice.stopVoiceNote(); if (r.text.trim().isNotEmpty || r.audioPath != null) provider.send(r.text, audioPath: r.audioPath);`.
- The existing `VoiceNoteBubble` already plays `audioPath` + shows the transcript below → the note appears WhatsApp-style, and because it now carries `text`, the assistant answers it (existing `send` streams a reply).
- l10n: `recordVoiceNote`, `recording`, `downloadingVoiceModel`. gen-l10n.
- Tests: tapping stop with a fake controller that returns (path, 'hola') calls `send('hola', audioPath: path)`. Keep existing green. `flutter build apk --debug` succeeds.
- Commit `feat(voice): record & send offline voice notes (audio + transcript + AI reply)`.

## Device verification (user)
- Tap the voice-note button → (first time) model downloads → record → speak → stop → your message appears as a **playable voice note with the transcript**, and the **AI answers** it. All offline after the one-time model download.
