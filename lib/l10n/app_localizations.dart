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
  /// **'AvoScan AI'**
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
  /// **'Save'**
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
