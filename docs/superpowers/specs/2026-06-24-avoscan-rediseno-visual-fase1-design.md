# Diseño — Fase 1: Rediseño visual de AvoScan AI

- **Fecha:** 2026-06-24
- **Estado:** Aprobado para implementación (pendiente revisión final del spec)
- **Proyecto:** AvoScan AI (app de tesis, ESPE) — detección de enfermedades del aguacate
- **Alcance de este documento:** Fase 1 (capa visual + tema + accesibilidad). La Fase 2 (asistente IA + voz) tiene su propio spec; se resume en el Apéndice.

---

## 1. Contexto y objetivo

La app está en su base V1: funcional pero con un look **genérico de Material** (estilos `fontSize`/`Color` inline repartidos por las pantallas, sin sistema de diseño, sin jerarquía fuerte ni estados vacíos cuidados). El objetivo de la Fase 1 es elevarla a un nivel **profesional y defendible en tesis**, con tres pilares:

1. **Identidad visual coherente** basada en la dirección **"C — Data-Forward Pro"** (panel analítico nítido, jerarquía tipográfica fuerte, verde profundo).
2. **Tema claro y oscuro** conmutables.
3. **UI descriptiva y accesible** para usuarios con poca familiaridad tecnológica (agricultores).

**Invariante clave:** la Fase 1 es **solo capa visual/UX**. No cambia la lógica de negocio, la base de datos, ni el contrato de clases de enfermedad. El modelo ML sigue *mock*; Firebase/auth siguen sin cablear.

---

## 2. Decisiones acordadas (resumen)

| Tema | Decisión |
|---|---|
| Estilo visual | C — Data-Forward Pro |
| Tema | Claro + Oscuro + Automático (sigue al sistema), conmutable y persistido |
| Accesibilidad | UI descriptiva para no técnicos (texto+ícono, lenguaje simple, ayudas, onboarding) |
| Idiomas | Se mantiene ES/EN (ES por defecto) |
| Dispositivo objetivo | Android gama media (4–6 GB) — sin animaciones costosas |
| Fuera de Fase 1 | Chat IA, voz, nube, modelo ML real, Firebase auth |

---

## 3. Alcance

### Dentro de la Fase 1
- Sistema de diseño (tokens, tipografía, espaciado, `ThemeData` claro/oscuro).
- Componentes reutilizables en `lib/core/widgets/`.
- `ThemeProvider` (modo claro/oscuro/auto) + toggle en Configuración.
- Rediseño de las 6 vistas: Dashboard, Calculadora, Cámara/Detección, **Resultado de detección**, Historial, Configuración + la `BottomNavigationBar`.
- Onboarding de primer uso (saltable).
- Estados vacíos, de carga y de error descriptivos.
- Nuevas cadenas de localización (ES/EN) para textos descriptivos y onboarding.

### Fuera de la Fase 1 (no tocar)
- `DetectionService` (sigue mock), `DatabaseHelper` (esquema intacto), modelos de datos, Firebase.
- Cualquier funcionalidad de Fase 2.

---

## 4. Sistema de diseño

### 4.1 Tokens de color

**Tema claro** (de la dirección C):

| Token | Hex |
|---|---|
| primary | `#1F6B3B` |
| primaryDark | `#0E2E1C` |
| accent (secondary) | `#26C281` |
| background | `#F4F6F5` |
| surface / card | `#FFFFFF` |
| textPrimary | `#0E1C14` |
| textSecondary | `#6B7B73` |
| healthy | `#22A565` |
| manchaNegra | `#3A3F45` |
| rona | `#E0962F` |
| success/warning/error/info | `#22A565` / `#E0962F` / `#E5484D` / `#3A8DDE` |

**Tema oscuro** (propuesto; ajustable en implementación, validar contraste AA):

| Token | Hex |
|---|---|
| primary | `#34B36A` (verde aclarado para contraste sobre oscuro) |
| primaryDark (app bar) | `#0E2E1C` |
| accent (secondary) | `#2FD08C` |
| background | `#0E1311` |
| surface | `#161D19` |
| card | `#1C2521` |
| textPrimary | `#ECF2EE` |
| textSecondary | `#9CB0A6` |
| healthy | `#34C77D` |
| manchaNegra | `#AEB4BA` (gris claro para verse sobre fondo oscuro) |
| rona | `#F0A94A` |

