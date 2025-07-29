import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';

class AudioAnalysisModel extends AudioAnalysis {
  const AudioAnalysisModel({
    required super.id,
    required super.recordingId,
    super.content = '',
    required super.status,
    super.errorMessage,
    required super.createdAt,
    super.completedAt,
  });

  factory AudioAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AudioAnalysisModel(
      id: json['id'] as String,
      recordingId: json['recordingId'] as String,
      content: json['content'] as String? ?? '',
      status: AnalysisStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => AnalysisStatus.pending,
      ),
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordingId': recordingId,
      'content': content,
      'status': status.name,
      'errorMessage': errorMessage,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory AudioAnalysisModel.fromEntity(AudioAnalysis analysis) {
    return AudioAnalysisModel(
      id: analysis.id,
      recordingId: analysis.recordingId,
      content: analysis.content,
      status: analysis.status,
      errorMessage: analysis.errorMessage,
      createdAt: analysis.createdAt,
      completedAt: analysis.completedAt,
    );
  }
}