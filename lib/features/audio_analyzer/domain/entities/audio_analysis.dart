import 'package:equatable/equatable.dart';

enum AnalysisStatus {
  pending,
  analyzing,
  completed,
  failed,
}

class AudioAnalysis extends Equatable {
  final String id;
  final String recordingId;
  final String? transcript;
  final String? summary;
  final List<String> keyPoints;
  final String? sentiment;
  final AnalysisStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  const AudioAnalysis({
    required this.id,
    required this.recordingId,
    this.transcript,
    this.summary,
    this.keyPoints = const [],
    this.sentiment,
    required this.status,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  AudioAnalysis copyWith({
    String? id,
    String? recordingId,
    String? transcript,
    String? summary,
    List<String>? keyPoints,
    String? sentiment,
    AnalysisStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return AudioAnalysis(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      transcript: transcript ?? this.transcript,
      summary: summary ?? this.summary,
      keyPoints: keyPoints ?? this.keyPoints,
      sentiment: sentiment ?? this.sentiment,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        recordingId,
        transcript,
        summary,
        keyPoints,
        sentiment,
        status,
        errorMessage,
        createdAt,
        completedAt,
      ];
}