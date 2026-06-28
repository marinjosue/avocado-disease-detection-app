# Fase 2 — Asistente IA con voz · Diseño (spec)

- **Fecha:** 2026-06-27
- **Estado:** En revisión (capa 2A lista para plan/implementación)
- **Proyecto:** avocadoIA (app de tesis, ESPE)
- **Enfoque elegido:** por capas (2A → 2B → 2C → 2D). Este spec detalla **2A**; 2B–2D se resumen y tendrán su propio spec.

---

## 1. Contexto y decisiones (ya acordadas en el brainstorming)

Agregar un **asistente conversacional** que explica el resultado del CNN y responde dudas de manejo del aguacate. Decisiones cerradas (ver memoria del proyecto):

- 🧠 **On-device por defecto (offline):** `flutter_gemma` + **Gemma 3 1B-IT** (texto, ~0.5 GB, descarga en primer arranque).
- 🧩 **"Multimodal efectivo":** al modelo se le inyecta como **texto** la etiqueta + % de confianza de la CNN, las recomendaciones y un resumen del historial. La imagen **no** va al LLM. **La CNN sigue siendo la fuente de verdad del diagnóstico; el LLM solo explica/conversa.**
- ☁️ **Nube opcional:** `firebase_ai` → Gemini cuando hay internet **y** el usuario la activa (desactivable).
- 🔊 **Voz completa:** `speech_to_text` (dictar) + `flutter_tts` (hablar), español, del sistema.
- 🚪 **Entradas:** botón "Preguntar a la IA" en Resultado + un acceso a "Asistente IA".
- 🛡️ **Salvaguardas:** temperatura baja, *grounding* al contexto, **disclaimer visible** ("orientativo, no sustituye a un agrónomo certificado").

---

## 2. Decomposición por capas

| Capa | Contenido | Riesgo | Verificable sin dispositivo |
|---|---|---|---|
| **2A** (este spec) | UI del chat + arquitectura `AssistantService` (con **stub** provisional) + inyección de contexto + entradas | Bajo | Sí (tests + analyze) |
| 2B | Conectar el modelo real on-device (`flutter_gemma` + Gemma 3 1B-IT + descarga) | Alto | Solo en el Pixel 8 |
| 2C | Voz (STT + TTS) sobre el chat | Medio | Parcial (en dispositivo) |
| 2D | Nube opcional (`firebase_ai` + toggle) — requiere proyecto Firebase del usuario | Medio | Con credenciales del usuario |

**Clave de 2A:** dejar la arquitectura "enchufable" para que en 2B/2D solo se cambie la implementación de `AssistantService`, sin tocar la UI.

---

## 3. Alcance de la capa 2A

### Dentro
- `AssistantService` (interfaz) + `StubAssistantService` (respuestas locales basadas en el contexto, sin red ni modelo).
- Modelos: `AssistantMessage`, `AssistantContext`.
- `AssistantProvider` (`ChangeNotifier`) para el estado del chat.
- `ChatPage` (UI del chat con el sistema de diseño).
- **Builder de contexto** desde un `DetectionResult` + `DetectionProvider` (stats/recientes).
- Entradas: botón **"Preguntar a la IA"** en el Resultado de detección + acceso desde el **Dashboard**.
- Disclaimer visible + l10n (ES/EN).

### Fuera (capas siguientes)
- El modelo real, la descarga, la voz y la nube. En 2A el `AssistantProvider` usa el **stub**.
- No se toca la CNN/DetectionService ni el contrato de clases.

---

## 4. Arquitectura (2A)

```
lib/features/assistant/
├── domain/
│   ├── assistant_message.dart      # {role: user|assistant, text, timestamp}
│   ├── assistant_context.dart      # {diseaseType?, confidence?, recommendation?, historySummary?}
│   └── assistant_service.dart      # abstract: Stream<String> reply(prompt, context, history)
├── data/
│   └── stub_assistant_service.dart # respuestas locales basadas en reglas + contexto
└── presentation/
    ├── providers/assistant_provider.dart  # ChangeNotifier: messages, send(), isThinking
    └── pages/chat_page.dart               # UI del chat
```

- **`AssistantService`** (interfaz): `Stream<String> reply({required String prompt, AssistantContext? context, List<AssistantMessage> history})` — devuelve la respuesta **en streaming** (tokens/trozos) para que la UI se sienta fluida. El stub emite la respuesta en pocos trozos con un pequeño delay simulado. (2B/2D implementan la misma interfaz.)
- **`AssistantContext`**: se construye desde un `DetectionResult` (tipo, confianza, `getRecommendationES/EN`) y/o un resumen del historial (`DetectionProvider.statistics`). Se serializa a un bloque de texto que el servicio antepone como *grounding*.
- **`AssistantProvider`**: mantiene `List<AssistantMessage>`, `isThinking`, el `AssistantContext` actual y un `AssistantService` inyectado (en 2A, `StubAssistantService`). `send(text)` agrega el mensaje del usuario, consume el stream del servicio y va actualizando el mensaje del asistente. Se registra en el `MultiProvider` de `main.dart`.
- **Stub brain (`StubAssistantService`)**: reglas simples para que se sienta real:
  - Si hay `context.diseaseType` y el usuario pregunta por tratamiento/gravedad/qué hacer → responde con la **recomendación de `DetectionResult`** + 1–2 frases de apoyo.
  - Saludo/uso general → presentación breve del asistente + el disclaimer.
  - Si no entiende → respuesta honesta de placeholder ("aún estoy aprendiendo…") con el disclaimer.
  - **Marcado claramente como provisional**; se reemplaza en 2B.

