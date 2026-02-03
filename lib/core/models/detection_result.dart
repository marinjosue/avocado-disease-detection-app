class DetectionResult {
  final int? id;
  final String diseaseType; // 'healthy', 'mancha_negra', 'rona'
  final double confidence;
  final String imagePath;
  final DateTime timestamp;
  final String? workspaceId;
  final String? notes;

  DetectionResult({
    this.id,
    required this.diseaseType,
    required this.confidence,
    required this.imagePath,
    required this.timestamp,
    this.workspaceId,
    this.notes,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'diseaseType': diseaseType,
      'confidence': confidence,
      'imagePath': imagePath,
      'timestamp': timestamp.toIso8601String(),
      'workspaceId': workspaceId,
      'notes': notes,
    };
  }

  // Create from Map
  factory DetectionResult.fromMap(Map<String, dynamic> map) {
    return DetectionResult(
      id: map['id'],
      diseaseType: map['diseaseType'],
      confidence: map['confidence'],
      imagePath: map['imagePath'],
      timestamp: DateTime.parse(map['timestamp']),
      workspaceId: map['workspaceId'],
      notes: map['notes'],
    );
  }

  // Check if fruit is healthy
  bool get isHealthy => diseaseType == 'healthy';

  // Get disease name in Spanish
  String getDiseaseNameES() {
    switch (diseaseType) {
      case 'healthy':
        return 'Sano';
      case 'mancha_negra':
        return 'Mancha Negra';
      case 'rona':
        return 'Roña';
      default:
        return 'Desconocido';
    }
  }

  // Get disease name in English
  String getDiseaseNameEN() {
    switch (diseaseType) {
      case 'healthy':
        return 'Healthy';
      case 'mancha_negra':
        return 'Black Spot';
      case 'rona':
        return 'Scab';
      default:
        return 'Unknown';
    }
  }

  // Get recommendation based on disease type
  String getRecommendationES() {
    switch (diseaseType) {
      case 'healthy':
        return 'El fruto está sano. Continúe con las prácticas de manejo actuales.';
      case 'mancha_negra':
        return '''Mancha Negra Detectada:
• Retire los frutos afectados para evitar propagación
• Aplique fungicidas a base de cobre
• Mejore la ventilación en el cultivo
• Evite el riego por aspersión
• Realice podas sanitarias''';
      case 'rona':
        return '''Roña Detectada:
• Aplique tratamiento fungicida preventivo
• Use productos a base de azufre o cobre
• Controle la humedad del ambiente
• Elimine material vegetal infectado
• Monitoree regularmente el cultivo''';
      default:
        return 'No se puede determinar una recomendación específica.';
    }
  }

  String getRecommendationEN() {
    switch (diseaseType) {
      case 'healthy':
        return 'The fruit is healthy. Continue with current management practices.';
      case 'mancha_negra':
        return '''Black Spot Detected:
• Remove affected fruits to prevent spread
• Apply copper-based fungicides
• Improve crop ventilation
• Avoid overhead irrigation
• Perform sanitary pruning''';
      case 'rona':
        return '''Scab Detected:
• Apply preventive fungicide treatment
• Use sulfur or copper-based products
• Control environmental humidity
• Remove infected plant material
• Monitor crop regularly''';
      default:
        return 'Cannot determine a specific recommendation.';
    }
  }

  DetectionResult copyWith({
    int? id,
    String? diseaseType,
    double? confidence,
    String? imagePath,
    DateTime? timestamp,
    String? workspaceId,
    String? notes,
  }) {
    return DetectionResult(
      id: id ?? this.id,
      diseaseType: diseaseType ?? this.diseaseType,
      confidence: confidence ?? this.confidence,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      workspaceId: workspaceId ?? this.workspaceId,
      notes: notes ?? this.notes,
    );
  }
}