**Regla:** los componentes **nunca** usan `Color` fijos; leen del `ColorScheme`/`ThemeExtension`. Los tres colores de enfermedad se exponen vía un `ThemeExtension<DiseaseColors>` para que cambien con el tema y se mapeen por la clave de clase (`healthy`/`mancha_negra`/`rona`).

### 4.2 Tipografía

- Fuente: **Inter**, **empaquetada en `assets/fonts/`** y declarada en `pubspec.yaml` (no se descarga en runtime — coherente con el enfoque offline; Inter es SIL OFL, libre). Con *tabular numerals* (`fontFeatures: [FontFeature.tabularFigures()]`) para todas las cifras (conteos, %, fechas).
- Fallback: `system-ui`, sans-serif.
- Escala (mapeada al `TextTheme` de Material 3):

| Rol | Slot | Tamaño / Peso |
|---|---|---|
| Título de pantalla (hero) | `headlineMedium` | 26 / w800 |
| Título AppBar | `titleLarge` | 20 / w700 |
| Encabezado de sección | `labelLarge` | 13 / w600, mayúsculas, tracking +0.08em, color secundario |
| Cifra de métrica | `displaySmall` | 28–34 / w700, tabular |
| Cuerpo | `bodyMedium` | 14.5 / w500 |
| Cuerpo secundario / caption | `bodySmall` | 12.5 / w500, color secundario |
| Texto de botón | `labelLarge` | 15 / w700 |

### 4.3 Espaciado, radios y elevación

- **Espaciado** (escala de 4): `4, 8, 12, 16, 20, 24, 32`. Padding de pantalla: 16; gap entre cards: 12.
- **Radios:** `sm 8`, `md 12` (cards), `lg 16` (hojas/diálogos), `pill 999` (chips/botones redondeados).
- **Elevación/sombra:** cards con sombra sutil (`y=4, blur=14, color negro 6–8%` en claro; en oscuro, borde `1px` sutil en vez de sombra). Centralizado como un helper de decoración.

### 4.4 Theming

- Un único punto de verdad: `lib/core/theme/app_theme.dart` con `AppTheme.light` y `AppTheme.dark` (`ThemeData`, Material 3), construidos desde los tokens. Incluye `appBarTheme`, `cardTheme`, `elevatedButtonTheme`, `outlinedButtonTheme`, `inputDecorationTheme`, `bottomNavigationBarTheme`, `chipTheme`, `dividerTheme`, `textTheme`.
- `lib/core/constants/colors.dart` se **reemplaza** por `app_tokens.dart` (paleta cruda claro/oscuro) + `disease_colors.dart`; las pantallas dejan de importar `AppColors` y leen del `Theme`. (Puede mantenerse un alias temporal de `AppColors` para migrar pantalla por pantalla.)
- `main.dart` consume `themeMode` desde `ThemeProvider` y pasa `theme`/`darkTheme` a `MaterialApp`.

### 4.5 Componentes reutilizables (`lib/core/widgets/`)

Cada uno como widget aislado, sin lógica de negocio, configurable por parámetros y sin colores fijos:

- `AppScaffold` — Scaffold con AppBar estilizada + slot de banner offline (reutiliza el existente).
- `StatCard({icon, label, value, accentColor})` — tarjeta de métrica del Dashboard.
- `SectionHeader({title, action?})` — encabezado de sección.
- `DetectionTile({result, onTap})` — ítem de actividad/historial: color e ícono por enfermedad + chip de confianza + tiempo relativo.
- `ConfidenceBar({value})` — barra de confianza 0–100% con color por nivel.
- `AppChip` / `StatusBadge({diseaseType})` — etiqueta/píldora coloreada por clase.
- `DonutChart({sections, legend})` — wrapper de `fl_chart` (PieChart) con leyenda y centro.
- `PrimaryButton` / `SecondaryButton` — botones grandes (alto ≥ 48dp), con ícono opcional.
- `EmptyState({icon, title, message, actionLabel?, onAction?})` — estados vacíos que enseñan.
- `LoadingState` / `ErrorState` — estados de carga y error consistentes.
- `InfoHint({term, explanation})` — ícono "?" que abre un tooltip/bottom-sheet explicando un término técnico.

