// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcomeTitle => 'Welcome to Vocario';

  @override
  String get welcomeSubtitle =>
      'AI-powered audio summarization at your fingertips';

  @override
  String get importAudio => 'Import Audio';

  @override
  String get importVideo => 'Import Video';

  @override
  String get importMedia => 'Import Media';

  @override
  String get record => 'Record';

  @override
  String get settings => 'Settings';

  @override
  String get appearance => 'Appearance';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get bengali => 'বাংলা (Bengali)';

  @override
  String get settingsSubtitle => 'Configure your app preferences';

  @override
  String get emailAddress => 'Email Address (Optional)';

  @override
  String get emailHint => 'your.email@example.com';

  @override
  String get emailDescription =>
      'Pre-fill your email when sharing meeting summaries';

  @override
  String get geminiApiKey => 'Gemini API Key';

  @override
  String get apiKeyHint => 'Enter your Gemini API key';

  @override
  String get getApiKey => 'Get your API key from Google AI Studio';

  @override
  String get apiKeyInfo =>
      'Your API key is stored locally on your device and never shared. It\'s required for generating meeting summaries.';

  @override
  String get aboutUs => 'About Us';

  @override
  String get ourMission => 'Our Mission';

  @override
  String get ourVision => 'Our Vision';

  @override
  String get whyWeBuildVocario => 'Why We Built Vocario';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get website => 'Website';

  @override
  String get email => 'Email';

  @override
  String get companyName => 'Brain Station 23';

  @override
  String get companyTagline =>
      'Leading Software Development & IT Service Provider';

  @override
  String get missionContent =>
      'Your trusted companion for digital leadership by empowering people to achieve more with less';

  @override
  String get visionContent =>
      'To be the fastest digital transformation and innovation partner by engaging global talents thus creating positive impact.';

  @override
  String get appPurposeContent =>
      'We developed Vocario as part of our commitment to serve our country by providing innovative solutions that help people communicate more effectively and efficiently through voice technology.';

  @override
  String get copyright => '© 2024 Brain Station 23 PLC. All rights reserved.';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get selectUsageContext => 'Select Usage Context';

  @override
  String get doctorConsultation => 'Doctor Consultation';

  @override
  String get meetingMinutes => 'Meeting Minutes';

  @override
  String get lectureSummary => 'Lecture Summary';

  @override
  String get cookingInstructions => 'Cooking Instructions';

  @override
  String get doctorConsultationDescription =>
      'Summarize medical consultations with structured clinical information';

  @override
  String get meetingMinutesDescription =>
      'Generate structured meeting summaries with action items and decisions';

  @override
  String get lectureSummaryDescription =>
      'Create educational summaries with key concepts and learning points';

  @override
  String get cookingInstructionsDescription =>
      'Extract step-by-step cooking instructions with ingredients and techniques';

  @override
  String get reanalysisFailed =>
      'Reanalysis failed. Previous analysis restored.';

  @override
  String get recordingDeletedSuccessfully =>
      'Recording and analysis deleted successfully';

  @override
  String failedToDelete(String error) {
    return 'Failed to delete: $error';
  }

  @override
  String get usageContextDescription =>
      'Choose the type of content you\'re recording to get the best summarization results.';

  @override
  String get cancel => 'Cancel';

  @override
  String get recordingMode => 'Recording Mode';

  @override
  String get change => 'Change';

  @override
  String get apiKeyRequired => 'API Key Required';

  @override
  String get apiKeyDescription =>
      'To analyze your audio recordings, Vocario needs a Gemini API key. This key is stored securely on your device and is only used to process your audio content.';

  @override
  String get apiKeySecurityInfo =>
      '• Your API key is stored locally and encrypted\n• No data is shared with third parties\n• You maintain full control over your API usage';

  @override
  String get goToSettings => 'Go to Settings';

  @override
  String get analysisResults => 'Analysis Results';

  @override
  String get shareOptions => 'Share Options';

  @override
  String get shareOptionsDescription => 'What would you like to share?';

  @override
  String get shareAudioFile => 'Share Audio File';

  @override
  String get shareAnalysisText => 'Share Analysis Text';

  @override
  String get noAnalysisAvailable => 'No Analysis Available';

  @override
  String get startAnalysisMessage =>
      'Start analysis to get insights from your recording';

  @override
  String get duration => 'Duration';

  @override
  String get created => 'Created';

  @override
  String get audioPlayer => 'Audio Player';

  @override
  String get recordingDetails => 'Recording Details';

  @override
  String get recordingNotFound => 'Recording not found';

  @override
  String get failedToLoadRecording => 'Failed to load recording';

  @override
  String get recordingInformation => 'Recording Information';

  @override
  String get fileName => 'File Name';

  @override
  String get fileSize => 'File Size';

  @override
  String get reanalyze => 'Reanalyze';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String get analysisComplete => 'Analysis Complete';

  @override
  String get aiProcessingMessage => 'AI is processing your recording...';

  @override
  String get processingTimeMessage => 'This may take a few moments';

  @override
  String get noRecordingsYet => 'No recordings yet';

  @override
  String get startRecordingMessage =>
      'Start recording to see your summaries here';

  @override
  String get failedToLoadRecordings => 'Failed to load recordings';

  @override
  String get deleteRecording => 'Delete Recording';

  @override
  String get deleteConfirmationMessage =>
      'Are you sure you want to delete this recording and its analysis? This action cannot be undone.';

  @override
  String get audioFileNotFound => 'Audio file not found';

  @override
  String failedToShareAudioFile(String error) {
    return 'Failed to share audio file: $error';
  }

  @override
  String get noAnalysisContentToShare =>
      'No analysis content available to share';

  @override
  String failedToShareAnalysisText(String error) {
    return 'Failed to share analysis text: $error';
  }

  @override
  String get audioAnalysisResults => 'Audio Analysis Results';

  @override
  String get dismiss => 'Dismiss';

  @override
  String audioRecordingFrom(String date) {
    return 'Audio recording from $date';
  }

  @override
  String couldNotLaunch(String url) {
    return 'Could not launch $url';
  }

  @override
  String get pleaseEnterApiKey => 'Please enter an API key';

  @override
  String get apiKeySavedSuccessfully => 'API key saved successfully';

  @override
  String get failedToSaveApiKey => 'Failed to save API key';

  @override
  String get tipMessage =>
      'Tip: For best results, ensure clear audio quality and minimal background noise.';

  @override
  String get summaries => 'Summaries';

  @override
  String get analysisFailed => 'Analysis failed';

  @override
  String get failedToImportMedia => 'Failed to import media';

  @override
  String get failedToAnalyzeMedia => 'Failed to analyze media';

  @override
  String get analysisInProgress => 'Analysis in Progress';

  @override
  String get analysisInProgressMessage =>
      'Audio analysis is currently in progress. If you leave now, the progress will be lost and the operation will be cancelled.';

  @override
  String get leaveAnyway => 'Leave Anyway';

  @override
  String get copy => 'Copy';

  @override
  String get analysisCopiedToClipboard => 'Analysis copied to clipboard';

  @override
  String get noAnalysisContentToCopy => 'No analysis content available to copy';

  @override
  String failedToCopyAnalysisText(String error) {
    return 'Failed to copy analysis text: $error';
  }
}
