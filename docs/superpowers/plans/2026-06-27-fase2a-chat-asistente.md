# Fase 2A — Chat del Asistente IA (stub) · Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: superpowers:subagent-driven-development. Steps use checkbox (`- [ ]`).

**Goal:** Construir el chat del Asistente IA con arquitectura enchufable (`AssistantService` + **stub**), inyección de contexto, y las 3 entradas (menú, resultado de cámara, detalle de historial) — sin modelo real, voz ni nube todavía.

**Architecture:** Feature nueva `lib/features/assistant/`. Una interfaz `AssistantService` con `StubAssistantService` (respuestas locales en streaming). `AssistantProvider` (ChangeNotifier) maneja la conversación. `ChatPage` (UI). En 2B/2D solo se cambia la implementación de `AssistantService`.

**Tech Stack:** Flutter 3.44 Material 3, provider, componentes y tema de Fase 1, l10n ARB. **Sin dependencias nuevas.**

## Global Constraints

- **Solo agrega la feature del asistente.** NO tocar `DetectionService`, `DatabaseHelper`, modelos de detección ni el contrato `'healthy'/'mancha_negra'/'rona'`.
- **Sin dependencias pesadas** en 2A: nada de `flutter_gemma`/`firebase_ai`/`speech_to_text`/`flutter_tts`. Solo Dart + provider.
- Todo lee del **`Theme`**/componentes de Fase 1 (sin `Color`/`fontSize` hardcodeados; `withValues(alpha:)`).
- Texto visible vía **l10n ES/EN** (los widgets reciben texto del caller, no hardcodean español).
- **La CNN es la fuente de verdad del diagnóstico**; el asistente solo explica/conversa. Disclaimer visible siempre.
- `flutter analyze` sin issues y `flutter test` verde tras cada tarea.

## File Structure

```
lib/features/assistant/
├── domain/
│   ├── assistant_message.dart
│   ├── assistant_context.dart
│   └── assistant_service.dart        # abstract
├── data/
│   └── stub_assistant_service.dart
└── presentation/
    ├── providers/assistant_provider.dart
    └── pages/chat_page.dart
lib/l10n/app_{es,en}.arb               # claves nuevas
lib/main.dart                          # registrar AssistantProvider
lib/features/main/.../main_page.dart   # destino "Asistente" en la barra
lib/features/detection/.../camera_page.dart        # botón "Preguntar a la IA"
lib/features/detection/.../history_list_page.dart  # botón "Preguntar a la IA"
```

---

### Task 1: Cadenas l10n del asistente

**Files:** Modify `lib/l10n/app_es.arb`, `app_en.arb`; run `flutter gen-l10n`.

**Produces (claves):** `assistant`, `navAssistant`, `askAI`, `assistantDisclaimer`, `assistantTalkingAbout`, `assistantGeneralGreeting`, `chatInputHint`, `send`, `assistantThinking`, `assistantPlaceholderReply`.

- [ ] **Step 1:** Add to BOTH arb files (English in en, Spanish in es), valid JSON. Suggested values:
  - en: `assistant`="AI Assistant", `navAssistant`="Assistant", `askAI`="Ask the AI", `assistantDisclaimer`="Guidance only — not a substitute for a certified agronomist.", `assistantTalkingAbout`="About", `assistantGeneralGreeting`="Hi! Ask me about avocado diseases, treatments, or your orchard.", `chatInputHint`="Type your question…", `send`="Send", `assistantThinking`="Thinking…", `assistantPlaceholderReply`="I'm still learning. For now I can explain detection results and general care."
  - es: `assistant`="Asistente IA", `navAssistant`="Asistente", `askAI`="Preguntar a la IA", `assistantDisclaimer`="Orientativo — no sustituye a un agrónomo certificado.", `assistantTalkingAbout`="Sobre", `assistantGeneralGreeting`="¡Hola! Pregúntame sobre enfermedades del aguacate, tratamientos o tu huerto.", `chatInputHint`="Escribe tu pregunta…", `send`="Enviar", `assistantThinking`="Pensando…", `assistantPlaceholderReply`="Aún estoy aprendiendo. Por ahora puedo explicar resultados de detección y cuidados generales."
- [ ] **Step 2:** `flutter gen-l10n` (no errors). **Step 3:** `flutter analyze` clean. Commit: `feat(l10n): assistant strings`.

---

### Task 2: Dominio — modelos + interfaz + contexto

**Files:** Create `lib/features/assistant/domain/assistant_message.dart`, `assistant_context.dart`, `assistant_service.dart`. Test `test/features/assistant/assistant_context_test.dart`.

