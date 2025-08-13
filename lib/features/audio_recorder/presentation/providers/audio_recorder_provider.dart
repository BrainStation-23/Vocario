import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/start_recording.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/stop_recording.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/toggle_recording.dart';
import 'package:vocario/features/audio_recorder/data/repositories/audio_recorder_repository_impl.dart';
import 'package:vocario/features/audio_recorder/domain/repositories/audio_recorder_repository.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/audio_analyzer_provider.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/recordings_provider.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:vocario/core/routing/app_router.dart';

part 'audio_recorder_provider.g.dart';

@Riverpod(keepAlive: true)
AudioRecorderRepository audioRecorderRepository(Ref ref) {
  final repository = AudioRecorderRepositoryImpl();
  LoggerService.info('AudioRecorderRepository instance created');
  return repository;
}

@riverpod
StartRecordingUseCase startRecordingUseCase(Ref ref) {
  return StartRecordingUseCase(ref.watch(audioRecorderRepositoryProvider));
}

@riverpod
StopRecordingUseCase stopRecordingUseCase(Ref ref) {
  return StopRecordingUseCase(ref.watch(audioRecorderRepositoryProvider));
}

@riverpod
ToggleRecordingUseCase toggleRecordingUseCase(Ref ref) {
  return ToggleRecordingUseCase(
    ref.watch(audioRecorderRepositoryProvider),
    ref.watch(startRecordingUseCaseProvider),
    ref.watch(stopRecordingUseCaseProvider),
  );
}

enum RecorderState {
  idle,
  recording,
  extractingAudio,
  analyzing,
  completed,
  error,
}

class RecorderStateData {
  final RecorderState state;
  final AudioRecording? recording;
  final String? errorMessage;

  const RecorderStateData({
    required this.state,
    this.recording,
    this.errorMessage,
  });

  RecorderStateData copyWith({
    RecorderState? state,
    AudioRecording? recording,
    String? errorMessage,
  }) {
    return RecorderStateData(
      state: state ?? this.state,
      recording: recording ?? this.recording,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class AudioRecorderNotifier extends _$AudioRecorderNotifier {
  @override
  RecorderStateData build() {
    return const RecorderStateData(state: RecorderState.idle);
  }

  Future<void> toggleRecording() async {
    try {
      final repository = ref.read(audioRecorderRepositoryProvider);
      final isCurrentlyRecording = await repository.isRecording();
      
      LoggerService.info('Toggle recording called - isCurrentlyRecording: $isCurrentlyRecording');
      
      if (isCurrentlyRecording) {
        LoggerService.info('Stopping recording...');
        final stopUseCase = ref.read(stopRecordingUseCaseProvider);
        final recording = await stopUseCase();
        LoggerService.info('Recording stopped: ${recording?.id}');
        
        if (recording != null) {
          // Set analyzing state
          state = state.copyWith(
            state: RecorderState.analyzing,
            recording: recording,
          );
          
          // Trigger analysis
          await _analyzeRecording(recording);
        } else {
          state = state.copyWith(state: RecorderState.error, errorMessage: 'Failed to stop recording');
        }
      } else {
        LoggerService.info('Starting recording...');
        final startUseCase = ref.read(startRecordingUseCaseProvider);
        final filePath = await startUseCase();
        
        if (filePath != null) {
          // Extract timestamp from filename to maintain consistent ID
          final fileName = filePath.split('/').last;
          final timestampMatch = RegExp(r'recording_(\d+)\.aac').firstMatch(fileName);
          final recordingId = timestampMatch?.group(1) ?? DateTime.now().millisecondsSinceEpoch.toString();
          final createdAt = timestampMatch != null 
              ? DateTime.fromMillisecondsSinceEpoch(int.parse(timestampMatch.group(1)!))
              : DateTime.now();
          
          final newRecording = AudioRecording(
            id: recordingId,
            filePath: filePath,
            createdAt: createdAt,
            duration: Duration.zero,
            fileSizeBytes: 0,
            isRecording: true,
          );
          state = state.copyWith(
            state: RecorderState.recording,
            recording: newRecording,
          );
          _listenToRecordingUpdates();
          LoggerService.info('Recording started successfully');
        } else {
          state = state.copyWith(state: RecorderState.error, errorMessage: 'Failed to start recording');
        }
      }
    } catch (e) {
      LoggerService.error('Error toggling recording: $e');
      state = state.copyWith(state: RecorderState.error, errorMessage: e.toString());
    }
  }

  Future<void> _analyzeRecording(AudioRecording recording) async {
    try {
      LoggerService.info('Starting analysis for recording: ${recording.id}');
      final analyzerNotifier = ref.read(audioAnalyzerNotifierProvider.notifier);
      final analysis = await analyzerNotifier.analyzeAudio(recording);
      
      LoggerService.info('Analysis completed with status: ${analysis.status}');
      
      // Check if analysis was successful based on the returned analysis
      if (analysis.status == AnalysisStatus.completed) {
        LoggerService.info('Analysis successful, updating state to completed');
        state = state.copyWith(state: RecorderState.completed);
        
        // Invalidate recordings to refresh the list
        ref.invalidate(recordingsNotifierProvider);
        
        _navigateToSummaryDetails(recording.id);
      } else {
        LoggerService.error('Analysis failed with status: ${analysis.status}');
        state = state.copyWith(
          state: RecorderState.error,
          errorMessage: 'Analysis failed with status: ${analysis.status}',
        );
      }
    } catch (e) {
      LoggerService.error('Error analyzing recording: $e');
      state = state.copyWith(
        state: RecorderState.error,
        errorMessage: 'Analysis failed: $e',
      );
    }
  }
  
  void _navigateToSummaryDetails(String recordingId) {
    // Schedule navigation for the next frame to ensure UI is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        AppRouter.router.push('/summaries/$recordingId');
        LoggerService.info('Navigated to summary details for recording: $recordingId');
      } catch (e) {
        LoggerService.error('Could not navigate to summary details: $e');
      }
    });
  }

