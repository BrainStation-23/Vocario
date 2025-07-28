import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_analyzer/domain/repositories/audio_analyzer_repository.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';

class AnalyzeAudio {
  final AudioAnalyzerRepository repository;

  const AnalyzeAudio(this.repository);

  Future<AudioAnalysis> call(AudioRecording recording) async {
    return await repository.analyzeAudio(recording);
  }
}