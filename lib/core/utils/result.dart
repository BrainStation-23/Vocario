import 'package:equatable/equatable.dart';
import 'package:vocario/core/error/app_error.dart';

abstract class Result<T> extends Equatable {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => isSuccess ? (this as Success<T>).data : null;
  AppError? get error => isFailure ? (this as Failure<T>).error : null;

  // Transform the result if it's successful
  Result<R> map<R>(R Function(T data) transform) {
    if (isSuccess) {
      try {
        return Success(transform((this as Success<T>).data));
      } catch (e) {
        return Failure(UnknownError(
          message: 'Error transforming result: $e',
          originalError: e,
        ));
      }
    }
    return Failure((this as Failure<T>).error);
  }

  // Transform the result asynchronously if it's successful
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    if (isSuccess) {
      try {
        final result = await transform((this as Success<T>).data);
        return Success(result);
      } catch (e) {
        return Failure(UnknownError(
          message: 'Error transforming result: $e',
          originalError: e,
        ));
      }
    }
    return Failure((this as Failure<T>).error);
  }

  // Execute a function if the result is successful
  Result<T> onSuccess(void Function(T data) action) {
    if (isSuccess) {
      action((this as Success<T>).data);
    }
    return this;
  }

  // Execute a function if the result is a failure
  Result<T> onFailure(void Function(AppError error) action) {
    if (isFailure) {
      action((this as Failure<T>).error);
    }
    return this;
  }

  // Get the data or throw the error
  T getOrThrow() {
    if (isSuccess) {
      return (this as Success<T>).data;
    }
    throw (this as Failure<T>).error;
  }

  // Get the data or return a default value
  T getOrDefault(T defaultValue) {
    if (isSuccess) {
      return (this as Success<T>).data;
    }
    return defaultValue;
  }

  // Get the data or compute it from the error
  T getOrElse(T Function(AppError error) orElse) {
    if (isSuccess) {
      return (this as Success<T>).data;
    }
    return orElse((this as Failure<T>).error);
  }

  @override
  List<Object?> get props => [
    if (isSuccess) (this as Success<T>).data,
    if (isFailure) (this as Failure<T>).error,
  ];
}

class Success<T> extends Result<T> {
  @override
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';
}

class Failure<T> extends Result<T> {
  @override
  final AppError error;

  const Failure(this.error);

  @override
  String toString() => 'Failure(error: $error)';
}

// Helper functions for creating results
Result<T> success<T>(T data) => Success(data);
Result<T> failure<T>(AppError error) => Failure(error);

// Extension for Future<Result<T>>
extension FutureResultExtension<T> on Future<Result<T>> {
  Future<Result<R>> mapAsync<R>(Future<R> Function(T data) transform) async {
    final result = await this;
    return result.mapAsync(transform);
  }

  Future<Result<T>> onSuccessAsync(Future<void> Function(T data) action) async {
    final result = await this;
    if (result.isSuccess) {
      await action(result.data as T);
    }
    return result;
  }

  Future<Result<T>> onFailureAsync(Future<void> Function(AppError error) action) async {
    final result = await this;
    if (result.isFailure) {
      await action(result.error!);
    }
    return result;
  }
}