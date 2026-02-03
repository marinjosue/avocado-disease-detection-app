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
  String get appName => 'AvoScan AI';

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
  String get save => 'Guardar';

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
  String get analyzing => 'Analizando...';

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
}