---

## 5. Tema claro / oscuro

- Nuevo `lib/core/providers/theme_provider.dart` (`ChangeNotifier`), espejo de `LocaleProvider`:
  - Estado: `ThemeMode` (`system` | `light` | `dark`), por defecto `system`.
  - Persistencia en `SharedPreferences` bajo la clave `themeMode`.
  - Se registra en el `MultiProvider` de `main.dart`.
- **Toggle en Configuración:** selector de 3 opciones (Automático / Claro / Oscuro) con descripción.
- Criterio: ambos temas deben pasar contraste **WCAG AA** en texto principal y botones.

---

## 6. Accesibilidad y UI descriptiva (principio transversal)

Patrones obligatorios en todas las pantallas:

1. **Texto + ícono siempre.** Ningún ícono-acción sin etiqueta visible o `Semantics`/tooltip.
2. **Lenguaje simple en español**, sin jerga. Términos técnicos explicados con `InfoHint`, p. ej. *"Confianza: qué tan seguro está el análisis (0–100%)."*
3. **Estados vacíos que enseñan**, con acción: *"Aún no tienes análisis. Toca la cámara para tomar tu primera foto."*
4. **Áreas táctiles grandes** (≥ 48dp), botones primarios anchos, buen contraste.
5. **Confirmaciones claras** antes de acciones destructivas (borrar historial / un análisis): diálogo con consecuencia explícita.
6. **`Semantics`** en elementos no textuales clave para lectores de pantalla (TalkBack).
7. **Sin dependencia del color solo**: el estado de enfermedad se comunica con color **+** ícono **+** texto.

### 6.1 Onboarding de primer uso
- 3 pantallas simples, **saltable** ("Saltar" siempre visible) y con indicador de paso:
  1. **Bienvenida:** qué hace AvoScan (detecta Mancha Negra y Roña en aguacate con una foto).
  2. **Cómo tomar una buena foto:** buena luz, acercar el fruto, enfocar, fondo simple.
  3. **Qué verás:** resultado + recomendaciones, historial y estadísticas.
- Se muestra una sola vez; flag `onboarding_seen` en `SharedPreferences`. Re-accesible desde Configuración ("Ver tutorial de nuevo").
- Implementado como ruta previa a `MainPage` cuando el flag es falso.

---

## 7. Rediseño por pantalla

> Todas heredan el tema y usan los componentes; se eliminan estilos inline.

1. **Dashboard** — layout del mockup C: 4 `StatCard` (2×2), `SectionHeader` "Distribución" + `DonutChart` con leyenda, `SectionHeader` "Actividad reciente" + lista de `DetectionTile`. `EmptyState` cuando no hay datos.
2. **Resultado de detección** — foto analizada, banner de resultado (color por clase) + `ConfidenceBar`, tarjeta "Recomendaciones" (viñetas legibles), `PrimaryButton` "Guardar" / `SecondaryButton` "Nueva detección". **Reservar un espacio** para el futuro botón "Preguntar a la IA" (Fase 2) sin implementarlo.
3. **Cámara/Detección** — acciones grandes "Tomar foto" / "Elegir de galería" con ícono+texto, guía breve de encuadre, y estado **"Analizando…"** claro (`LoadingState`).
4. **Calculadora** — campos con `InputDecorationTheme`, etiquetas descriptivas y ayuda; resultados con componentes nuevos y explicación de cada índice.
5. **Historial** — lista de `DetectionTile`, `EmptyState`, confirmación al borrar, formato de fecha legible.
6. **Configuración** — secciones: **Apariencia** (tema claro/oscuro/auto), **Idioma** (ES/EN), **Ayuda** (ver tutorial), **Acerca de**. Deja huecos preparados para los toggles de Fase 2 (voz, nube) sin crearlos.
7. **BottomNavigationBar** — restyle según el tema, con la **cámara central elevada**; etiquetas visibles en las 5 pestañas.

---

## 8. Internacionalización

