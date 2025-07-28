import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:vocario/features/audio_analyzer/data/models/audio_analysis_model.dart';
import 'package:vocario/features/audio_analyzer/data/services/gemini_api_service.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_analyzer/domain/repositories/audio_analyzer_repository.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/core/services/logger_service.dart';

class AudioAnalyzerRepositoryImpl implements AudioAnalyzerRepository {
  final GeminiApiService _geminiApiService;
  static const String _analysesFileName = 'audio_analyses.json';

  AudioAnalyzerRepositoryImpl(this._geminiApiService);

  @override
  Future<AudioAnalysis> analyzeAudio(AudioRecording recording) async {
    try {
      LoggerService.info('Starting audio analysis for recording: ${recording.id}');
      
      // Create initial analysis record
      final analysis = AudioAnalysisModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        recordingId: recording.id,
        status: AnalysisStatus.analyzing,
        createdAt: DateTime.now(),
      );

      // Save initial state
      await _saveAnalysis(analysis);

      try {
        // Upload audio file to Gemini
        final fileUri = await _geminiApiService.uploadAudioFile(recording.filePath);
        final mimeType = _getMimeType(recording.filePath);
        
        // Generate content analysis
        final analysisResult = await _geminiApiService.generateContent(fileUri, mimeType);
        
        // Parse key points
        final keyPoints = <String>[];
        if (analysisResult['keyPoints'] is List) {
          keyPoints.addAll((analysisResult['keyPoints'] as List).cast<String>());
        } else if (analysisResult['keyPoints'] is String) {
          // If it's a string, try to split by common delimiters
          final keyPointsStr = analysisResult['keyPoints'] as String;
          keyPoints.addAll(
            keyPointsStr
                .split(RegExp(r'[\n•\-\*]'))
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList(),
          );
        }

        // Create completed analysis
        final completedAnalysis = analysis.copyWith(
          transcript: analysisResult['transcript']?.toString(),
          summary: analysisResult['summary']?.toString(),
          keyPoints: keyPoints,
          sentiment: analysisResult['sentiment']?.toString(),
          status: AnalysisStatus.completed,
          completedAt: DateTime.now(),
        );

        // Save completed analysis
        await _saveAnalysis(completedAnalysis);
        
        LoggerService.info('Audio analysis completed successfully for recording: ${recording.id}');
        return completedAnalysis;
      } catch (e) {
        LoggerService.error('Audio analysis failed for recording: ${recording.id}', e);
        
        // Save failed analysis
        final failedAnalysis = analysis.copyWith(
          status: AnalysisStatus.failed,
          errorMessage: e.toString(),
          completedAt: DateTime.now(),
        );
        
        await _saveAnalysis(failedAnalysis);
        return failedAnalysis;
      }
    } catch (e) {
      LoggerService.error('Failed to start audio analysis', e);
      rethrow;
    }
  }

  @override
  Future<List<AudioAnalysis>> getAllAnalyses() async {
    try {
      final file = await _getAnalysesFile();
      if (!await file.exists()) {
        return [];
      }

      final jsonString = await file.readAsString();
      final jsonList = json.decode(jsonString) as List;
      
      return jsonList
          .map((json) => AudioAnalysisModel.fromJson(json as Map<String, dynamic>) as AudioAnalysis)
          .toList();
    } catch (e) {
      LoggerService.error('Failed to get all analyses', e);
      return [];
    }
  }

  @override
  Future<AudioAnalysis?> getAnalysisById(String analysisId) async {
    try {
      final analyses = await getAllAnalyses();
      return analyses.where((analysis) => analysis.id == analysisId).firstOrNull;
    } catch (e) {
      LoggerService.error('Failed to get analysis by id: $analysisId', e);
      return null;
    }
  }

  @override
  Future<AudioAnalysis?> getAnalysisByRecordingId(String recordingId) async {
    try {
      final analyses = await getAllAnalyses();
      return analyses.where((analysis) => analysis.recordingId == recordingId).firstOrNull;
    } catch (e) {
      LoggerService.error('Failed to get analysis by recording id: $recordingId', e);
      return null;
    }
  }

  @override
  Future<void> deleteAnalysis(String analysisId) async {
    try {
      final analyses = await getAllAnalyses();
      final updatedAnalyses = analyses.where((analysis) => analysis.id != analysisId).toList();
      await _saveAllAnalyses(updatedAnalyses);
      LoggerService.info('Deleted analysis: $analysisId');
    } catch (e) {
      LoggerService.error('Failed to delete analysis: $analysisId', e);
      rethrow;
    }
  }

  Future<void> _saveAnalysis(AudioAnalysis analysis) async {
    try {
      final analyses = await getAllAnalyses();
      final existingIndex = analyses.indexWhere((a) => a.id == analysis.id);
      
      if (existingIndex >= 0) {
        analyses[existingIndex] = analysis;
      } else {
        analyses.add(analysis);
      }
      
      await _saveAllAnalyses(analyses);
    } catch (e) {
      LoggerService.error('Failed to save analysis', e);
      rethrow;
    }
  }

  Future<void> _saveAllAnalyses(List<AudioAnalysis> analyses) async {
    try {
      final file = await _getAnalysesFile();
      final jsonList = analyses
          .map((analysis) => AudioAnalysisModel.fromEntity(analysis).toJson())
          .toList();
      
      await file.writeAsString(json.encode(jsonList));
    } catch (e) {
      LoggerService.error('Failed to save all analyses', e);
      rethrow;
    }
  }

  Future<File> _getAnalysesFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_analysesFileName');
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
        return 'audio/mpeg';
    }
  }
}