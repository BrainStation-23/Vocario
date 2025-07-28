import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';

abstract class AudioAnalyzerRepository {
  Future<AudioAnalysis> analyzeAudio(AudioRecording recording);
  Future<List<AudioAnalysis>> getAllAnalyses();
  Future<AudioAnalysis?> getAnalysisById(String analysisId);
  Future<AudioAnalysis?> getAnalysisByRecordingId(String recordingId);
  Future<void> deleteAnalysis(String analysisId);
}