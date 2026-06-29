import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'Avocado Disease Detection'**
  String get appTitle;

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'avocadoIA'**
  String get appName;

  /// Application version
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get appVersion;

  /// Application description
  ///
  /// In en, this message translates to:
  /// **'Early detection of Black Spot and Scab in avocado using convolutional neural networks'**
  String get appDescription;

  /// A greeting
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// Login button and page title
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Logout button
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// Register button and page title
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// Sign up prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Login prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Settings page title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Edit action
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Save action
  ///
  /// In en, this message translates to:
  /// **'Save result'**
  String get save;

  /// Cancel action
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Dashboard page title
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Camera page title
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// Calculator page title
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator;

  /// History page title
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Total analyses label
  ///
  /// In en, this message translates to:
  /// **'Total Analyses'**
  String get totalAnalyses;

  /// Healthy fruits label
  ///
  /// In en, this message translates to:
  /// **'Healthy Fruits'**
  String get healthyFruits;

  /// Detected diseases label
  ///
  /// In en, this message translates to:
  /// **'Detected Diseases'**
  String get detectedDiseases;

  /// This month label
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Statistics label
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Recent activity label
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Recommendations label
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get recommendations;

  /// No history message
  ///
  /// In en, this message translates to:
  /// **'No history found'**
  String get noHistoryFound;

  /// Healthy status
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get healthy;

  /// Black spot disease
  ///
  /// In en, this message translates to:
  /// **'Black Spot'**
  String get manchaNegra;

  /// Scab disease
  ///
  /// In en, this message translates to:
  /// **'Scab'**
  String get rona;

  /// Confidence level
  ///
  /// In en, this message translates to:
  /// **'Confidence'**
  String get confidence;

  /// Offline mode message
  ///
  /// In en, this message translates to:
  /// **'Offline mode - Using local model'**
  String get offlineMode;

  /// Health calculator title
  ///
  /// In en, this message translates to:
  /// **'Health Calculator'**
  String get healthCalculator;

  /// Total fruits label
  ///
  /// In en, this message translates to:
  /// **'Total Fruits'**
  String get totalFruits;

  /// Calculate health score button
  ///
  /// In en, this message translates to:
  /// **'Calculate Health Score'**
  String get calculateHealthScore;

  /// Healthy percentage label
  ///
  /// In en, this message translates to:
  /// **'Healthy Percentage'**
  String get healthyPercentage;

  /// Disease incidence label
  ///
  /// In en, this message translates to:
  /// **'Disease Incidence'**
  String get diseaseIncidence;

  /// Delete action
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Add workspace action
  ///
  /// In en, this message translates to:
  /// **'Add Workspace'**
  String get addWorkspace;

  /// Workspace name label
  ///
  /// In en, this message translates to:
  /// **'Workspace Name'**
  String get workspaceName;

  /// Workspace description label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get workspaceDescription;

  /// Enter name placeholder
  ///
  /// In en, this message translates to:
  /// **'Enter name'**
  String get enterName;

  /// Optional description placeholder
  ///
  /// In en, this message translates to:
  /// **'Optional description'**
  String get optionalDescription;

  /// Delete workspace title
  ///
  /// In en, this message translates to:
  /// **'Delete Workspace'**
  String get deleteWorkspace;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete'**
  String get sureDelete;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select an image'**
  String get selectImage;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @analyzeImage.
  ///
  /// In en, this message translates to:
  /// **'Analyze Image'**
  String get analyzeImage;

  /// No description provided for @analyzing.
  ///
  /// In en, this message translates to:
  /// **'Analyzing…'**
  String get analyzing;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @selectImageError.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get selectImageError;

  /// No description provided for @analyzeError.
  ///
  /// In en, this message translates to:
  /// **'Error analyzing image'**
  String get analyzeError;

  /// No description provided for @loadFromHistory.
  ///
  /// In en, this message translates to:
  /// **'Load from history'**
  String get loadFromHistory;

  /// No description provided for @enterDataManually.
  ///
  /// In en, this message translates to:
  /// **'Enter data manually or load from your detection history'**
  String get enterDataManually;

  /// No description provided for @results.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get results;

  /// No description provided for @pleaseEnterTotal.
  ///
  /// In en, this message translates to:
  /// **'Please enter total fruits'**
  String get pleaseEnterTotal;

  /// No description provided for @sumDoesNotMatch.
  ///
  /// In en, this message translates to:
  /// **'The sum of fruits does not match the total'**
  String get sumDoesNotMatch;

  /// No description provided for @recordDeleted.
  ///
  /// In en, this message translates to:
  /// **'Record deleted'**
  String get recordDeleted;

  /// No description provided for @clearHistory.
  ///
  /// In en, this message translates to:
  /// **'Clear history'**
  String get clearHistory;

  /// No description provided for @sureDeleteAll.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all history?'**
  String get sureDeleteAll;

  /// No description provided for @deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAll;

  /// No description provided for @historyCleared.
  ///
  /// In en, this message translates to:
  /// **'History cleared'**
  String get historyCleared;

  /// No description provided for @sureDeleteRecord.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get sureDeleteRecord;

  /// No description provided for @agoMoment.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get agoMoment;

  /// No description provided for @agoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count} minute{s} ago'**
  String agoMinutes(Object count, Object s);

  /// No description provided for @agoHours.
  ///
  /// In en, this message translates to:
  /// **'{count} hour{s} ago'**
  String agoHours(Object count, Object s);

  /// No description provided for @agoDays.
  ///
  /// In en, this message translates to:
  /// **'{count} day{s} ago'**
  String agoDays(Object count, Object s);

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'AvoScan AI - Avocado disease detection'**
  String get aboutDescription;

  /// No description provided for @aboutProject.
  ///
  /// In en, this message translates to:
  /// **'About the Project'**
  String get aboutProject;

  /// No description provided for @developedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed as a thesis project'**
  String get developedBy;

  /// No description provided for @detectedDiseases2.
  ///
  /// In en, this message translates to:
  /// **'Detected diseases:'**
  String get detectedDiseases2;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features:'**
  String get features;

  /// No description provided for @realTimeDetection.
  ///
  /// In en, this message translates to:
  /// **'Real-time detection'**
  String get realTimeDetection;

  /// No description provided for @offlineFunctionality.
  ///
  /// In en, this message translates to:
  /// **'Offline functionality'**
  String get offlineFunctionality;

  /// No description provided for @detectionHistory.
  ///
  /// In en, this message translates to:
  /// **'Detection history'**
  String get detectionHistory;

  /// No description provided for @statisticsAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Statistics and analysis'**
  String get statisticsAnalysis;

  /// No description provided for @automaticRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Automatic recommendations'**
  String get automaticRecommendations;

  /// No description provided for @multiLanguageSupport.
  ///
  /// In en, this message translates to:
  /// **'Multi-language support'**
  String get multiLanguageSupport;

  /// No description provided for @noDataToShow.
  ///
  /// In en, this message translates to:
  /// **'No data to display'**
  String get noDataToShow;

  /// No description provided for @excellentHealth.
  ///
  /// In en, this message translates to:
  /// **'Excellent phytosanitary status'**
  String get excellentHealth;

  /// No description provided for @continueCurrentPractices.
  ///
  /// In en, this message translates to:
  /// **'Continue with current management practices'**
  String get continueCurrentPractices;

  /// No description provided for @maintainMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Maintain regular preventive monitoring'**
  String get maintainMonitoring;

  /// No description provided for @documentPractices.
  ///
  /// In en, this message translates to:
  /// **'Document successful practices'**
  String get documentPractices;

  /// No description provided for @earlyWarning.
  ///
  /// In en, this message translates to:
  /// **'Early warning level'**
  String get earlyWarning;

  /// No description provided for @increaseMonitoring.
  ///
  /// In en, this message translates to:
  /// **'Increase monitoring frequency'**
  String get increaseMonitoring;

  /// No description provided for @considerPreventive.
  ///
  /// In en, this message translates to:
  /// **'Consider preventive fungicide application'**
  String get considerPreventive;

  /// No description provided for @reviewManagement.
  ///
  /// In en, this message translates to:
  /// **'Review cultural management practices'**
  String get reviewManagement;

  /// No description provided for @improveDrainage.
  ///
  /// In en, this message translates to:
  /// **'Improve ventilation and drainage'**
  String get improveDrainage;

  /// No description provided for @criticalLevel.
  ///
  /// In en, this message translates to:
  /// **'Critical level - Immediate action required'**
  String get criticalLevel;

  /// No description provided for @applyUrgentTreatment.
  ///
  /// In en, this message translates to:
  /// **'Apply urgent fungicide treatment'**
  String get applyUrgentTreatment;

  /// No description provided for @removeInfected.
  ///
  /// In en, this message translates to:
  /// **'Remove infected fruits and plant material'**
  String get removeInfected;

  /// No description provided for @improveConditions.
  ///
  /// In en, this message translates to:
  /// **'Improve environmental conditions'**
  String get improveConditions;

  /// No description provided for @consultSpecialist.
  ///
  /// In en, this message translates to:
  /// **'Consult with agronomic specialist'**
  String get consultSpecialist;

  /// No description provided for @implementIPM.
  ///
  /// In en, this message translates to:
  /// **'Implement integrated pest management (IPM)'**
  String get implementIPM;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @distribution.
  ///
  /// In en, this message translates to:
  /// **'Distribution'**
  String get distribution;

  /// No description provided for @emptyDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'No analyses yet'**
  String get emptyDashboardTitle;

  /// No description provided for @emptyDashboardMessage.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of a fruit to start.'**
  String get emptyDashboardMessage;

  /// No description provided for @takeFirstPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeFirstPhoto;

  /// No description provided for @emptyHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get emptyHistoryTitle;

  /// No description provided for @emptyHistoryMessage.
  ///
  /// In en, this message translates to:
  /// **'Your detections will appear here.'**
  String get emptyHistoryMessage;

  /// No description provided for @confidenceHint.
  ///
  /// In en, this message translates to:
  /// **'How sure the analysis is (0–100%).'**
  String get confidenceHint;

  /// No description provided for @viewTutorial.
  ///
  /// In en, this message translates to:
  /// **'View tutorial again'**
  String get viewTutorial;

  /// No description provided for @confirmDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete record?'**
  String get confirmDeleteTitle;

  /// No description provided for @confirmDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'This detection will be permanently removed.'**
  String get confirmDeleteMessage;

  /// No description provided for @confirmClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear history?'**
  String get confirmClearTitle;

  /// No description provided for @confirmClearMessage.
  ///
  /// In en, this message translates to:
  /// **'All detections will be permanently removed.'**
  String get confirmClearMessage;

  /// No description provided for @newDetection.
  ///
  /// In en, this message translates to:
  /// **'New detection'**
  String get newDetection;

  /// No description provided for @onbWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to avocadoIA'**
  String get onbWelcomeTitle;

  /// No description provided for @onbWelcomeBody.
  ///
  /// In en, this message translates to:
  /// **'Detect Black Spot and Scab in avocado from a photo.'**
  String get onbWelcomeBody;

  /// No description provided for @onbPhotoTitle.
  ///
  /// In en, this message translates to:
  /// **'Take a good photo'**
  String get onbPhotoTitle;

  /// No description provided for @onbPhotoBody.
  ///
  /// In en, this message translates to:
  /// **'Good light, get close to the fruit, keep it in focus.'**
  String get onbPhotoBody;

  /// No description provided for @onbResultsTitle.
  ///
  /// In en, this message translates to:
  /// **'See results and tips'**
  String get onbResultsTitle;

  /// No description provided for @onbResultsBody.
  ///
  /// In en, this message translates to:
  /// **'Review the diagnosis, recommendations and your history.'**
  String get onbResultsBody;

  /// No description provided for @onbSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onbSkip;

  /// No description provided for @onbNext.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onbNext;

  /// No description provided for @onbStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbStart;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navCalculator.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get navCalculator;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @assistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get assistant;

  /// No description provided for @navAssistant.
  ///
  /// In en, this message translates to:
  /// **'Assistant'**
  String get navAssistant;

  /// No description provided for @askAI.
  ///
  /// In en, this message translates to:
  /// **'Ask the AI'**
  String get askAI;

  /// No description provided for @assistantDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'Guidance only — not a substitute for a certified agronomist.'**
  String get assistantDisclaimer;

  /// No description provided for @assistantTalkingAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get assistantTalkingAbout;

  /// No description provided for @assistantGeneralGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hi! Ask me about avocado diseases, treatments, or your orchard.'**
  String get assistantGeneralGreeting;

  /// No description provided for @chatInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type your question…'**
  String get chatInputHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @assistantThinking.
  ///
  /// In en, this message translates to:
  /// **'Thinking…'**
  String get assistantThinking;

  /// No description provided for @assistantPlaceholderReply.
  ///
  /// In en, this message translates to:
  /// **'I\'m still learning. For now I can explain detection results and general care.'**
  String get assistantPlaceholderReply;

  /// No description provided for @modelSetupTitle.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant — Model'**
  String get modelSetupTitle;

  /// No description provided for @modelSetupIntro.
  ///
  /// In en, this message translates to:
  /// **'To use the assistant offline, download the language model to your device.'**
  String get modelSetupIntro;

  /// No description provided for @wifiWarning.
  ///
  /// In en, this message translates to:
  /// **'Use WiFi: the download is ~584 MB.'**
  String get wifiWarning;

  /// No description provided for @hfTokenLabel.
  ///
  /// In en, this message translates to:
  /// **'HuggingFace Token'**
  String get hfTokenLabel;

  /// No description provided for @hfTokenHint.
  ///
  /// In en, this message translates to:
  /// **'hf_… (stored only on your device)'**
  String get hfTokenHint;

  /// No description provided for @modelUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Model URL'**
  String get modelUrlLabel;

  /// No description provided for @downloadModel.
  ///
  /// In en, this message translates to:
  /// **'Download model'**
  String get downloadModel;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading…'**
  String get downloading;

  /// No description provided for @modelReady.
  ///
  /// In en, this message translates to:
  /// **'Model ready'**
  String get modelReady;

  /// No description provided for @modelNotReady.
  ///
  /// In en, this message translates to:
  /// **'Model not installed'**
  String get modelNotReady;

  /// No description provided for @downloadError.
  ///
  /// In en, this message translates to:
  /// **'Could not download the model'**
  String get downloadError;

  /// No description provided for @aiModelTile.
  ///
  /// In en, this message translates to:
  /// **'Assistant model (AI)'**
  String get aiModelTile;

  /// Title for the conversations list screen
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get conversations;

  /// FAB label to create a new conversation
  ///
  /// In en, this message translates to:
  /// **'New conversation'**
  String get newConversation;

  /// Empty state title when no conversations exist
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get noConversations;

  /// Empty state message when no conversations exist
  ///
  /// In en, this message translates to:
  /// **'Start a chat with the assistant.'**
  String get noConversationsMsg;

  /// Title of the delete-single-conversation confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Delete conversation'**
  String get deleteConversation;

  /// Body of the delete-single-conversation confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This conversation will be permanently removed.'**
  String get deleteConversationMsg;

  /// Title/action for deleting all conversations
  ///
  /// In en, this message translates to:
  /// **'Delete all'**
  String get deleteAllConversations;

  /// Body of the delete-all-conversations confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'All conversations will be permanently removed.'**
  String get deleteAllConversationsMsg;

  /// SnackBar shown after a conversation is deleted
  ///
  /// In en, this message translates to:
  /// **'Conversation deleted'**
  String get conversationDeleted;

  /// Fallback title when a conversation has no title
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get untitledConversation;

  /// Tooltip for the microphone button to start voice dictation
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get voiceDictate;

  /// Label shown while the app is listening for speech
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get voiceListening;

  /// Tooltip for the button that stops voice dictation or TTS
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get voiceStop;

  /// Tooltip for the per-message play button
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get voicePlay;

  /// Tooltip for the AppBar mute toggle when auto-read is currently enabled
  ///
  /// In en, this message translates to:
  /// **'Auto-read on'**
  String get voiceAutoReadOn;

  /// Tooltip for the AppBar mute toggle when auto-read is currently disabled
  ///
  /// In en, this message translates to:
  /// **'Auto-read off'**
  String get voiceAutoReadOff;

  /// Message shown when microphone permission is denied
  ///
  /// In en, this message translates to:
  /// **'Microphone permission denied'**
  String get micDenied;

  /// Message shown when STT/TTS is not available on the device
  ///
  /// In en, this message translates to:
  /// **'Voice not available on this device'**
  String get voiceUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
