import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';

class AudioAnalysisModel extends AudioAnalysis {
  const AudioAnalysisModel({
    required super.id,
    required super.recordingId,
    super.transcript,
    super.summary,
    super.keyPoints = const [],
    super.sentiment,
    required super.status,
    super.errorMessage,
    required super.createdAt,
    super.completedAt,
  });

  factory AudioAnalysisModel.fromJson(Map<String, dynamic> json) {
    return AudioAnalysisModel(
      id: json['id'] as String,
      recordingId: json['recordingId'] as String,
      transcript: json['transcript'] as String?,
      summary: json['summary'] as String?,
      keyPoints: (json['keyPoints'] as List<dynamic>?)?.cast<String>() ?? [],
      sentiment: json['sentiment'] as String?,
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
      'transcript': transcript,
      'summary': summary,
      'keyPoints': keyPoints,
      'sentiment': sentiment,
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
      transcript: analysis.transcript,
      summary: analysis.summary,
      keyPoints: analysis.keyPoints,
      sentiment: analysis.sentiment,
      status: analysis.status,
      errorMessage: analysis.errorMessage,
      createdAt: analysis.createdAt,
      completedAt: analysis.completedAt,
    );
  }
}