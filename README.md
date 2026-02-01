# 🥑 AvoScan AI - Detección de Enfermedades en Aguacate

[![Flutter](https://img.shields.io/badge/Flutter-3.9.2-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?logo=firebase)](https://firebase.google.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Aplicación móvil profesional para la detección temprana de Mancha Negra y Roña en aguacate mediante redes neuronales convolucionales (CNN). Proyecto de tesis desarrollado en ESPE.

## ✨ Características Principales

### 🔐 Autenticación de Usuarios
- Login con email y contraseña
- Autenticación con Google
- Gestión de perfiles de usuario
- Selección de tipo de ubicación (Finca, Invernadero, Laboratorio)

### 📊 Dashboard Inteligente
- Estadísticas en tiempo real
- Gráficos de distribución de enfermedades
- Actividad reciente
- Recomendaciones personalizadas basadas en análisis

### 🎯 Detección de Enfermedades
- Captura de imágenes con cámara
- Carga desde galería
- Análisis con modelo CNN
- Resultados con nivel de confianza
- Recomendaciones específicas por enfermedad

### 🧮 Calculadora de Salud
- Cálculo de porcentaje de frutos sanos
- Incidencia de enfermedades
- Visualización gráfica de resultados
- Recomendaciones basadas en porcentajes

### 📱 Funcionalidad Offline
- Almacenamiento local con SQLite
- Análisis sin conexión a internet
- Sincronización automática cuando hay conexión
- Indicador de estado de conexión

### 🌍 Multiidioma
- Español (por defecto)
- Inglés
- Cambio dinámico de idioma

## 🚀 Instalación

### Prerrequisitos
- Flutter SDK 3.9.2 o superior
- Dart 3.0 o superior
- Android Studio / Xcode (para compilación móvil)

### Pasos de Instalación

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/avocado-disease-detection-app.git
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

## 📦 Dependencias Principales

- **flutter_localizations**: Soporte multiidioma
- **provider**: Manejo de estado
- **sqflite**: Base de datos local
- **firebase_auth**: Autenticación de usuarios
- **fl_chart**: Gráficos y visualización
- **connectivity_plus**: Detección de conexión
- **image_picker**: Captura y selección de imágenes

## 🏗️ Arquitectura del Proyecto

```
lib/
├── core/
│   ├── constants/          # Colores, strings
│   ├── database/           # SQLite helper
│   ├── localization/       # i18n - Español/Inglés
│   ├── providers/          # Providers globales
│   └── widgets/            # Widgets reutilizables
├── features/
│   ├── auth/               # Autenticación
│   ├── dashboard/          # Panel de control
│   ├── detection/          # Detección de enfermedades
│   ├── calculator/         # Calculadora de salud
│   └── main/               # Navegación principal
└── main.dart
```

## 📝 Configuración de Firebase (Opcional)

1. Crea un proyecto en [Firebase Console](https://console.firebase.google.com)
2. Descarga `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
3. Colócalos en las carpetas correspondientes
4. Habilita autenticación por email y Google

**Nota:** Si no usas Firebase, comenta las líneas relacionadas en `main.dart`

## 📄 Licencia

Proyecto de tesis académica - ESPE

## 👥 Autores

**Desarrollado en ESPE** - Escuela Politécnica del Ejército

---

**Desarrollado con ❤️ en Ecuador 🇪🇨**
