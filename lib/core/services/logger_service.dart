import 'package:logger/logger.dart';

class LoggerService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTime,
    ),
  );

  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Log API requests
  static void logApiRequest(String method, String url, {Map<String, dynamic>? data}) {
    info('API Request: $method $url', data);
  }

  // Log API responses
  static void logApiResponse(String method, String url, int statusCode, {dynamic data}) {
    info('API Response: $method $url - Status: $statusCode', data);
  }

  // Log API errors
  static void logApiError(String method, String url, dynamic error, [StackTrace? stackTrace]) {
    LoggerService.error('API Error: $method $url', error, stackTrace);
  }

  // Log user actions
  static void logUserAction(String action, {Map<String, dynamic>? parameters}) {
    info('User Action: $action', parameters);
  }

  // Log navigation
  static void logNavigation(String from, String to) {
    info('Navigation: $from -> $to');
  }

  // Log file operations
  static void logFileOperation(String operation, String fileName, {String? result}) {
    info('File Operation: $operation - $fileName', result);
  }

  // Log performance metrics
  static void logPerformance(String operation, Duration duration) {
    info('Performance: $operation took ${duration.inMilliseconds}ms');
  }
}