import 'package:equatable/equatable.dart';

abstract class AppError extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppError({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code, originalError];
}

class NetworkError extends AppError {
  const NetworkError({
    required super.message,
    super.code,
    super.originalError,
  });
}

class ServerError extends AppError {
  final int? statusCode;

  const ServerError({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  List<Object?> get props => [...super.props, statusCode];
}

class ValidationError extends AppError {
  final Map<String, String>? fieldErrors;

  const ValidationError({
    required super.message,
    super.code,
    super.originalError,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

class AuthenticationError extends AppError {
  const AuthenticationError({
    required super.message,
    super.code,
    super.originalError,
  });
}

class AuthorizationError extends AppError {
  const AuthorizationError({
    required super.message,
    super.code,
    super.originalError,
  });
}

class FileError extends AppError {
  final String? fileName;
  final String? fileType;

  const FileError({
    required super.message,
    super.code,
    super.originalError,
    this.fileName,
    this.fileType,
  });

  @override
  List<Object?> get props => [...super.props, fileName, fileType];
}

class AudioProcessingError extends AppError {
  final Duration? audioDuration;
  final String? audioFormat;

  const AudioProcessingError({
    required super.message,
    super.code,
    super.originalError,
    this.audioDuration,
    this.audioFormat,
  });

  @override
  List<Object?> get props => [...super.props, audioDuration, audioFormat];
}

class CacheError extends AppError {
  const CacheError({
    required super.message,
    super.code,
    super.originalError,
  });
}

class UnknownError extends AppError {
  const UnknownError({
    required super.message,
    super.code,
    super.originalError,
  });
}