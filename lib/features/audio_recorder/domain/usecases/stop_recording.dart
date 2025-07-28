import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/features/audio_recorder/domain/repositories/audio_recorder_repository.dart';

class StopRecordingUseCase {
  final AudioRecorderRepository repository;

  StopRecordingUseCase(this.repository);

  Future<AudioRecording?> call() async {
    return await repository.stopRecording();
  }
}