import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';

class AudioRecordingModel extends AudioRecording {
  const AudioRecordingModel({
    required super.id,
    required super.filePath,
    required super.createdAt,
    required super.duration,
    required super.fileSizeBytes,
    required super.isRecording,
  });

  factory AudioRecordingModel.fromEntity(AudioRecording entity) {
    return AudioRecordingModel(
      id: entity.id,
      filePath: entity.filePath,
      createdAt: entity.createdAt,
      duration: entity.duration,
      fileSizeBytes: entity.fileSizeBytes,
      isRecording: entity.isRecording,
    );
  }

  factory AudioRecordingModel.fromJson(Map<String, dynamic> json) {
    return AudioRecordingModel(
      id: json['id'],
      filePath: json['filePath'],
      createdAt: DateTime.parse(json['createdAt']),
      duration: Duration(milliseconds: json['duration']),
      fileSizeBytes: json['fileSizeBytes'],
      isRecording: json['isRecording'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'filePath': filePath,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration.inMilliseconds,
      'fileSizeBytes': fileSizeBytes,
      'isRecording': isRecording,
    };
  }

  @override
  AudioRecordingModel copyWith({
    String? id,
    String? filePath,
    DateTime? createdAt,
    Duration? duration,
    int? fileSizeBytes,
    bool? isRecording,
  }) {
    return AudioRecordingModel(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      createdAt: createdAt ?? this.createdAt,
      duration: duration ?? this.duration,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      isRecording: isRecording ?? this.isRecording,
    );
  }
}