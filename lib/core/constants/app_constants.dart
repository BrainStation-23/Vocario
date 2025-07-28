class AppConstants {
  // App Information
  static const String appName = 'Vocario';
  static const String appDescription = 'AI Audio Summarizer';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'https://api.vocario.com';
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userPreferencesKey = 'user_preferences';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Audio Configuration
  static const int maxAudioDurationMinutes = 60;
  static const int maxFileSizeMB = 100;
  static const List<String> supportedAudioFormats = [
    'mp3',
    'wav',
    'aac',
    'm4a',
    'flac',
  ];
  static const List<String> supportedVideoFormats = [
    'mp4',
    'avi',
    'mov',
    'mkv',
    'webm',
  ];

  // UI Configuration
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Error Messages
  static const String networkErrorMessage = 'Network connection failed. Please check your internet connection.';
  static const String serverErrorMessage = 'Server error occurred. Please try again later.';
  static const String unknownErrorMessage = 'An unexpected error occurred. Please try again.';
  static const String fileTooLargeMessage = 'File size exceeds the maximum limit of {maxSize}MB.';
  static const String unsupportedFormatMessage = 'Unsupported file format. Please use: {formats}';
  static const String audioDurationExceededMessage = 'Audio duration exceeds the maximum limit of {maxDuration} minutes.';

  // Success Messages
  static const String uploadSuccessMessage = 'File uploaded successfully!';
  static const String summarizationCompleteMessage = 'Audio summarization completed!';
  static const String settingsSavedMessage = 'Settings saved successfully!';

  // Feature Flags
  static const bool enableDarkMode = true;
  static const bool enableOfflineMode = false;
  static const bool enableAnalytics = true;
  static const bool enableCrashReporting = true;
}