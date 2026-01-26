class AppStrings {
  // App
  static const String appName = 'AvoScan AI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Detección temprana de Mancha Negra y Roña en aguacate mediante redes neuronales convolucionales';

  // Navigation
  static const String home = 'Inicio';
  static const String camera = 'Captura';
  static const String processing = 'Procesamiento';
  static const String result = 'Resultados';
  static const String history = 'Historial';

  // Buttons
  static const String startDetection = 'Iniciar detección';
  static const String captureImage = 'Capturar imagen';
  static const String uploadImage = 'Cargar desde galería';
  static const String analyze = 'Analizar';
  static const String newAnalysis = 'Nuevo análisis';
  static const String retry = 'Intentar de nuevo';
  static const String done = 'Finalizar';
  static const String cancel = 'Cancelar';
  static const String viewHistory = 'Ver historial';

  // Camera
  static const String cameraHelp = 'Coloque el aguacate dentro del marco';
  static const String frameGuide = 'Centrar el fruto aquí';

  // Messages
  static const String processingImage = 'Analizando imagen con el modelo CNN...';
  static const String detectionComplete = 'Análisis completado';
  static const String noHistoryFound = 'No hay análisis previos';
  static const String selectImage = 'Por favor seleccione una imagen';
  static const String error = 'Error';
  static const String success = 'Éxito';

  // Diseases
  static const String healthy = 'Fruto sano';
  static const String manchaNegra = 'Mancha Negra';
  static const String rona = 'Roña';

  // Recommendations
  static const String healthyRecommendation = 'El fruto está en buen estado. Continúe con las prácticas de manejo preventivo.';
  static const String manchaNegraRecommendation = 'Se detectó Mancha Negra. Recomendación: Aplicar tratamiento fungicida y mejorar drenaje del cultivo.';
  static const String ronaRecommendation = 'Se detectó Roña. Recomendación: Implementar control químico preventivo y manejo de humedad.';

  // Results
  static const String confidence = 'Confianza del modelo';
  static const String diagnosis = 'Diagnóstico';
  static const String recommendation = 'Recomendación';
  static const String analysisDate = 'Fecha de análisis';

  // Errors
  static const String errorLoadingModel = 'Error al cargar el modelo';
  static const String errorProcessingImage = 'Error al procesar la imagen';
  static const String errorCameraAccess = 'Acceso a la cámara denegado';
  static const String errorGalleryAccess = 'Acceso a la galería denegado';

  // Permissions
  static const String cameraPermission = 'Permiso de Cámara';
  static const String galleryPermission = 'Permiso de Galería';
}
