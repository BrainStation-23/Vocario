import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:vocario/core/services/network_service/network_utils.dart';
import 'package:vocario/core/services/storage_service.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_summarization_context.dart';
import 'package:vocario/core/services/network_service/network_exception.dart';

class GeminiApiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com';
  static const int _maxFileSizeBytes = 200 * 1024 * 1024; // 200MB limit
  static const Duration _defaultTimeout = Duration(minutes: 10);
  
  final Dio _dio;
  CancelToken? _currentCancelToken;

  GeminiApiService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = _defaultTimeout;
    _dio.options.receiveTimeout = _defaultTimeout;
    _dio.options.sendTimeout = _defaultTimeout;
    
    // Add interceptor for better error handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onError: (error, handler) {
          final customError = handleDioError(error);
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: customError,
            type: error.type,
            response: error.response,
          ));
        },
      ),
    );
  }

  /// Cancel any ongoing operations
  void cancelOperations() {
    _currentCancelToken?.cancel('Operation cancelled by user');
    _currentCancelToken = null;
  }

  Future<void> _ensureApiKeySet() async {
    final apiKey = await StorageService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw const NetworkException(
        'Gemini API key not found.',
      );
    }
    _dio.options.headers['x-goog-api-key'] = apiKey;
  }

  /// Upload audio file with support for large files and cancellation
  Future<String> uploadAudioFile(
    String filePath, {
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    _currentCancelToken = cancelToken ?? CancelToken();
    
    try {
      await _ensureApiKeySet();
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw const NetworkException('Audio file not found');
      }

      final fileStats = await file.stat();
      final numBytes = fileStats.size;
      
      // Check file size limit
      if (numBytes > _maxFileSizeBytes) {
        throw NetworkException(
          'File size (${formatFileSize(numBytes)}) exceeds the maximum limit of ${formatFileSize(_maxFileSizeBytes)}',
        );
      }
      
      LoggerService.info('Uploading audio file: $filePath (${formatFileSize(numBytes)})');

      return await _uploadFile(
        file,
        getMimeType(filePath),
        numBytes,
        onSendProgress,
      );
    } catch (e) {
      LoggerService.error('Failed to upload audio file', e);
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException('Upload failed: ${e.toString()}');
    } finally {
      _currentCancelToken = null;
    }
  }

  Future<String> _uploadFile(
    File file,
    String mimeType,
    int numBytes,
    void Function(int sent, int total)? onSendProgress,
  ) async {
    // Step 1: Initial resumable request
    final uploadResponse = await _dio.post(
      '/upload/v1beta/files',
      cancelToken: _currentCancelToken,
      options: Options(
        headers: {
          'X-Goog-Upload-Protocol': 'resumable',
          'X-Goog-Upload-Command': 'start',
          'X-Goog-Upload-Header-Content-Length': numBytes.toString(),
          'X-Goog-Upload-Header-Content-Type': mimeType,
          'Content-Type': 'application/json',
        },
      ),
      data: {
        'file': {
          'display_name': 'AUDIO_${DateTime.now().millisecondsSinceEpoch}'
        }
      },
    );

    final uploadUrl = uploadResponse.headers['x-goog-upload-url']?.first;
    if (uploadUrl == null) {
      throw const NetworkException(
        'Upload URL not found in response headers',
      );
    }

    LoggerService.info('Got upload URL: $uploadUrl');

    // Step 2: Upload the actual bytes
    final uploadBytesResponse = await _dio.put(
      uploadUrl,
      cancelToken: _currentCancelToken,
      onSendProgress: onSendProgress,
      options: Options(
        headers: {
          'Content-Type': mimeType,
          'X-Goog-Upload-Offset': '0',
          'X-Goog-Upload-Command': 'upload, finalize',
          'Transfer-Encoding': 'chunked',
        },
      ),
      data: file.openRead(),
    );

    final fileInfo = uploadBytesResponse.data;
    final fileUri = fileInfo['file']['uri'] as String;
    
    LoggerService.info('File uploaded successfully: $fileUri');
    return fileUri;
  }

  /// Generate content with cancellation support
  Future<String> generateContent(
    String fileUri, 
    String mimeType, {
    AudioSummarizationContext? usageContext,
    CancelToken? cancelToken,
  }) async {
    _currentCancelToken = cancelToken ?? CancelToken();
    
    try {
      await _ensureApiKeySet();
      
      LoggerService.info('Generating content for file: $fileUri');
      
      final response = await _dio.post(
        '/v1beta/models/gemini-2.5-flash:generateContent',
        cancelToken: _currentCancelToken,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'contents': [
            {
              'parts': [
                {
                  'text': await _getPromptText(usageContext)
                },
                {
                  'file_data': {
                    'mime_type': mimeType,
                    'file_uri': fileUri
                  }
                }
              ]
            }
          ]
        },
      );

      final candidates = response.data['candidates'] as List;
      if (candidates.isEmpty) {
        throw const NetworkException(
          'No candidates in response',
        );
      }

      final content = candidates.first['content'];
      final parts = content['parts'] as List;
      if (parts.isEmpty) {
        throw const NetworkException(
          'No parts in content',
        );
      }

      final text = (parts.first['text'] as String).trim();
      LoggerService.info('Generated content successfully');
      return text;
    } catch (e) {
      LoggerService.error('Failed to generate content', e);
      if (e is NetworkException) {
        rethrow;
      }
      throw NetworkException('Content generation failed: ${e.toString()}');
    } finally {
      _currentCancelToken = null;
    }
  }

  Future<String> _getPromptText(AudioSummarizationContext? usageContext) async {
    if (usageContext == null) {
      final savedUsageContext = await StorageService.getUsageContext();
      if (savedUsageContext != null) {
        try {
          usageContext = AudioSummarizationContext.values.firstWhere(
            (context) => context.name == savedUsageContext,
          );
        } catch (e) {
          LoggerService.warning('Invalid saved usage context: $savedUsageContext');
        }
      }
    }
    
    if (usageContext != null) {
      LoggerService.info('Using prompt for usage context: ${usageContext.displayName}');
      return usageContext.prompt;
    } else {
      throw const NetworkException(
        'No usage context provided',
      );
    }
  }
}