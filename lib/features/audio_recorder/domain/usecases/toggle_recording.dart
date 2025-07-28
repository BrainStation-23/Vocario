import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/features/audio_recorder/domain/repositories/audio_recorder_repository.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/start_recording.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/stop_recording.dart';

class ToggleRecordingUseCase {
  final AudioRecorderRepository repository;
  final StartRecordingUseCase startRecordingUseCase;
  final StopRecordingUseCase stopRecordingUseCase;

  ToggleRecordingUseCase(
    this.repository,
    this.startRecordingUseCase,
    this.stopRecordingUseCase,
  );

  Future<AudioRecording?> call() async {
    final isRecording = await repository.isRecording();
    
    if (isRecording) {
      return await stopRecordingUseCase();
    } else {
      final filePath = await startRecordingUseCase();
      if (filePath != null) {
        return AudioRecording(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          filePath: filePath,
          createdAt: DateTime.now(),
          duration: Duration.zero,
          fileSizeBytes: 0,
          isRecording: true,
        );
      }
    }
    return null;
  }
}