import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';

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
    Locale('bn'),
    Locale('en'),
  ];

  /// Welcome title on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome to Vocario'**
  String get welcomeTitle;

  /// Welcome subtitle on home screen
  ///
  /// In en, this message translates to:
  /// **'AI-powered audio summarization at your fingertips'**
  String get welcomeSubtitle;

  /// Import audio button text
  ///
  /// In en, this message translates to:
  /// **'Import Audio'**
  String get importAudio;

  /// Import video button text
  ///
  /// In en, this message translates to:
  /// **'Import Video'**
  String get importVideo;

  /// Menu item for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Appearance section title
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Dark mode toggle label
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// Language section title
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Bengali language option
  ///
  /// In en, this message translates to:
  /// **'বাংলা (Bengali)'**
  String get bengali;

  /// Settings screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Configure your app preferences'**
  String get settingsSubtitle;

  /// Email section title
  ///
  /// In en, this message translates to:
  /// **'Email Address (Optional)'**
  String get emailAddress;

  /// Email input hint text
  ///
  /// In en, this message translates to:
  /// **'your.email@example.com'**
  String get emailHint;

  /// Email section description
  ///
  /// In en, this message translates to:
  /// **'Pre-fill your email when sharing meeting summaries'**
  String get emailDescription;

  /// API key section title
  ///
  /// In en, this message translates to:
  /// **'Gemini API Key'**
  String get geminiApiKey;

  /// API key input hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your Gemini API key'**
  String get apiKeyHint;

  /// API key link text
  ///
  /// In en, this message translates to:
  /// **'Get your API key from Google AI Studio'**
  String get getApiKey;

  /// API key information text
  ///
  /// In en, this message translates to:
  /// **'Your API key is stored locally on your device and never shared. It\'s required for generating meeting summaries.'**
  String get apiKeyInfo;

  /// Menu item for about us
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// Mission section title
  ///
  /// In en, this message translates to:
  /// **'Our Mission'**
  String get ourMission;

  /// Vision section title
  ///
  /// In en, this message translates to:
  /// **'Our Vision'**
  String get ourVision;

  /// App purpose section title
  ///
  /// In en, this message translates to:
  /// **'Why We Built Vocario'**
  String get whyWeBuildVocario;

  /// Contact section title
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// Website contact label
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Email contact label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Company name
  ///
  /// In en, this message translates to:
  /// **'Brain Station 23'**
  String get companyName;

  /// Company tagline
  ///
  /// In en, this message translates to:
  /// **'Leading Software Development & IT Service Provider'**
  String get companyTagline;

  /// Company mission statement
  ///
  /// In en, this message translates to:
  /// **'Your trusted companion for digital leadership by empowering people to achieve more with less'**
  String get missionContent;

  /// Company vision statement
  ///
  /// In en, this message translates to:
  /// **'To be the fastest digital transformation and innovation partner by engaging global talents thus creating positive impact.'**
  String get visionContent;

  /// App purpose description
  ///
  /// In en, this message translates to:
  /// **'We developed Vocario as part of our commitment to serve our country by providing innovative solutions that help people communicate more effectively and efficiently through voice technology.'**
  String get appPurposeContent;

  /// Copyright notice
  ///
  /// In en, this message translates to:
  /// **'© 2024 Brain Station 23 PLC. All rights reserved.'**
  String get copyright;

  /// Status message during analysis
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// Title for usage context selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Usage Context'**
  String get selectUsageContext;

  /// Doctor consultation context type
  ///
  /// In en, this message translates to:
  /// **'Doctor Consultation'**
  String get doctorConsultation;

  /// Meeting minutes context type
  ///
  /// In en, this message translates to:
  /// **'Meeting Minutes'**
  String get meetingMinutes;

  /// Lecture summary context type
  ///
  /// In en, this message translates to:
  /// **'Lecture Summary'**
  String get lectureSummary;

  /// Cooking instructions context type
  ///
  /// In en, this message translates to:
  /// **'Cooking Instructions'**
  String get cookingInstructions;

  /// Description for doctor consultation context
  ///
  /// In en, this message translates to:
  /// **'Summarize medical consultations with structured clinical information'**
  String get doctorConsultationDescription;

  /// Description for meeting minutes context
  ///
  /// In en, this message translates to:
  /// **'Generate structured meeting summaries with action items and decisions'**
  String get meetingMinutesDescription;

  /// Description for lecture summary context
  ///
  /// In en, this message translates to:
  /// **'Create educational summaries with key concepts and learning points'**
  String get lectureSummaryDescription;

  /// Description for cooking instructions context
  ///
  /// In en, this message translates to:
  /// **'Extract step-by-step cooking instructions with ingredients and techniques'**
  String get cookingInstructionsDescription;

  /// Error message when reanalysis fails
  ///
  /// In en, this message translates to:
  /// **'Reanalysis failed. Previous analysis restored.'**
  String get reanalysisFailed;

  /// Success message after deleting recording
  ///
  /// In en, this message translates to:
  /// **'Recording and analysis deleted successfully'**
  String get recordingDeletedSuccessfully;

  /// Error message when deletion fails
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: {error}'**
  String failedToDelete(String error);

  /// Description for usage context selection
  ///
  /// In en, this message translates to:
  /// **'Choose the type of content you\'re recording to get the best summarization results.'**
  String get usageContextDescription;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Label for recording mode display
  ///
  /// In en, this message translates to:
  /// **'Recording Mode'**
  String get recordingMode;

  /// Change button text
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Title for API key required dialog
  ///
  /// In en, this message translates to:
  /// **'API Key Required'**
  String get apiKeyRequired;

  /// Description for API key requirement
  ///
  /// In en, this message translates to:
  /// **'To analyze your audio recordings, Vocario needs a Gemini API key. This key is stored securely on your device and is only used to process your audio content.'**
  String get apiKeyDescription;

  /// Security information about API key
  ///
  /// In en, this message translates to:
  /// **'• Your API key is stored locally and encrypted\n• No data is shared with third parties\n• You maintain full control over your API usage'**
  String get apiKeySecurityInfo;

  /// Button text to navigate to settings
  ///
  /// In en, this message translates to:
  /// **'Go to Settings'**
  String get goToSettings;

  /// Title for analysis results section
  ///
  /// In en, this message translates to:
  /// **'Analysis Results'**
  String get analysisResults;

  /// Title for share options dialog
  ///
  /// In en, this message translates to:
  /// **'Share Options'**
  String get shareOptions;

  /// Description for share options
  ///
  /// In en, this message translates to:
  /// **'What would you like to share?'**
  String get shareOptionsDescription;

  /// Option to share audio file
  ///
  /// In en, this message translates to:
  /// **'Share Audio File'**
  String get shareAudioFile;

  /// Option to share analysis text
  ///
  /// In en, this message translates to:
  /// **'Share Analysis Text'**
  String get shareAnalysisText;

  /// Message when no analysis is available
  ///
  /// In en, this message translates to:
  /// **'No Analysis Available'**
  String get noAnalysisAvailable;

  /// Message to encourage starting analysis
  ///
  /// In en, this message translates to:
  /// **'Start analysis to get insights from your recording'**
  String get startAnalysisMessage;

  /// Label for duration
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Label for creation date
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// Title for audio player section
  ///
  /// In en, this message translates to:
  /// **'Audio Player'**
  String get audioPlayer;

  /// Title for recording details section
  ///
  /// In en, this message translates to:
  /// **'Recording Details'**
  String get recordingDetails;

  /// Error message when recording is not found
  ///
  /// In en, this message translates to:
  /// **'Recording not found'**
  String get recordingNotFound;

  /// Error message when recording fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load recording'**
  String get failedToLoadRecording;

  /// Title for recording information section
  ///
  /// In en, this message translates to:
  /// **'Recording Information'**
  String get recordingInformation;

  /// Label for file name
  ///
  /// In en, this message translates to:
  /// **'File Name'**
  String get fileName;

  /// Label for file size
  ///
  /// In en, this message translates to:
  /// **'File Size'**
  String get fileSize;

  /// Button text to reanalyze
  ///
  /// In en, this message translates to:
  /// **'Reanalyze'**
  String get reanalyze;

  /// Share button tooltip
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Delete button tooltip
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Title when analysis is complete
  ///
  /// In en, this message translates to:
  /// **'Analysis Complete'**
  String get analysisComplete;

  /// Message during AI processing
  ///
  /// In en, this message translates to:
  /// **'AI is processing your recording...'**
  String get aiProcessingMessage;

  /// Message about processing time
  ///
  /// In en, this message translates to:
  /// **'This may take a few moments'**
  String get processingTimeMessage;

  /// Message when no recordings exist
  ///
  /// In en, this message translates to:
  /// **'No recordings yet'**
  String get noRecordingsYet;

  /// Message to encourage starting recording
  ///
  /// In en, this message translates to:
  /// **'Start recording to see your summaries here'**
  String get startRecordingMessage;

  /// Error message when recordings fail to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load recordings'**
  String get failedToLoadRecordings;

  /// Title for delete recording dialog
  ///
  /// In en, this message translates to:
  /// **'Delete Recording'**
  String get deleteRecording;

  /// Confirmation message for deleting recording
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recording and its analysis? This action cannot be undone.'**
  String get deleteConfirmationMessage;

  /// Error message when audio file is not found
  ///
  /// In en, this message translates to:
  /// **'Audio file not found'**
  String get audioFileNotFound;

  /// Error message when sharing audio file fails
  ///
  /// In en, this message translates to:
  /// **'Failed to share audio file: {error}'**
  String failedToShareAudioFile(String error);

  /// Error message when no analysis content is available to share
  ///
  /// In en, this message translates to:
  /// **'No analysis content available to share'**
  String get noAnalysisContentToShare;

  /// Error message when sharing analysis text fails
  ///
  /// In en, this message translates to:
  /// **'Failed to share analysis text: {error}'**
  String failedToShareAnalysisText(String error);

  /// Subject for sharing audio analysis results
  ///
  /// In en, this message translates to:
  /// **'Audio Analysis Results'**
  String get audioAnalysisResults;

  /// Dismiss button text
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// Text for sharing audio recording with date
  ///
  /// In en, this message translates to:
  /// **'Audio recording from {date}'**
  String audioRecordingFrom(String date);

  /// Error message when URL cannot be launched
  ///
  /// In en, this message translates to:
  /// **'Could not launch {url}'**
  String couldNotLaunch(String url);

  /// Error message when API key field is empty
  ///
  /// In en, this message translates to:
  /// **'Please enter an API key'**
  String get pleaseEnterApiKey;

  /// Success message when API key is saved
  ///
  /// In en, this message translates to:
  /// **'API key saved successfully'**
  String get apiKeySavedSuccessfully;

  /// Error message when API key save fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save API key'**
  String get failedToSaveApiKey;

  /// Tip message for audio quality
  ///
  /// In en, this message translates to:
  /// **'Tip: For best results, ensure clear audio quality and minimal background noise.'**
  String get tipMessage;

  /// Menu item for summaries
  ///
  /// In en, this message translates to:
  /// **'Summaries'**
  String get summaries;

  /// Error message when audio analysis fails
  ///
  /// In en, this message translates to:
  /// **'Analysis failed'**
  String get analysisFailed;

  /// Error message when audio import fails
  ///
  /// In en, this message translates to:
  /// **'Failed to import audio'**
  String get failedToImportAudio;
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
      <String>['bn', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
