import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/audio_recorder_provider.dart';

part 'recordings_provider.g.dart';

@riverpod
Future<List<AudioRecording>> allRecordings(Ref ref) async {
  final repository = ref.watch(audioRecorderRepositoryProvider);
  return await repository.getAllRecordings();
}

@riverpod
Future<AudioRecording?> recordingById(Ref ref, String id) async {
  final repository = ref.watch(audioRecorderRepositoryProvider);
  return await repository.getRecordingById(id);
}

@riverpod
class ReanalysisNotifier extends _$ReanalysisNotifier {
  @override
  bool build() => false;

  void setReanalyzing(bool value) {
    state = value;
  }
}