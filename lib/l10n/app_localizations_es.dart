// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Detección de Enfermedades del Aguacate';

  @override
  String get appName => 'avocadoIA';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appDescription =>
      'Detección temprana de Mancha Negra y Roña en aguacate usando redes neuronales convolucionales';

  @override
  String get hello => 'Hola';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get register => 'Registrarse';

  @override
  String get email => 'Correo Electrónico';

  @override
  String get password => 'Contraseña';

  @override
  String get confirmPassword => 'Confirmar Contraseña';

  @override
  String get name => 'Nombre';

  @override
  String get forgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get dontHaveAccount => '¿No tienes una cuenta?';

  @override
  String get alreadyHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get profile => 'Perfil';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Guardar resultado';

  @override
  String get cancel => 'Cancelar';

  @override
  String get dashboard => 'Panel de Control';

  @override
  String get camera => 'Cámara';

  @override
  String get calculator => 'Calculadora';

  @override
  String get history => 'Historial';

  @override
  String get totalAnalyses => 'Análisis Totales';

  @override
  String get healthyFruits => 'Frutos Sanos';

  @override
  String get detectedDiseases => 'Enfermedades Detectadas';

  @override
  String get thisMonth => 'Este Mes';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get recentActivity => 'Actividad Reciente';

  @override
  String get recommendations => 'Recomendaciones';

  @override
  String get noHistoryFound => 'No se encontró historial';

  @override
  String get healthy => 'Sano';

  @override
  String get manchaNegra => 'Mancha Negra';

  @override
  String get rona => 'Roña';

  @override
  String get confidence => 'Confianza';

  @override
  String get offlineMode => 'Modo sin conexión - Usando modelo local';

  @override
  String get healthCalculator => 'Calculadora de Salud';

  @override
  String get totalFruits => 'Total de Frutos';

  @override
  String get calculateHealthScore => 'Calcular Índice de Salud';

  @override
  String get healthyPercentage => 'Porcentaje de Frutos Sanos';

  @override
  String get diseaseIncidence => 'Incidencia de Enfermedades';

  @override
  String get delete => 'Eliminar';

  @override
  String get addWorkspace => 'Agregar Espacio de Trabajo';

  @override
  String get workspaceName => 'Nombre del Espacio';

  @override
  String get workspaceDescription => 'Descripción';

  @override
  String get enterName => 'Ingrese el nombre';

  @override
  String get optionalDescription => 'Descripción opcional';

  @override
  String get deleteWorkspace => 'Eliminar Espacio';

  @override
  String get sureDelete => '¿Estás seguro de que quieres eliminar';

  @override
  String get selectImage => 'Selecciona una imagen';

  @override
  String get takePhoto => 'Tomar Foto';

  @override
  String get chooseFromGallery => 'Elegir de Galería';

  @override
  String get analyzeImage => 'Analizar Imagen';

  @override
  String get analyzing => 'Analizando…';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Cerrar';

  @override
  String get selectImageError => 'Error al seleccionar imagen';

  @override
  String get analyzeError => 'Error al analizar imagen';

  @override
  String get loadFromHistory => 'Cargar desde historial';

  @override
  String get enterDataManually =>
      'Ingrese los datos manualmente o cárguelos desde su historial de detecciones';

  @override
  String get results => 'Resultados';

  @override
  String get pleaseEnterTotal => 'Por favor ingrese el total de frutos';

  @override
  String get sumDoesNotMatch => 'La suma de frutos no coincide con el total';

  @override
  String get recordDeleted => 'Registro eliminado';

  @override
  String get clearHistory => 'Limpiar historial';

  @override
  String get sureDeleteAll =>
      '¿Estás seguro de que quieres eliminar todo el historial?';

  @override
  String get deleteAll => 'Eliminar todo';

  @override
  String get historyCleared => 'Historial limpiado';

  @override
  String get sureDeleteRecord =>
      '¿Estás seguro de que quieres eliminar este registro?';

  @override
  String get agoMoment => 'Hace un momento';

  @override
  String agoMinutes(Object count, Object s) {
    return 'Hace $count minuto$s';
  }

  @override
  String agoHours(Object count, Object s) {
    return 'Hace $count hora$s';
  }

  @override
  String agoDays(Object count, Object s) {
    return 'Hace $count día$s';
  }

  @override
  String get aboutApp => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get aboutDescription =>
      'AvoScan AI - Detección de enfermedades en aguacate';

  @override
  String get aboutProject => 'Sobre el Proyecto';

  @override
  String get developedBy => 'Desarrollado como proyecto de tesis';

  @override
  String get detectedDiseases2 => 'Enfermedades detectadas:';

  @override
  String get features => 'Características:';

  @override
  String get realTimeDetection => 'Detección en tiempo real';

  @override
  String get offlineFunctionality => 'Funcionamiento offline';

  @override
  String get detectionHistory => 'Historial de detecciones';

  @override
  String get statisticsAnalysis => 'Estadísticas y análisis';

  @override
  String get automaticRecommendations => 'Recomendaciones automáticas';

  @override
  String get multiLanguageSupport => 'Soporte multiidioma';

  @override
  String get noDataToShow => 'No hay datos para mostrar';

  @override
  String get excellentHealth => 'Excelente estado fitosanitario';

  @override
  String get continueCurrentPractices =>
      'Continuar con las prácticas actuales de manejo';

  @override
  String get maintainMonitoring => 'Mantener monitoreo preventivo regular';

  @override
  String get documentPractices => 'Documentar las prácticas exitosas';

  @override
  String get earlyWarning => 'Nivel de alerta temprana';

  @override
  String get increaseMonitoring => 'Incrementar frecuencia de monitoreo';

  @override
  String get considerPreventive =>
      'Considerar aplicación preventiva de fungicidas';

  @override
  String get reviewManagement => 'Revisar prácticas de manejo cultural';

  @override
  String get improveDrainage => 'Mejorar ventilación y drenaje';

  @override
  String get criticalLevel => 'Nivel crítico - Acción inmediata requerida';

  @override
  String get applyUrgentTreatment => 'Aplicar tratamiento fungicida urgente';

  @override
  String get removeInfected => 'Eliminar frutos y material vegetal infectado';

  @override
  String get improveConditions => 'Mejorar condiciones ambientales';

  @override
  String get consultSpecialist => 'Consultar con especialista agronómico';

  @override
  String get implementIPM => 'Implementar plan de manejo integrado';

  @override
  String get appearance => 'Apariencia';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get themeSystem => 'Automático';

  @override
  String get distribution => 'Distribución';

  @override
  String get emptyDashboardTitle => 'Aún no hay análisis';

  @override
  String get emptyDashboardMessage => 'Toma una foto de un fruto para empezar.';

  @override
  String get takeFirstPhoto => 'Tomar foto';

  @override
  String get emptyHistoryTitle => 'Aún no hay historial';

  @override
  String get emptyHistoryMessage => 'Tus detecciones aparecerán aquí.';

  @override
  String get confidenceHint => 'Qué tan seguro está el análisis (0–100%).';

  @override
  String get viewTutorial => 'Ver tutorial de nuevo';

  @override
  String get confirmDeleteTitle => '¿Eliminar registro?';

  @override
  String get confirmDeleteMessage =>
      'Esta detección se eliminará permanentemente.';

  @override
  String get confirmClearTitle => '¿Limpiar historial?';

  @override
  String get confirmClearMessage => 'Se eliminarán todas las detecciones.';

  @override
  String get newDetection => 'Nueva detección';

  @override
  String get onbWelcomeTitle => 'Bienvenido a avocadoIA';

  @override
  String get onbWelcomeBody =>
      'Detecta Mancha Negra y Roña en aguacate desde una foto.';

  @override
  String get onbPhotoTitle => 'Toma una buena foto';

  @override
  String get onbPhotoBody => 'Buena luz, acerca el fruto y mantenlo enfocado.';

  @override
  String get onbResultsTitle => 'Mira resultados y consejos';

  @override
  String get onbResultsBody =>
      'Revisa el diagnóstico, las recomendaciones y tu historial.';

  @override
  String get onbSkip => 'Saltar';

  @override
  String get onbNext => 'Siguiente';

  @override
  String get onbStart => 'Empezar';

  @override
  String get navDashboard => 'Panel';

  @override
  String get navCalculator => 'Calc.';

  @override
  String get navSettings => 'Ajustes';

  @override
  String get assistant => 'Asistente IA';

  @override
  String get navAssistant => 'Asistente';

  @override
  String get askAI => 'Preguntar a la IA';

  @override
  String get assistantDisclaimer =>
      'Orientativo — no sustituye a un agrónomo certificado.';

  @override
  String get assistantTalkingAbout => 'Sobre';

  @override
  String get assistantGeneralGreeting =>
      '¡Hola! Pregúntame sobre enfermedades del aguacate, tratamientos o tu huerto.';

  @override
  String get chatInputHint => 'Escribe tu pregunta…';

  @override
  String get send => 'Enviar';

  @override
  String get assistantThinking => 'Pensando…';

  @override
  String get assistantPlaceholderReply =>
      'Aún estoy aprendiendo. Por ahora puedo explicar resultados de detección y cuidados generales.';

  @override
  String get modelSetupTitle => 'Asistente IA — Modelo';

  @override
  String get modelSetupIntro =>
      'Para usar el asistente fuera de línea, descarga el modelo de lenguaje en tu dispositivo.';

  @override
  String get wifiWarning => 'Usa WiFi: la descarga es de ~584 MB.';

  @override
  String get hfTokenLabel => 'Token de HuggingFace';

  @override
  String get hfTokenHint => 'hf_… (se guarda solo en tu dispositivo)';

  @override
  String get modelUrlLabel => 'URL del modelo';

  @override
  String get downloadModel => 'Descargar modelo';

  @override
  String get downloading => 'Descargando…';

  @override
  String get modelReady => 'Modelo listo';

  @override
  String get modelNotReady => 'Modelo no instalado';

  @override
  String get downloadError => 'No se pudo descargar el modelo';

  @override
  String get aiModelTile => 'Modelo del asistente (IA)';

  @override
  String get conversations => 'Conversaciones';

  @override
  String get newConversation => 'Nueva conversación';

  @override
  String get noConversations => 'Aún no hay conversaciones';

  @override
  String get noConversationsMsg => 'Inicia un chat con el asistente.';

  @override
  String get deleteConversation => 'Eliminar conversación';

  @override
  String get deleteConversationMsg =>
      'Esta conversación se eliminará permanentemente.';

  @override
  String get deleteAllConversations => 'Eliminar todas';

  @override
  String get deleteAllConversationsMsg =>
      'Todas las conversaciones se eliminarán permanentemente.';

  @override
  String get conversationDeleted => 'Conversación eliminada';

  @override
  String get untitledConversation => 'Conversación';

  @override
  String get voiceDictate => 'Dictar';

  @override
  String get voiceListening => 'Escuchando…';

  @override
  String get voiceStop => 'Detener';

  @override
  String get voicePlay => 'Reproducir';

  @override
  String get voiceAutoReadOn => 'Lectura automática activada';

  @override
  String get voiceAutoReadOff => 'Lectura automática desactivada';

  @override
  String get micDenied => 'Permiso de micrófono denegado';

  @override
  String get voiceUnavailable => 'Voz no disponible en este dispositivo';
}
