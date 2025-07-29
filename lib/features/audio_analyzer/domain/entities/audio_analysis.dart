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
  final String content;
  final AnalysisStatus status;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;

  const AudioAnalysis({
    required this.id,
    required this.recordingId,
    this.content = '',
    required this.status,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });

  AudioAnalysis copyWith({
    String? id,
    String? recordingId,
    String? content,
    AnalysisStatus? status,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return AudioAnalysis(
      id: id ?? this.id,
      recordingId: recordingId ?? this.recordingId,
      content: content ?? this.content,
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
        content,
        status,
        errorMessage,
        createdAt,
        completedAt,
      ];
}