- Se agregan cadenas nuevas a `lib/l10n/app_es.arb` y `app_en.arb` para: textos descriptivos, ayudas (`InfoHint`), estados vacíos, onboarding, etiquetas de tema, confirmaciones.
- Regenerar con `flutter gen-l10n`.
- Las recomendaciones por enfermedad siguen donde están hoy (métodos en `DetectionResult`); no se migran en Fase 1 (evitar alcance extra), pero los textos de UI nuevos sí van en ARB.

---

## 9. Restricciones técnicas / invariantes

- **No cambiar** el contrato de clases: literales `'healthy'`, `'mancha_negra'`, `'rona'` en servicio, modelo, DB, estadísticas.
- **No cambiar** la lógica de `DetectionProvider`, `DatabaseHelper`, modelos ni servicios.
- Mantener `provider` como gestión de estado (agregar solo `ThemeProvider`).
- Rendimiento: evitar animaciones costosas; objetivo fluido en gama media.
- Compatibilidad: la app sigue compilando y los flujos actuales siguen funcionando tras cada pantalla migrada.

---

## 10. Estructura de archivos (nueva/cambiada)

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_theme.dart          # NUEVO: ThemeData light/dark
│   │   ├── app_tokens.dart         # NUEVO: tokens color/espaciado/radio
│   │   └── disease_colors.dart     # NUEVO: ThemeExtension por clase
│   ├── constants/colors.dart       # refactor → tokens (o reemplazado)
│   ├── providers/theme_provider.dart  # NUEVO
│   └── widgets/                    # NUEVOS componentes (sección 4.5)
├── features/
│   ├── onboarding/                 # NUEVO: páginas de onboarding
│   ├── dashboard/ ... settings/    # pantallas migradas al tema/componentes
└── main.dart                        # registra ThemeProvider, theme/darkTheme, ruta onboarding
```

---

## 11. Criterios de aceptación

- [ ] Existe un `ThemeData` claro y oscuro; cambiar el modo en Configuración actualiza toda la app al instante y **persiste** tras reiniciar.
- [ ] Ninguna pantalla usa `Color(...)` o `fontSize` inline; todo proviene del tema/componentes.
- [ ] Las 6 vistas + BottomNav reflejan el estilo C y se ven correctas en **claro y oscuro**.
- [ ] Cada pantalla tiene estados vacío/carga/error descriptivos donde aplica.
- [ ] Onboarding aparece en el primer arranque, es saltable y no reaparece; re-accesible desde Configuración.
- [ ] Términos técnicos visibles tienen ayuda (`InfoHint`); el estado de enfermedad se comunica con color + ícono + texto.
- [ ] Botones primarios ≥ 48dp; contraste AA en texto principal.
- [ ] Las cadenas nuevas están en ES y EN; `flutter analyze` sin nuevos warnings; la app compila y los flujos existentes funcionan.
- [ ] El contrato de clases de enfermedad permanece intacto.

---

## 12. Riesgos

- **Deriva de alcance** hacia lógica/funcionalidad: mitigar manteniendo el invariante "solo visual".
- **Contraste en modo oscuro** de los colores de enfermedad (sobre todo Mancha Negra): validar y ajustar tokens oscuros.
- **`fl_chart`** y colores del tema: asegurar que el donut lee del tema.
- **Fuente Inter:** debe quedar **empaquetada** (no descargada) para mantener el espíritu offline; ya contemplado en §4.2 (licencia SIL OFL, libre).

---

## Apéndice — Fase 2 (resumen; spec propio aparte)

Asistente IA + voz, **on-device por defecto**:
- `flutter_gemma` + **Gemma 3 1B-IT** (texto, ~0.5 GB, descarga en primer arranque).
- **"Multimodal efectivo":** se inyecta como contexto la etiqueta + confianza de la CNN + historial SQLite (la imagen no va al LLM).
- **Nube opcional** (`firebase_ai` → Gemini Flash) cuando hay internet y el usuario la activa; desactivable.
- **Voz completa:** `speech_to_text` + `flutter_tts` (ES, offline).
- Dos entradas: botón "Preguntar a la IA" en Resultado, y pestaña Asistente (conocimiento + datos del usuario).
- Salvaguardas: temperatura baja, *grounding* al contexto, disclaimer visible.

Detalle completo y plan en el spec de Fase 2.
