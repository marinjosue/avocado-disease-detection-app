# AvoScan AI - Detección de Enfermedades en Aguacate

## 📋 Descripción

Sistema de detección temprana de **Mancha Negra** y **Roña** en aguacate mediante redes neuronales convolucionales (CNN). Esta aplicación móvil utiliza visión por computadora y transfer learning para identificar patrones visuales característicos de cada patología en frutos de aguacate.

## 🎯 Características Principales

✅ **Detección en Tiempo Real**
- Análisis de imágenes mediante CNN
- Funcionamiento online y offline
- Modelo optimizado para dispositivos móviles

✅ **Dashboard Interactivo**
- Estadísticas de detecciones
- Gráficos visuales (pie charts)
- Análisis de tendencias

✅ **Historial Completo**
- Base de datos local (SQLite)
- Almacenamiento de imágenes
- Exportación de datos

✅ **Calculadora de Salud**
- Cálculo de índices fitosanitarios
- Porcentajes de incidencia
- Recomendaciones automáticas

✅ **Multiidioma**
- Español
- Inglés

✅ **Recomendaciones Inteligentes**
- Consejos específicos por enfermedad
- Guías de manejo integrado
- Tratamientos recomendados

## 🚀 Comenzar

### Prerequisitos

- Flutter SDK (>=3.9.2)
- Dart SDK
- Android Studio / VS Code
- Dispositivo Android/iOS o emulador

### Instalación

1. **Clonar el repositorio**
```bash
cd avocado-disease-detection-app
```

2. **Instalar dependencias**
```bash
flutter pub get
```

3. **Ejecutar la aplicación**
```bash
flutter run
```

## 🧠 Integración del Modelo ML

**IMPORTANTE**: El modelo de Machine Learning debe ser convertido de `.ckpt` a `.tflite` antes de su uso.

Ver instrucciones completas en: [MODELO_ML_INTEGRATION.md](MODELO_ML_INTEGRATION.md)

Pasos resumidos:
1. Convertir modelo .ckpt a TensorFlow Lite (.tflite)
2. Colocar el archivo en `assets/models/`
3. Agregar dependencia `tflite_flutter`
4. Actualizar `DetectionService`

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   ├── constants/          # Colores, constantes
│   ├── database/          # SQLite database helper
│   ├── models/            # Modelos de datos
│   ├── providers/         # Providers globales
│   └── widgets/           # Widgets reutilizables
├── features/
│   ├── auth/             # Autenticación (Firebase)
│   ├── dashboard/        # Dashboard con estadísticas
│   ├── detection/        # Detección de enfermedades
│   │   ├── data/
│   │   │   └── services/ # DetectionService (ML)
│   │   └── presentation/
│   │       ├── pages/    # Camera, History
│   │       └── providers/
│   ├── calculator/       # Calculadora de salud
│   └── main/            # Navegación principal
├── l10n/                # Localizaciones (ES/EN)
└── main.dart           # Entry point
```

## 🔧 Configuración

### Base de Datos

La app utiliza SQLite para almacenamiento local:
- **Tabla `workspaces`**: Espacios de trabajo
- **Tabla `detection_results`**: Historial de detecciones

### Providers

- `LocaleProvider`: Manejo de idiomas
- `ConnectivityProvider`: Estado de conexión
- `DetectionProvider`: Gestión de detecciones
- `AuthProvider`: Autenticación (opcional)

## 📱 Pantallas Principales

### 1. Dashboard
- Estadísticas totales
- Gráfico de distribución
- Actividad reciente

### 2. Cámara
- Captura/selección de imagen
- Análisis en tiempo real
- Resultados con confianza

### 3. Historial
- Lista de todas las detecciones
- Detalles por detección
- Eliminación de registros

### 4. Calculadora
- Cálculo manual de índices
- Integración con historial
- Recomendaciones personalizadas

### 5. Configuración
- Cambio de idioma
- Información de la app
- Sobre el proyecto

## 🌐 Localización

Archivos de traducción:
- `lib/l10n/app_es.arb` - Español
- `lib/l10n/app_en.arb` - Inglés

Para agregar traducciones:
1. Editar archivos `.arb`
2. Ejecutar: `flutter gen-l10n`

## 🔬 Enfermedades Detectadas

### Mancha Negra (Black Spot)
- Causada por hongos
- Manchas oscuras en la piel
- Afecta calidad y comercialización

### Roña (Scab)
- Lesiones costrosas
- Reduce valor comercial
- Propagación rápida

### Estado Saludable
- Sin signos de enfermedad
- Apto para comercialización

## 📊 Tecnologías Utilizadas

- **Flutter**: Framework de desarrollo
- **Provider**: Gestión de estado
- **SQLite**: Base de datos local
- **fl_chart**: Gráficos interactivos
- **image_picker**: Captura de imágenes
- **TensorFlow Lite**: Inferencia ML (por integrar)
- **connectivity_plus**: Estado de red

## 🎓 Contexto Académico

Este proyecto es parte de una tesis de grado enfocada en la aplicación de inteligencia artificial en el sector agrícola, específicamente para mejorar la detección temprana de enfermedades en cultivos de aguacate.

### Objetivos
- Automatizar detección de enfermedades
- Reducir diagnósticos tardíos
- Minimizar uso inadecuado de agroquímicos
- Mejorar rendimiento de cultivos

## 📝 Próximos Pasos

- [ ] Integrar modelo TensorFlow Lite real
- [ ] Implementar autenticación Firebase
- [ ] Sincronización en la nube
- [ ] Exportar reportes PDF
- [ ] Modo oscuro
- [ ] Notificaciones push
- [ ] Análisis por lotes

## 🤝 Contribución

Este es un proyecto de tesis. Para sugerencias o mejoras, contactar al autor.

## 📄 Licencia

Proyecto académico - ESPE 2026

## ✨ Autor

Proyecto de Tesis - Escuela Politécnica del Ejército (ESPE)

---

**Nota**: El modelo de ML actualmente usa datos simulados. Consulta [MODELO_ML_INTEGRATION.md](MODELO_ML_INTEGRATION.md) para integrar tu modelo real.
