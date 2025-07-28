import 'package:vocario/features/audio_recorder/domain/repositories/audio_recorder_repository.dart';

class StartRecordingUseCase {
  final AudioRecorderRepository repository;

  StartRecordingUseCase(this.repository);

  Future<String?> call() async {
    final hasPermission = await repository.hasPermission();
    if (!hasPermission) {
      final granted = await repository.requestPermission();
      if (!granted) {
        return null;
      }
    }

    return await repository.startRecording();
  }
}