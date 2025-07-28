import 'package:dio/dio.dart';
import 'package:vocario/core/constants/app_constants.dart';
import 'package:vocario/core/services/logger_service.dart';

class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();

  late final Dio _dio;

  void initialize() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_createLoggingInterceptor());
    _dio.interceptors.add(_createAuthInterceptor());
    _dio.interceptors.add(_createErrorInterceptor());
  }

  // GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      LoggerService.logApiRequest('GET', path, data: queryParameters);
      final response = await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      LoggerService.logApiResponse('GET', path, response.statusCode ?? 0, data: response.data);
      return response;
    } catch (e, stackTrace) {
      LoggerService.logApiError('GET', path, e, stackTrace);
      rethrow;
    }
  }

  // POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      LoggerService.logApiRequest('POST', path, data: data);
      final response = await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      LoggerService.logApiResponse('POST', path, response.statusCode ?? 0, data: response.data);
      return response;
    } catch (e, stackTrace) {
      LoggerService.logApiError('POST', path, e, stackTrace);
      rethrow;
    }
  }

  // PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      LoggerService.logApiRequest('PUT', path, data: data);
      final response = await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      LoggerService.logApiResponse('PUT', path, response.statusCode ?? 0, data: response.data);
      return response;
    } catch (e, stackTrace) {
      LoggerService.logApiError('PUT', path, e, stackTrace);
      rethrow;
    }
  }

  // DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      LoggerService.logApiRequest('DELETE', path, data: data);
      final response = await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      LoggerService.logApiResponse('DELETE', path, response.statusCode ?? 0, data: response.data);
      return response;
    } catch (e, stackTrace) {
      LoggerService.logApiError('DELETE', path, e, stackTrace);
      rethrow;
    }
  }

  // Upload file
  Future<Response<T>> uploadFile<T>(
    String path,
    String filePath,
    String fileName, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
        ...?data,
      });

      LoggerService.logApiRequest('POST', path, data: {'file': fileName, ...?data});
      final response = await _dio.post<T>(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );
      LoggerService.logApiResponse('POST', path, response.statusCode ?? 0);
      return response;
    } catch (e, stackTrace) {
      LoggerService.logApiError('POST', path, e, stackTrace);
      rethrow;
    }
  }

  // Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Create logging interceptor
  Interceptor _createLoggingInterceptor() {
    return LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => LoggerService.debug(object.toString()),
    );
  }

  // Create auth interceptor
  Interceptor _createAuthInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add any auth logic here if needed
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized access
          LoggerService.warning('Unauthorized access detected');
          // TODO: Implement token refresh or redirect to login
        }
        handler.next(error);
      },
    );
  }

  // Create error interceptor
  Interceptor _createErrorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        String errorMessage;
        switch (error.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = AppConstants.networkErrorMessage;
            break;
          case DioExceptionType.badResponse:
            errorMessage = AppConstants.serverErrorMessage;
            break;
          default:
            errorMessage = AppConstants.unknownErrorMessage;
        }
        
        LoggerService.error('Network Error: $errorMessage', error);
        handler.next(error);
      },
    );
  }
}