import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';

abstract class AudioRecorderRepository {
  Future<bool> hasPermission();
  Future<bool> requestPermission();
  Future<String> startRecording();
  Future<AudioRecording?> stopRecording();
  Future<bool> isRecording();
  Future<void> cancelRecording();
  Stream<Duration> getRecordingDuration();
  Stream<int> getRecordingFileSize();
  Future<List<AudioRecording>> getAllRecordings();
  Future<AudioRecording?> getRecordingById(String id);
  Future<void> deleteRecording(String id);
}