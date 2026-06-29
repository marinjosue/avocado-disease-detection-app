# Asistente — Conversaciones persistentes · Implementation Plan

**Goal:** Que las conversaciones del asistente **se guarden** localmente (no se pierdan), con una **lista de conversaciones**, conversaciones **ligadas a una detección** (con su imagen) que se **continúan**, y opción de **borrar** (solo si el usuario quiere).

**Architecture:** Persistencia SQLite (migración v1→v2, solo AGREGA tablas — no toca detecciones). `Conversation` + mensajes serializados. `AssistantProvider` se reescribe para gestionar la lista + la conversación actual y persistir cada mensaje. Nueva `ConversationsListPage` (pestaña Asistente). El router Gemma/stub y el flujo de inferencia NO cambian.

## Global Constraints
- **No romper datos existentes**: la migración SQLite solo **crea** `conversations` + `conversation_messages` (con `onCreate` para instalación nueva y `onUpgrade` para la existente). NO alterar `detection_results`/`workspaces`.
- Mantener el `AssistantServiceRouter` (Gemma cuando hay modelo, stub si no) intacto.
- Contrato de clases `'healthy'/'mancha_negra'/'rona'` intacto. Todo del `Theme`. l10n ES/EN. **Sin co-autores de Claude** en commits.
- `detectionKey` de una conversación = el `imagePath` de la detección (único; sirve para cámara e historial).

## Tasks

### Task 1: Serialización + `imagePath` en el contexto
- `AssistantMessage`: agregar `Map<String,dynamic> toJson()` + `factory AssistantMessage.fromJson(Map)`.
- `AssistantContext`: agregar campo `String? imagePath`; incluirlo en `fromDetection` (`r.imagePath`); agregar `toJson()/fromJson()`.
- Tests de round-trip JSON.
- Commit: `feat(assistant): json serialization + imagePath in context`.

### Task 2: Modelo `Conversation` + migración SQLite + repositorio
- `lib/features/assistant/domain/conversation.dart`: `Conversation { int? id; String title; String? detectionKey; AssistantContext? context; DateTime createdAt; DateTime updatedAt; List<AssistantMessage> messages; copyWith(...) }`.
- `DatabaseHelper`: subir `version` 1→2; en `onCreate` y `onUpgrade(v1→v2)` crear:
  - `conversations(id INTEGER PK AUTOINCREMENT, title TEXT NOT NULL, detectionKey TEXT, contextJson TEXT, createdAt TEXT NOT NULL, updatedAt TEXT NOT NULL)`
  - `conversation_messages(id INTEGER PK AUTOINCREMENT, conversationId INTEGER NOT NULL, role TEXT NOT NULL, text TEXT NOT NULL, timestamp TEXT NOT NULL, FOREIGN KEY(conversationId) REFERENCES conversations(id))`
- `lib/features/assistant/data/conversation_repository.dart`: `createConversation`, `getConversations()` (orden `updatedAt DESC`, sin cargar mensajes — para la lista, con un preview opcional), `getConversation(int id)` (con mensajes), `getByDetectionKey(String key)`, `addMessage(int convId, AssistantMessage)`, `updateConversation(int id, {String? title, DateTime? updatedAt})`, `deleteConversation(int id)` (borra sus mensajes), `deleteAll()`.
- Dev dep `sqflite_common_ffi`; tests del repositorio con `databaseFactoryFfi` (crear, listar, getByDetectionKey, addMessage, delete, deleteAll). Para no chocar con el singleton `DatabaseHelper`, el repo debe aceptar una `Database` inyectable o usar `DatabaseHelper.instance.database` (en test, set `databaseFactory = databaseFactoryFfi` + `sqfliteFfiInit()` y usar una db temporal).
- Commit: `feat(assistant): conversation model + sqlite migration + repository`.

### Task 3: `AssistantProvider` reescrito (persistencia)
- Estado: `List<Conversation> conversations` (lista para la pestaña), `Conversation? current` (la abierta), `bool isThinking`. Mantener el `AssistantService` (router) inyectado y el `ConversationRepository`.
- `Future<void> loadConversations()`.
- `Future<Conversation> openOrCreateForDetection(AssistantContext ctx)`: busca por `detectionKey == ctx.imagePath`; si existe la carga (con mensajes) y la pone como `current`; si no, crea una nueva (title = nombre enfermedad · %, detectionKey = imagePath, context = ctx) y la persiste.
- `Future<Conversation> createGeneral()` (nueva conversación general; title inicial vacío/"Conversación") y `Future<Conversation> openConversation(int id)`.
- `Future<void> send(String text)`: agrega y **persiste** el mensaje del usuario; si es el primer mensaje de una conversación general, fija el title = primeras ~40 chars; marca `isThinking`; consume el router (`reply(prompt, context: current.context, history: prior)`) acumulando y al terminar **persiste** el mensaje del asistente; actualiza `updatedAt`; refresca la lista.
- `Future<void> deleteConversation(int id)`, `Future<void> deleteAll()`.
- Mantener el snapshot de history ANTES de agregar el mensaje del usuario.
- Tests con un repo fake/in-memory + un `AssistantService` fake.
- Commit: `feat(assistant): persistent conversations in AssistantProvider`.

### Task 4: `ConversationsListPage` + pestaña Asistente
- `lib/features/assistant/presentation/pages/conversations_list_page.dart`: `Consumer<AssistantProvider>` → lista (orden por fecha): cada ítem muestra título, preview/última actualización, y **miniatura de la imagen** si `detectionKey`/context.imagePath existe (con fallback). Tap → `openConversation(id)` y navega a `ChatPage`. Botón **"+ Nueva conversación"** (FAB) → `createGeneral()` → ChatPage. Borrar por ítem (icono/long-press) con **confirmación**; acción "Borrar todas" en el AppBar (confirmación). `EmptyState` si no hay conversaciones.
- `main_page.dart`: la destinación **Asistente** ahora muestra `ConversationsListPage` (en vez de `ChatPage` general). `loadConversations()` al entrar.
- l10n: `conversations`, `newConversation`, `noConversations`, `noConversationsMsg`, `deleteConversation`, `deleteConversationMsg`, `deleteAllConversations`, `deleteAllConversationsMsg`, `conversationDeleted`.
- Commit: `feat(assistant): conversations list page + tab`.

### Task 5: `ChatPage` reescrito + entradas desde detección
- `ChatPage` recibe `int conversationId` (en vez de context/greeting). En init carga la conversación del provider como `current` (si no está ya). Renderiza `current.messages` vía `Consumer`. Si `current.context?.imagePath != null`, muestra la **imagen** (miniatura) en la tarjeta de contexto + el `StatusBadge`. Persiste al enviar (vía provider.send). Mantiene disclaimer, streaming, "pensando", input, y el hueco `// Fase 2C: micrófono`.
- Cámara (`camera_page`) e Historial (`history_list_page`): "Preguntar a la IA" → `await provider.openOrCreateForDetection(AssistantContext.fromDetection(result, isSpanish: ...))` → `Navigator.push(ChatPage(conversationId: conv.id!))`.
- Commit: `feat(assistant): chat loads/persists conversation + shows detection image`.

## Notas
- Probar en device que el chat persiste tras cerrar/reabrir y que re-abrir un resultado continúa la misma conversación.
- La inferencia (Gemma) y el router no se tocan; solo se persiste alrededor.
