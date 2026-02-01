import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'messages_all.dart';

class AppLocalizations {
  static Future<AppLocalizations> load(Locale locale) async {
    final String name =
        locale.countryCode == null ? locale.languageCode : locale.toString();
    final String localeName = Intl.canonicalizedLocale(name);

    await initializeMessages(localeName);
    Intl.defaultLocale = localeName;

    return AppLocalizations();
  }

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  // App
  String get appName => Intl.message('AvoScan AI', name: 'appName');
  String get appVersion => Intl.message('1.0.0', name: 'appVersion');
  String get appDescription => Intl.message(
        'Early detection of Black Spot and Scab in avocado using convolutional neural networks',
        name: 'appDescription',
      );

  // Navigation
  String get home => Intl.message('Home', name: 'home');
  String get dashboard => Intl.message('Dashboard', name: 'dashboard');
  String get camera => Intl.message('Camera', name: 'camera');
  String get processing => Intl.message('Processing', name: 'processing');
  String get result => Intl.message('Results', name: 'result');
  String get history => Intl.message('History', name: 'history');
  String get calculator => Intl.message('Calculator', name: 'calculator');
  String get recommendations => Intl.message('Recommendations', name: 'recommendations');
  String get profile => Intl.message('Profile', name: 'profile');
  String get settings => Intl.message('Settings', name: 'settings');

  // Auth
  String get login => Intl.message('Login', name: 'login');
  String get logout => Intl.message('Logout', name: 'logout');
  String get register => Intl.message('Register', name: 'register');
  String get email => Intl.message('Email', name: 'email');
  String get password => Intl.message('Password', name: 'password');
  String get confirmPassword => Intl.message('Confirm Password', name: 'confirmPassword');
  String get name => Intl.message('Name', name: 'name');
  String get forgotPassword => Intl.message('Forgot Password?', name: 'forgotPassword');
  String get signInWithGoogle => Intl.message('Sign in with Google', name: 'signInWithGoogle');
  String get dontHaveAccount => Intl.message("Don't have an account?", name: 'dontHaveAccount');
  String get alreadyHaveAccount => Intl.message('Already have an account?', name: 'alreadyHaveAccount');

  // Buttons
  String get startDetection => Intl.message('Start Detection', name: 'startDetection');
  String get captureImage => Intl.message('Capture Image', name: 'captureImage');
  String get uploadImage => Intl.message('Upload from Gallery', name: 'uploadImage');
  String get analyze => Intl.message('Analyze', name: 'analyze');
  String get newAnalysis => Intl.message('New Analysis', name: 'newAnalysis');
  String get retry => Intl.message('Retry', name: 'retry');
  String get done => Intl.message('Done', name: 'done');
  String get cancel => Intl.message('Cancel', name: 'cancel');
  String get viewHistory => Intl.message('View History', name: 'viewHistory');
  String get save => Intl.message('Save', name: 'save');
  String get delete => Intl.message('Delete', name: 'delete');
  String get edit => Intl.message('Edit', name: 'edit');

  // Camera
  String get cameraHelp => Intl.message('Place the avocado within the frame', name: 'cameraHelp');
  String get frameGuide => Intl.message('Center the fruit here', name: 'frameGuide');

  // Messages
  String get processingImage => Intl.message('Analyzing image with CNN model...', name: 'processingImage');
  String get detectionComplete => Intl.message('Analysis complete', name: 'detectionComplete');
  String get noHistoryFound => Intl.message('No previous analyses', name: 'noHistoryFound');
  String get selectImage => Intl.message('Please select an image', name: 'selectImage');
  String get error => Intl.message('Error', name: 'error');
  String get success => Intl.message('Success', name: 'success');
  String get loading => Intl.message('Loading...', name: 'loading');
  String get online => Intl.message('Online', name: 'online');
  String get offline => Intl.message('Offline', name: 'offline');
  String get offlineMode => Intl.message('Offline mode - Using local model', name: 'offlineMode');

  // Diseases
  String get healthy => Intl.message('Healthy Fruit', name: 'healthy');
  String get manchaNegra => Intl.message('Black Spot', name: 'manchaNegra');
  String get rona => Intl.message('Scab', name: 'rona');

  // Recommendations
  String get healthyRecommendation => Intl.message(
        'The fruit is in good condition. Continue with preventive management practices.',
        name: 'healthyRecommendation',
      );
  String get manchaNegraRecommendation => Intl.message(
        'Black Spot detected. Recommendation: Apply fungicide treatment and improve crop drainage.',
        name: 'manchaNegraRecommendation',
      );
  String get ronaRecommendation => Intl.message(
        'Scab detected. Recommendation: Implement preventive chemical control and humidity management.',
        name: 'ronaRecommendation',
      );

  // Results
  String get confidence => Intl.message('Model Confidence', name: 'confidence');
  String get diagnosis => Intl.message('Diagnosis', name: 'diagnosis');
  String get recommendation => Intl.message('Recommendation', name: 'recommendation');

  // Location
  String get location => Intl.message('Location', name: 'location');
  String get selectLocation => Intl.message('Select your location', name: 'selectLocation');
  String get farm => Intl.message('Farm', name: 'farm');
  String get greenhouse => Intl.message('Greenhouse', name: 'greenhouse');
  String get laboratory => Intl.message('Laboratory', name: 'laboratory');
  String get other => Intl.message('Other', name: 'other');

  // Dashboard
  String get totalAnalyses => Intl.message('Total Analyses', name: 'totalAnalyses');
  String get healthyFruits => Intl.message('Healthy Fruits', name: 'healthyFruits');
  String get detectedDiseases => Intl.message('Detected Diseases', name: 'detectedDiseases');
  String get recentActivity => Intl.message('Recent Activity', name: 'recentActivity');
  String get statistics => Intl.message('Statistics', name: 'statistics');
  String get today => Intl.message('Today', name: 'today');
  String get thisWeek => Intl.message('This Week', name: 'thisWeek');
  String get thisMonth => Intl.message('This Month', name: 'thisMonth');

  // Calculator
  String get healthCalculator => Intl.message('Avocado Health Calculator', name: 'healthCalculator');
  String get calculateHealthScore => Intl.message('Calculate Health Score', name: 'calculateHealthScore');
  String get healthyPercentage => Intl.message('Healthy Percentage', name: 'healthyPercentage');
  String get diseaseIncidence => Intl.message('Disease Incidence', name: 'diseaseIncidence');
  String get totalFruits => Intl.message('Total Fruits', name: 'totalFruits');
  String get affectedFruits => Intl.message('Affected Fruits', name: 'affectedFruits');

  // Language
  String get language => Intl.message('Language', name: 'language');
  String get spanish => Intl.message('Spanish', name: 'spanish');
  String get english => Intl.message('English', name: 'english');
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return AppLocalizations.load(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
