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
  String get importAudioFeatureComingSoon =>
      'Import Audio feature coming soon!';

  @override
  String get importVideoFeatureComingSoon =>
      'Import Video feature coming soon!';
}
