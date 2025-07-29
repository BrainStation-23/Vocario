import 'dart:io';
import 'package:dio/dio.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:vocario/core/services/storage_service.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_summarization_context.dart';

class GeminiApiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com';
  
  final Dio _dio;

  GeminiApiService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
  }

  Future<void> _ensureApiKeySet() async {
    final apiKey = await StorageService.getApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('API key not found. Please set your Gemini API key in settings.');
    }
    _dio.options.headers['x-goog-api-key'] = apiKey;
  }

  Future<String> uploadAudioFile(String filePath) async {
    try {
      await _ensureApiKeySet();
      
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: $filePath');
      }

      final fileBytes = await file.readAsBytes();
      final mimeType = _getMimeType(filePath);
      final numBytes = fileBytes.length;
      
      LoggerService.info('Uploading audio file: $filePath ($numBytes bytes)');

      // Step 1: Initial resumable request
      final uploadResponse = await _dio.post(
        '/upload/v1beta/files',
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
        throw Exception('Upload URL not found in response headers');
      }

      LoggerService.info('Got upload URL: $uploadUrl');

      // Step 2: Upload the actual bytes
      final uploadBytesResponse = await _dio.put(
        uploadUrl,
        options: Options(
          headers: {
            'Content-Length': numBytes.toString(),
            'Content-Type': mimeType,
            'X-Goog-Upload-Offset': '0',
            'X-Goog-Upload-Command': 'upload, finalize',
          },
        ),
        data: fileBytes,
      );

      final fileInfo = uploadBytesResponse.data;
      final fileUri = fileInfo['file']['uri'] as String;
      
      LoggerService.info('File uploaded successfully: $fileUri');
      return fileUri;
    } catch (e) {
      LoggerService.error('Failed to upload audio file', e);
      rethrow;
    }
  }

  Future<String> generateContent(String fileUri, String mimeType, {AudioSummarizationContext? usageContext}) async {
    try {
      await _ensureApiKeySet();
      
      LoggerService.info('Generating content for file: $fileUri');
      
      final response = await _dio.post(
        '/v1beta/models/gemini-2.5-flash:generateContent',
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
        throw Exception('No candidates in response');
      }

      final content = candidates.first['content'];
      final parts = content['parts'] as List;
      if (parts.isEmpty) {
        throw Exception('No parts in content');
      }

      final text = (parts.first['text'] as String).trim();
      LoggerService.info('Generated content: $text');
      return text;
    } catch (e) {
      LoggerService.error('Failed to generate content', e);
      rethrow;
    }
  }

  Future<String> _getPromptText(AudioSummarizationContext? usageContext) async {
    // If no usage context provided, try to get it from storage
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
    
    // Return the appropriate prompt or fallback to default
    if (usageContext != null) {
      LoggerService.info('Using prompt for usage context: ${usageContext.displayName}');
      return usageContext.prompt;
    } else {
      LoggerService.info('Using default prompt');
      return '''Please analyze this audio recording and provide:
1. A complete transcript of the audio
2. A concise summary (2-3 sentences)
3. Key points (3-5 bullet points)
4. Sentiment analysis (positive/negative/neutral with brief explanation)

IMPORTANT: Return ONLY valid HTML formatted text with proper HTML tags. Use basic HTML tags like <h1>, <h2>, <p>, <ul>, <li>, <strong>, <em> for formatting. Do NOT use markdown - only HTML tags.Do not include any prefixes like "html" or "markdown" in your response. Start your response directly with the relevant HTML tags.''';
    }
  }

  String _getMimeType(String filePath) {
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
}