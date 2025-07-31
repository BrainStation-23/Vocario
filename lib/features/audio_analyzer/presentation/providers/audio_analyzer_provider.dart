import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocario/features/audio_analyzer/data/repositories/audio_analyzer_repository_impl.dart';
import 'package:vocario/core/services/network_service/gemini_api_service.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_analyzer/domain/repositories/audio_analyzer_repository.dart';
import 'package:vocario/features/audio_analyzer/domain/usecases/analyze_audio.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/core/services/logger_service.dart';

part 'audio_analyzer_provider.g.dart';

@riverpod
AudioAnalyzerRepository audioAnalyzerRepository(Ref ref) {
  final geminiApiService = GeminiApiService();
  return AudioAnalyzerRepositoryImpl(geminiApiService);
}

@riverpod
AnalyzeAudio analyzeAudioUseCase(Ref ref) {
  final repository = ref.watch(audioAnalyzerRepositoryProvider);
  return AnalyzeAudio(repository);
}

@riverpod
Future<List<AudioAnalysis>> audioAnalysesList(Ref ref) async {
  final repository = ref.watch(audioAnalyzerRepositoryProvider);
  return await repository.getAllAnalyses();
}

@riverpod
Future<AudioAnalysis?> audioAnalysisById(
  Ref ref,
  String analysisId,
) async {
  final repository = ref.watch(audioAnalyzerRepositoryProvider);
  return await repository.getAnalysisById(analysisId);
}

@riverpod
Future<AudioAnalysis?> audioAnalysisByRecordingId(
  Ref ref,
  String recordingId,
) async {
  final repository = ref.watch(audioAnalyzerRepositoryProvider);
  return await repository.getAnalysisByRecordingId(recordingId);
}

enum AudioAnalyzerState {
  idle,
  analyzing,
  completed,
  error,
}

@riverpod
class AudioAnalyzerNotifier extends _$AudioAnalyzerNotifier {
  @override
  AudioAnalyzerState build() {
    return AudioAnalyzerState.idle;
  }

  Future<AudioAnalysis> analyzeAudio(AudioRecording recording) async {
    try {
      state = AudioAnalyzerState.analyzing;
      LoggerService.info('Starting audio analysis for recording: ${recording.id}');
      
      final useCase = ref.read(analyzeAudioUseCaseProvider);
      final analysis = await useCase(recording);
      
      if (analysis.status == AnalysisStatus.completed) {
        state = AudioAnalyzerState.completed;
      } else {
        state = AudioAnalyzerState.error;
      }
      
      // Refresh the analyses list
      ref.invalidate(audioAnalysesListProvider);
      ref.invalidate(audioAnalysisByRecordingIdProvider);
      
      return analysis;
    } catch (e) {
      LoggerService.error('Failed to analyze audio', e);
      state = AudioAnalyzerState.error;
      rethrow;
    }
  }

  void reset() {
    state = AudioAnalyzerState.idle;
  }
}