**Interfaces — Produces:**
- `enum AssistantRole { user, assistant }`
- `class AssistantMessage { final AssistantRole role; final String text; final DateTime timestamp; const AssistantMessage(...); AssistantMessage copyWith({String? text}); }`
- `class AssistantContext { final String? diseaseType; final double? confidence; final String? recommendation; final String? historySummary; const AssistantContext({...}); factory AssistantContext.fromDetection(DetectionResult r, {required bool isSpanish}); factory AssistantContext.fromHistory({int total, int healthy, int manchaNegra, int rona, required bool isSpanish}); String toGroundingText(); bool get hasDetection => diseaseType != null; }`
  - `toGroundingText()` arma un bloque de texto que el servicio antepone (p. ej. "Contexto: la CNN detectó {nombre} con {conf}% de confianza. Recomendación: {rec}.").
- `abstract class AssistantService { Stream<String> reply({required String prompt, AssistantContext? context, List<AssistantMessage> history = const []}); }`

- [ ] **Step 1: Failing test** — `AssistantContext.fromDetection(DetectionResult(diseaseType:'rona', confidence:0.87, imagePath:'x', timestamp: DateTime(2026)), isSpanish:true)` → `hasDetection==true`, and `toGroundingText()` contains "Roña" and "87".
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implement the three files. `fromDetection` uses `r.getDiseaseNameES()/EN()` and `r.getRecommendationES()/EN()` and `(r.confidence*100).round()`.
- [ ] **Step 4:** Run test → PASS. **Step 5:** Commit: `feat(assistant): domain models + AssistantService interface`.

---

### Task 3: StubAssistantService + AssistantProvider

**Files:** Create `lib/features/assistant/data/stub_assistant_service.dart`, `lib/features/assistant/presentation/providers/assistant_provider.dart`; Modify `lib/main.dart` (register provider). Tests `test/features/assistant/stub_assistant_service_test.dart`, `test/features/assistant/assistant_provider_test.dart`.

**Interfaces — Produces:**
- `class StubAssistantService implements AssistantService` — rule-based streaming:
  - If `context?.hasDetection == true` and prompt mentions treatment/severity/qué/cómo → stream the `context.recommendation` (split into chunks) + a short closing sentence.
  - Else → stream a short canned reply (use a provided default text) + remind it's a placeholder.
  - Emit in 2–4 chunks via an `async*` generator with tiny `await Future.delayed(Duration(milliseconds: 120))` between chunks (so the UI shows streaming). Keep deterministic enough to test.
- `class AssistantProvider extends ChangeNotifier { AssistantProvider(this._service); final AssistantService _service; List<AssistantMessage> get messages; bool get isThinking; AssistantContext? get context; void startSession({AssistantContext? context, String? greeting}); Future<void> send(String text); void clear(); }`
  - `startSession` resets messages (optionally seeds an assistant greeting) and sets the context.
  - `send` appends the user message, sets `isThinking`, consumes `_service.reply(...)` accumulating into a single growing assistant message (notifyListeners per chunk), then `isThinking=false`.

- [ ] **Step 1: Failing tests** — (a) Stub: given a detection context + "¿cómo lo trato?", the concatenated stream contains part of the recommendation. (b) Provider: `send('hola')` ends with `messages.last.role == assistant`, `isThinking==false`, and ≥2 messages.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implement service + provider. Register `ChangeNotifierProvider(create: (_) => AssistantProvider(StubAssistantService()))` in `main.dart`'s `MultiProvider` (keep the other 4 providers).
- [ ] **Step 4:** Run tests + `flutter analyze`. **Step 5:** Commit: `feat(assistant): stub service + AssistantProvider`.

---

### Task 4: ChatPage (UI)

**Files:** Create `lib/features/assistant/presentation/pages/chat_page.dart`. Test `test/features/assistant/chat_page_test.dart`.

**Interfaces:** `class ChatPage extends StatelessWidget { const ChatPage({super.key, this.context, this.greeting}); final AssistantContext? context; final String? greeting; }` — on first build it calls `AssistantProvider.startSession(context:, greeting:)` (guarded so it runs once).

