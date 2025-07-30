import 'package:dio/dio.dart';
import 'package:vocario/core/services/network_service/network_exception.dart';

String formatFileSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
}

String getMimeType(String filePath) {
  final extension = filePath.split('.').last.toLowerCase();
  switch (extension) {
    case 'mp3':
      return 'audio/mpeg';
    case 'wav':
      return 'audio/wav';
    case 'aac':
      return 'audio/aac';
    case 'm4a':
      return 'audio/mp4';
    case 'ogg':
      return 'audio/ogg';
    case 'flac':
      return 'audio/flac';
    default:
      return 'audio/mpeg'; // Default fallback
  }
}

/// Handle Dio errors and convert them to user-friendly messages
NetworkException handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return NetworkException(
        'Request timed out. Please check your internet connection and try again.',
        originalMessage: error.message,
      );

    case DioExceptionType.connectionError:
      return NetworkException(
        'Unable to connect to the server. Please check your internet connection.',
        originalMessage: error.message,
      );

    case DioExceptionType.cancel:
      return NetworkException(
        'Request was cancelled',
        originalMessage: error.message,
      );

    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      switch (statusCode) {
        case 400:
          return NetworkException(
            'Invalid request. Please check your input and try again.',
            originalMessage: error.message,
            statusCode: statusCode,
          );
        case 401:
          return NetworkException(
            'Invalid API key. Please check your API key in settings.',
            originalMessage: error.message,
            statusCode: statusCode,
          );
        case 403:
          return NetworkException(
            'Access forbidden. Please check your API key permissions.',
            originalMessage: error.message,
            statusCode: statusCode,
          );
        case 404:
          return NetworkException(
            'Service not found. Please try again later.',
            originalMessage: error.message,
            statusCode: statusCode,
          );
        case 413:
          return NetworkException(
            'File is too large. Please use a smaller file.',
            originalMessage: error.message,
            statusCode: statusCode,
          );
        case 429:
          return NetworkException(
            'Too many requests. Please wait a moment and try again.',
            originalMessage: error.message,
            statusCode: statusCode,
          );
        case 500:
        case 502:
        case 503:
        case 504:
          return NetworkException(
            'Server error. Please try again later.',
            originalMessage: error.message,
            statusCode: statusCode,
          );
        default:
          return NetworkException(
            'Request failed with status code $statusCode',
            originalMessage: error.message,
            statusCode: statusCode,
          );
      }

    case DioExceptionType.unknown:
    default:
      return NetworkException(
        'An unexpected error occurred. Please try again.',
        originalMessage: error.message,
      );
  }
}
