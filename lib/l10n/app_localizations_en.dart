// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Avocado Disease Detection';

  @override
  String get appName => 'avocadoIA';

  @override
  String get appVersion => '1.0.0';

  @override
  String get appDescription =>
      'Early detection of Black Spot and Scab in avocado using convolutional neural networks';

  @override
  String get hello => 'Hello';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get name => 'Name';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get settings => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get profile => 'Profile';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save result';

  @override
  String get cancel => 'Cancel';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get camera => 'Camera';

  @override
  String get calculator => 'Calculator';

  @override
  String get history => 'History';

  @override
  String get totalAnalyses => 'Total Analyses';

  @override
  String get healthyFruits => 'Healthy Fruits';

  @override
  String get detectedDiseases => 'Detected Diseases';

  @override
  String get thisMonth => 'This Month';

  @override
  String get statistics => 'Statistics';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get recommendations => 'Recommendations';

  @override
  String get noHistoryFound => 'No history found';

  @override
  String get healthy => 'Healthy';

  @override
  String get manchaNegra => 'Black Spot';

  @override
  String get rona => 'Scab';

  @override
  String get confidence => 'Confidence';

  @override
  String get offlineMode => 'Offline mode - Using local model';

  @override
  String get healthCalculator => 'Health Calculator';

  @override
  String get totalFruits => 'Total Fruits';

  @override
  String get calculateHealthScore => 'Calculate Health Score';

  @override
  String get healthyPercentage => 'Healthy Percentage';

  @override
  String get diseaseIncidence => 'Disease Incidence';

  @override
  String get delete => 'Delete';

  @override
  String get addWorkspace => 'Add Workspace';

  @override
  String get workspaceName => 'Workspace Name';

  @override
  String get workspaceDescription => 'Description';

  @override
  String get enterName => 'Enter name';

  @override
  String get optionalDescription => 'Optional description';

  @override
  String get deleteWorkspace => 'Delete Workspace';

  @override
  String get sureDelete => 'Are you sure you want to delete';

  @override
  String get selectImage => 'Select an image';

  @override
  String get takePhoto => 'Take Photo';

  @override
  String get chooseFromGallery => 'Choose from Gallery';

  @override
  String get analyzeImage => 'Analyze Image';

  @override
  String get analyzing => 'Analyzing…';

  @override
  String get error => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get close => 'Close';

  @override
  String get selectImageError => 'Error selecting image';

  @override
  String get analyzeError => 'Error analyzing image';

  @override
  String get loadFromHistory => 'Load from history';

  @override
  String get enterDataManually =>
      'Enter data manually or load from your detection history';

  @override
  String get results => 'Results';

  @override
  String get pleaseEnterTotal => 'Please enter total fruits';

  @override
  String get sumDoesNotMatch => 'The sum of fruits does not match the total';

  @override
  String get recordDeleted => 'Record deleted';

  @override
  String get clearHistory => 'Clear history';

  @override
  String get sureDeleteAll => 'Are you sure you want to delete all history?';

  @override
  String get deleteAll => 'Delete all';

  @override
  String get historyCleared => 'History cleared';

  @override
  String get sureDeleteRecord => 'Are you sure you want to delete this record?';

  @override
  String get agoMoment => 'Just now';

  @override
  String agoMinutes(Object count, Object s) {
    return '$count minute$s ago';
  }

  @override
  String agoHours(Object count, Object s) {
    return '$count hour$s ago';
  }

  @override
  String agoDays(Object count, Object s) {
    return '$count day$s ago';
  }

  @override
  String get aboutApp => 'About';

  @override
  String get version => 'Version';

  @override
  String get aboutDescription => 'AvoScan AI - Avocado disease detection';

  @override
  String get aboutProject => 'About the Project';

  @override
  String get developedBy => 'Developed as a thesis project';

  @override
  String get detectedDiseases2 => 'Detected diseases:';

  @override
  String get features => 'Features:';

  @override
  String get realTimeDetection => 'Real-time detection';

  @override
  String get offlineFunctionality => 'Offline functionality';

  @override
  String get detectionHistory => 'Detection history';

  @override
  String get statisticsAnalysis => 'Statistics and analysis';

  @override
  String get automaticRecommendations => 'Automatic recommendations';

  @override
  String get multiLanguageSupport => 'Multi-language support';

  @override
  String get noDataToShow => 'No data to display';

  @override
  String get excellentHealth => 'Excellent phytosanitary status';

  @override
  String get continueCurrentPractices =>
      'Continue with current management practices';

  @override
  String get maintainMonitoring => 'Maintain regular preventive monitoring';

  @override
  String get documentPractices => 'Document successful practices';

  @override
  String get earlyWarning => 'Early warning level';

  @override
  String get increaseMonitoring => 'Increase monitoring frequency';

  @override
  String get considerPreventive => 'Consider preventive fungicide application';

  @override
  String get reviewManagement => 'Review cultural management practices';

  @override
  String get improveDrainage => 'Improve ventilation and drainage';

  @override
  String get criticalLevel => 'Critical level - Immediate action required';

  @override
  String get applyUrgentTreatment => 'Apply urgent fungicide treatment';

  @override
  String get removeInfected => 'Remove infected fruits and plant material';

  @override
  String get improveConditions => 'Improve environmental conditions';

  @override
  String get consultSpecialist => 'Consult with agronomic specialist';

  @override
  String get implementIPM => 'Implement integrated pest management (IPM)';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get distribution => 'Distribution';

  @override
  String get emptyDashboardTitle => 'No analyses yet';

  @override
  String get emptyDashboardMessage => 'Take a photo of a fruit to start.';

  @override
  String get takeFirstPhoto => 'Take a photo';

  @override
  String get emptyHistoryTitle => 'No history yet';

  @override
  String get emptyHistoryMessage => 'Your detections will appear here.';

  @override
  String get confidenceHint => 'How sure the analysis is (0–100%).';

  @override
  String get viewTutorial => 'View tutorial again';

  @override
  String get confirmDeleteTitle => 'Delete record?';

  @override
  String get confirmDeleteMessage =>
      'This detection will be permanently removed.';

  @override
  String get confirmClearTitle => 'Clear history?';

  @override
  String get confirmClearMessage =>
      'All detections will be permanently removed.';

  @override
  String get newDetection => 'New detection';

  @override
  String get onbWelcomeTitle => 'Welcome to avocadoIA';

  @override
  String get onbWelcomeBody =>
      'Detect Black Spot and Scab in avocado from a photo.';

  @override
  String get onbPhotoTitle => 'Take a good photo';

  @override
  String get onbPhotoBody =>
      'Good light, get close to the fruit, keep it in focus.';

  @override
  String get onbResultsTitle => 'See results and tips';

  @override
  String get onbResultsBody =>
      'Review the diagnosis, recommendations and your history.';

  @override
  String get onbSkip => 'Skip';

  @override
  String get onbNext => 'Next';

  @override
  String get onbStart => 'Get started';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navCalculator => 'Calculator';

  @override
  String get navSettings => 'Settings';

  @override
  String get assistant => 'AI Assistant';

  @override
  String get navAssistant => 'Assistant';

  @override
  String get askAI => 'Ask the AI';

  @override
  String get assistantDisclaimer =>
      'Guidance only — not a substitute for a certified agronomist.';

  @override
  String get assistantTalkingAbout => 'About';

  @override
  String get assistantGeneralGreeting =>
      'Hi! Ask me about avocado diseases, treatments, or your orchard.';

  @override
  String get chatInputHint => 'Type your question…';

  @override
  String get send => 'Send';

  @override
  String get assistantThinking => 'Thinking…';

  @override
  String get assistantPlaceholderReply =>
      'I\'m still learning. For now I can explain detection results and general care.';

  @override
  String get modelSetupTitle => 'AI Assistant — Model';

  @override
  String get modelSetupIntro =>
      'To use the assistant offline, download the language model to your device.';

  @override
  String get wifiWarning => 'Use WiFi: the download is ~584 MB.';

  @override
  String get hfTokenLabel => 'HuggingFace Token';

  @override
  String get hfTokenHint => 'hf_… (stored only on your device)';

  @override
  String get modelUrlLabel => 'Model URL';

  @override
  String get downloadModel => 'Download model';

  @override
  String get downloading => 'Downloading…';

  @override
  String get modelReady => 'Model ready';

  @override
  String get modelNotReady => 'Model not installed';

  @override
  String get downloadError => 'Could not download the model';

  @override
  String get aiModelTile => 'Assistant model (AI)';

  @override
  String get conversations => 'Conversations';

  @override
  String get newConversation => 'New conversation';

  @override
  String get noConversations => 'No conversations yet';

  @override
  String get noConversationsMsg => 'Start a chat with the assistant.';

  @override
  String get deleteConversation => 'Delete conversation';

  @override
  String get deleteConversationMsg =>
      'This conversation will be permanently removed.';

  @override
  String get deleteAllConversations => 'Delete all';

  @override
  String get deleteAllConversationsMsg =>
      'All conversations will be permanently removed.';

  @override
  String get conversationDeleted => 'Conversation deleted';

  @override
  String get untitledConversation => 'Conversation';

  @override
  String get voiceDictate => 'Dictate';

  @override
  String get voiceListening => 'Listening…';

  @override
  String get voiceStop => 'Stop';

  @override
  String get voicePlay => 'Play';

  @override
  String get voiceAutoReadOn => 'Auto-read on';

  @override
  String get voiceAutoReadOff => 'Auto-read off';

  @override
  String get micDenied => 'Microphone permission denied';

  @override
  String get voiceUnavailable => 'Voice not available on this device';

  @override
  String get voiceNote => 'Voice note';

  @override
  String get recordVoiceNote => 'Record voice note';

  @override
  String get recording => 'Recording…';

  @override
  String get downloadingVoiceModel => 'Downloading voice model…';

  @override
  String get voiceModelError => 'Couldn\'t download the voice model';

  @override
  String get exclusiveAccess => 'Exclusive access';

  @override
  String get accessCodeHint => 'Access code';

  @override
  String get unlock => 'Unlock';

  @override
  String get wrongCode => 'Incorrect code';

  @override
  String get downloadingAiModel => 'Downloading AI model…';

  @override
  String get aiReady => 'AI ready';

  @override
  String get continueLabel => 'Continue';

  @override
  String get retry => 'Retry';
}
