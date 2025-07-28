import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocario/features/audio_recorder/data/repositories/audio_recorder_repository_impl.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/features/audio_recorder/domain/repositories/audio_recorder_repository.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/start_recording.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/stop_recording.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/toggle_recording.dart';
import 'package:vocario/core/services/logger_service.dart';

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

@riverpod
class AudioRecorderNotifier extends _$AudioRecorderNotifier {
  @override
  AudioRecording? build() {
    return null;
  }

  Future<void> toggleRecording() async {
    try {
      final repository = ref.read(audioRecorderRepositoryProvider);
      final isCurrentlyRecording = await repository.isRecording();
      
      LoggerService.info('Toggle recording called - isCurrentlyRecording: $isCurrentlyRecording');
      
      if (isCurrentlyRecording) {
        // Stop recording
        LoggerService.info('Stopping recording...');
        final stopUseCase = ref.read(stopRecordingUseCaseProvider);
        final result = await stopUseCase();
        if (result != null) {
          state = result;
          LoggerService.info('Recording stopped successfully');
        }
      } else {
        // Start recording
        LoggerService.info('Starting recording...');
        final startUseCase = ref.read(startRecordingUseCaseProvider);
        final filePath = await startUseCase();
        if (filePath != null) {
          final newRecording = AudioRecording(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            filePath: filePath,
            createdAt: DateTime.now(),
            duration: Duration.zero,
            fileSizeBytes: 0,
            isRecording: true,
          );
          state = newRecording;
          _listenToRecordingUpdates();
          LoggerService.info('Recording started successfully');
        }
      }
    } catch (e) {
      LoggerService.error('Failed to toggle recording', e);
    }
  }

  Future<void> stopRecording() async {
    try {
      final useCase = ref.read(stopRecordingUseCaseProvider);
      final result = await useCase();
      
      if (result != null) {
        state = result;
      }
    } catch (e) {
      LoggerService.error('Failed to stop recording', e);
    }
  }

  void _listenToRecordingUpdates() {
    final repository = ref.read(audioRecorderRepositoryProvider);
    
    repository.getRecordingDuration().listen((duration) {
      if (state != null && state!.isRecording) {
        state = state!.copyWith(duration: duration);
      }
    });
    
    repository.getRecordingFileSize().listen((fileSize) {
      if (state != null && state!.isRecording) {
        state = state!.copyWith(fileSizeBytes: fileSize);
        
        // Auto-stop if file size reaches 20MB
        const maxSizeBytes = 20 * 1024 * 1024; // 20MB
        if (fileSize >= maxSizeBytes) {
          LoggerService.info('File size limit reached (20MB), stopping recording automatically');
          stopRecording();
        }
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