  Future<void> stopRecording() async {
    try {
      final useCase = ref.read(stopRecordingUseCaseProvider);
      final recording = await useCase();
      
      if (recording != null) {
        state = state.copyWith(
          state: RecorderState.idle,
          recording: recording,
        );
      }
      LoggerService.info('Recording stopped: ${recording?.id}');
    } catch (e) {
      LoggerService.error('Failed to stop recording', e);
      state = state.copyWith(
        state: RecorderState.error,
        errorMessage: e.toString(),
      );
    }
  }

  void setAnalyzingState(AudioRecording recording) {
    state = state.copyWith(
      state: RecorderState.analyzing,
      recording: recording,
    );
  }

  void setCompletedState() {
    state = state.copyWith(
      state: RecorderState.completed,
    );
  }

  void setExtractingAudioState() {
    state = state.copyWith(
      state: RecorderState.extractingAudio,
    );
  }

  void setIdleState() {
    state = state.copyWith(
      state: RecorderState.idle,
      recording: null,
      errorMessage: null,
    );
  }

  bool isRecordOrAnalyzeOngoing() {
    return state.state == RecorderState.recording || 
           state.state == RecorderState.analyzing || 
           state.state == RecorderState.extractingAudio;
  }

  void _listenToRecordingUpdates() {
    final repository = ref.read(audioRecorderRepositoryProvider);
    
    repository.getRecordingDuration().listen((duration) {
      if (state.recording != null && state.recording!.isRecording) {
        state = state.copyWith(
          recording: state.recording!.copyWith(duration: duration),
        );
      }
    });
    
    repository.getRecordingFileSize().listen((fileSize) {
      if (state.recording != null && state.recording!.isRecording) {
        state = state.copyWith(
          recording: state.recording!.copyWith(fileSizeBytes: fileSize),
        );
      }
    });
  }
}

@riverpod
Stream<Duration> recordingDuration(Ref ref) {
  final repository = ref.watch(audioRecorderRepositoryProvider);
  return repository.getRecordingDuration();
}

@riverpod
Stream<int> recordingFileSize(Ref ref) {
  final repository = ref.watch(audioRecorderRepositoryProvider);
  return repository.getRecordingFileSize();
}