### UI — `ChatPage`
- AppBar "Asistente IA" (hereda el tema).
- **Banner de disclaimer** fijo arriba (`InfoHint`-style / tarjeta sutil): "orientativo, no sustituye a un agrónomo".
- Lista de **burbujas** de mensaje (usuario a la derecha con `colorScheme.primary`, asistente a la izquierda con `surface`/`card`). Texto del tema; el del asistente puede ir apareciendo (streaming).
- Si llegó con contexto de detección, una **tarjeta de contexto** arriba ("Hablando sobre: Roña · 87%").
- Campo de entrada (`InputDecorationTheme`) + botón enviar (`PrimaryButton`/icon). Indicador "pensando…" (`LoadingState`-style, 3 puntos).
- *(Hueco reservado para el micrófono 🎤 de la capa 2C — comentado, no implementado.)*

### Entradas a `ChatPage` (3, según lo pedido por el usuario)
1. **Menú (consulta general):** el Asistente es una **destinación de la barra inferior** ("Asistente IA"). En modo general el contexto es un **resumen del historial** (`DetectionProvider.statistics`).
2. **Tras analizar con la cámara:** en el Resultado de detección ([camera_page](lib/features/detection/presentation/pages/camera_page.dart)), el comentario `// Fase 2: ... Preguntar a la IA` se reemplaza por un `SecondaryButton(icon: Icons.smart_toy, label: l10n.askAI)` que abre `ChatPage` **a partir de esa imagen/resultado** (contexto = enfermedad + confianza + recomendación de esa detección).
3. **Historial:** en el detalle de una detección guardada ([history_list_page](lib/features/detection/presentation/pages/history_list_page.dart) `_showDetectionDetails`), un botón "Preguntar a la IA" abre `ChatPage` con el contexto de **ese resultado**.

> **Layout de la barra (6 destinos):** con el Asistente como destino, la barra inferior pasa de 5 a **6 destinos**. La **Cámara se mantiene como la acción central destacada**. Se reestructura a un `BottomAppBar` con muesca + **FAB central de Cámara** y los otros 5 destinos alrededor (Panel, Calculadora, Asistente | Historial, Configuración), o, si resulta más simple, 6 ítems con etiquetas cortas. El detalle exacto se decide en el plan; la cámara sigue siendo la acción central.

---

## 5. Internacionalización (2A)
Nuevas claves ES/EN: `assistant` ("Asistente IA"/"AI Assistant"), `askAI` ("Preguntar a la IA"/"Ask the AI"), `assistantDisclaimer`, `assistantHintGeneral`, `assistantTalkingAbout` ("Hablando sobre"), `chatInputHint` ("Escribe tu pregunta…"), `send`, `assistantThinking`, `assistantPlaceholderReply`. Regenerar con `flutter gen-l10n`.

---

## 6. Invariantes
- No tocar `DetectionService` (sigue mock), `DatabaseHelper`, modelos de detección, ni el contrato `'healthy'/'mancha_negra'/'rona'`.
- Todo lee del `Theme`/componentes (sin `Color`/`fontSize` hardcodeados).
- La capa 2A no añade dependencias pesadas (nada de `flutter_gemma`/`firebase_ai`/voz todavía); solo código Dart + provider.

---

## 7. Criterios de aceptación (2A)
- [ ] El Asistente es accesible desde el **menú inferior** (consulta general), con la Cámara aún como acción central destacada.
- [ ] Desde el **Resultado de la cámara**, "Preguntar a la IA" abre el chat con el contexto de esa detección (enfermedad + confianza) visible.
- [ ] Desde el **detalle en Historial**, "Preguntar a la IA" abre el chat con el contexto de ese resultado.
- [ ] El chat envía mensajes y el asistente responde (stub) en streaming, con indicador "pensando".
- [ ] El disclaimer es visible en el chat.
- [ ] Funciona en claro y oscuro; sin `AppColors`/estilos inline.
- [ ] `flutter analyze` sin issues; `flutter test` verde (incluye tests del provider/stub y un widget test del chat).
- [ ] La interfaz `AssistantService` permite enchufar otra implementación sin tocar la UI (verificado por el diseño del provider).

---

## Apéndice — capas siguientes (resumen, spec propio)
- **2B:** `GemmaAssistantService` con `flutter_gemma` + Gemma 3 1B-IT; pantalla/flow de **descarga del modelo** (solo WiFi, progreso, reanudable); detección de capacidad del dispositivo; system prompt + inyección de contexto real; streaming token-a-token; temperatura ~0.2–0.4.
- **2C:** Voz — `speech_to_text` (botón 🎤 → dictado) + `flutter_tts` (leer la respuesta), español; toggles en Configuración.
- **2D:** Nube opcional — `firebase_ai` → Gemini cuando online + activado; requiere proyecto Firebase del usuario (`google-services.json`); toggle desactivable en Configuración para preservar el modo offline.