- [ ] **Step 1: Failing widget test** — pump `ChatPage` inside `MaterialApp(localizationsDelegates, theme: AppTheme.light, home: ChangeNotifierProvider<AssistantProvider>(create: (_) => AssistantProvider(StubAssistantService()), child: const ChatPage()))`; assert the disclaimer text and the input hint render; type into the field and tap send → after `pumpAndSettle`, at least one user bubble with the typed text appears.
- [ ] **Step 2:** Run → FAIL.
- [ ] **Step 3:** Implement: `AppScaffold`/Scaffold AppBar `l10n.assistant`; a top disclaimer card (`l10n.assistantDisclaimer`, subtle, uses `colorScheme`); if `context?.hasDetection==true`, a small context chip "(`l10n.assistantTalkingAbout`) {diseaseName} · {conf}%" via `StatusBadge`/`AppChip`; a `ListView` of message bubbles (user → right, `colorScheme.primary`/`onPrimary`; assistant → left, `surfaceContainer`/`onSurface`) using `Consumer<AssistantProvider>`; an "isThinking" indicator bubble; a bottom input row (`TextField` with `l10n.chatInputHint` + send `IconButton`/`PrimaryButton`). Auto-scroll to bottom on new messages. *(Reserve a commented `// Fase 2C: botón de micrófono 🎤` next to the input — not implemented.)* All from `Theme`.
- [ ] **Step 4:** Run test + `flutter analyze`. **Step 5:** Commit: `feat(assistant): ChatPage UI`.

---

### Task 5: Destino "Asistente" en la barra inferior (6 destinos)

**Files:** Modify `lib/features/main/presentation/pages/main_page.dart`. Test: update/extend if a nav test exists (else build-smoke).

- [ ] **Step 1:** Add `ChatPage` (general mode) as a 6th destination. Restructure the bottom bar to hold **6 destinations** while keeping **Cámara as the prominent central action**. Preferred: a `BottomAppBar` with a center notch + `FloatingActionButton` for Cámara, and the other 5 destinations (Panel, Calculadora, Asistente, Historial, Configuración) as bar items split around the notch; `floatingActionButtonLocation: centerDocked`. If that proves fiddly, fall back to a 6-item `BottomNavigationBar` with short labels (`navAssistant`="Asistente"). Either way: preserve the `_pages`/index switching, the offline banner, and add the Assistant page to `_pages`. When the Assistant tab is shown, it opens `ChatPage` in general mode (`startSession` with a history-summary context + `l10n.assistantGeneralGreeting`).
- [ ] **Step 2:** `flutter analyze` + `flutter test`. Commit: `feat(nav): add Assistant destination (camera stays central)`.

**Acceptance:** Los 6 destinos son accesibles; la Cámara sigue siendo la acción central; el banner offline funciona; cambiar de pestaña conserva el estado.

---

### Task 6: Entradas contextuales (Resultado de cámara + detalle de Historial)

**Files:** Modify `lib/features/detection/presentation/pages/camera_page.dart` and `history_list_page.dart`.

- [ ] **Step 1 (cámara):** En el panel de resultado, reemplazar el comentario `// Fase 2: ... Preguntar a la IA` por un `SecondaryButton(icon: Icons.smart_toy, label: l10n.askAI, onPressed: ...)` que hace `Navigator.push(MaterialPageRoute(builder: (_) => ChatPage(context: AssistantContext.fromDetection(result, isSpanish: l10n.localeName=='es'))))`.
- [ ] **Step 2 (historial):** En `_showDetectionDetails`, añadir un botón "Preguntar a la IA" (`l10n.askAI`) en las acciones del diálogo que cierra el diálogo y hace el mismo `Navigator.push` con `AssistantContext.fromDetection(detection, isSpanish: ...)`.
- [ ] **Step 3:** `flutter analyze` + `flutter test`. Commit: `feat(assistant): contextual entries from result + history`.

**Acceptance:** Desde un resultado de cámara y desde el detalle de una detección guardada se abre el chat con el contexto de esa detección visible.

---

## Self-Review
- Cobertura del spec 2A: arquitectura enchufable (T2/T3), stub (T3), ChatPage (T4), inyección de contexto (T2 builder + T4 chip + T6 entradas), 3 entradas (T5 menú + T6 cámara/historial), l10n (T1), disclaimer (T4). ✔
- Placeholders intencionales: el `// Fase 2C: micrófono` en ChatPage (no implementado en 2A).
- Invariante: ninguna tarea toca detección/DB/contrato; sin deps nuevas.
- Tipos consistentes: `AssistantService.reply` (T2) usado por stub (T3) y provider (T3); `AssistantContext.fromDetection` (T2) usado en T6.

## Capas siguientes (recordatorio)
2B modelo real (`flutter_gemma`+Gemma 3 1B-IT+descarga), 2C voz (STT/TTS), 2D nube (`firebase_ai`) — cada una con su spec/plan.
