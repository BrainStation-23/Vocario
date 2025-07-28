import 'package:equatable/equatable.dart';

class AudioRecording extends Equatable {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final Duration duration;
  final int fileSizeBytes;
  final bool isRecording;

  const AudioRecording({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.duration,
    required this.fileSizeBytes,
    required this.isRecording,
  });

  AudioRecording copyWith({
    String? id,
    String? filePath,
    DateTime? createdAt,
    Duration? duration,
    int? fileSizeBytes,
    bool? isRecording,
  }) {
    return AudioRecording(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      isRecording: isRecording ?? this.isRecording,
    );
  }

  @override
  List<Object?> get props => [
        id,
        filePath,
        createdAt,
        duration,
        fileSizeBytes,
        isRecording,
      ];
}