import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:vocario/core/services/logger_service.dart';

class GeminiApiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com';
  static const String _apiKey = ''; // TODO: Move to environment variables
  
  final Dio _dio;

  GeminiApiService() : _dio = Dio() {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.headers = {
      'x-goog-api-key': _apiKey,
    };
  }

  Future<String> uploadAudioFile(String filePath) async {
    try {
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

  Future<Map<String, dynamic>> generateContent(String fileUri, String mimeType) async {
    try {
      LoggerService.info('Generating content for file: $fileUri');
      
      final response = await _dio.post(
        '/v1beta/models/gemini-2.0-flash-exp:generateContent',
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
                  'text': '''Please analyze this audio recording and provide:
1. A complete transcript of the audio
2. A concise summary (2-3 sentences)
3. Key points (3-5 bullet points)
4. Sentiment analysis (positive/negative/neutral with brief explanation)

Format your response as JSON with the following structure:
{
  "transcript": "full transcript here",
  "summary": "summary here",
  "keyPoints": ["point 1", "point 2", "point 3"],
  "sentiment": "sentiment analysis here"
}'''
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

      final text = parts.first['text'] as String;
      LoggerService.info('Generated content: $text');
      
      // Try to parse JSON from the response
      try {
        // Extract JSON from the response text
        final jsonMatch = RegExp(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}').firstMatch(text);
        if (jsonMatch != null) {
          final jsonStr = jsonMatch.group(0)!;
          return json.decode(jsonStr) as Map<String, dynamic>;
        }
      } catch (e) {
        LoggerService.warning('Failed to parse JSON from response, using fallback parsing');
      }
      
      // Fallback: parse manually if JSON parsing fails
      return _parseResponseManually(text);
    } catch (e) {
      LoggerService.error('Failed to generate content', e);
      rethrow;
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

  Map<String, dynamic> _parseResponseManually(String text) {
    // Fallback parsing if JSON parsing fails
    final result = <String, dynamic>{
      'transcript': '',
      'summary': '',
      'keyPoints': <String>[],
      'sentiment': '',
    };

    // Simple regex-based parsing as fallback
    final transcriptMatch = RegExp(r'transcript["\s]*:["\s]*([^"\n]+)', caseSensitive: false).firstMatch(text);
    if (transcriptMatch != null) {
      result['transcript'] = transcriptMatch.group(1)?.trim() ?? '';
    }

    final summaryMatch = RegExp(r'summary["\s]*:["\s]*([^"\n]+)', caseSensitive: false).firstMatch(text);
    if (summaryMatch != null) {
      result['summary'] = summaryMatch.group(1)?.trim() ?? '';
    }

    final sentimentMatch = RegExp(r'sentiment["\s]*:["\s]*([^"\n]+)', caseSensitive: false).firstMatch(text);
    if (sentimentMatch != null) {
      result['sentiment'] = sentimentMatch.group(1)?.trim() ?? '';
    }

    // If parsing fails, use the entire text as transcript
    if (result['transcript'].toString().isEmpty) {
      result['transcript'] = text;
      result['summary'] = 'Analysis completed';
      result['sentiment'] = 'neutral';
    }

    return result;
  }
}