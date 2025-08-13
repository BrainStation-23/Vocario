import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocario/core/constants/app_constants.dart';
import 'package:vocario/core/utils/app_utils.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';
import 'package:path/path.dart' as path;
import 'package:vocario/features/audio_recorder/presentation/providers/audio_recorder_provider.dart';

part 'import_video.g.dart';

@riverpod
ImportVideoUseCase importVideoUseCase(Ref ref) {
  return ImportVideoUseCase(ref);
}

class ImportVideoUseCase {
  final Ref ref;

  ImportVideoUseCase(this.ref);

  Future<AudioRecording?> call() async {
    try {
      LoggerService.info('Starting video file import');
      
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedVideoFormats,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        LoggerService.info('No video file selected');
        return null;
      }

      final pickedFile = result.files.first;
      LoggerService.info('Video file selected: ${pickedFile.name}');

      if (!AppUtils.isVideoFormatSupported(pickedFile.name)) {
        LoggerService.warning('Unsupported video format: ${pickedFile.name}');
        throw Exception('Unsupported video format. Supported formats: ${AppConstants.supportedVideoFormats.join(", ")}');
      }

      // Get video file path
      final videoFilePath = pickedFile.path;
      if (videoFilePath == null) {
        throw Exception('Unable to access video file path');
      }

      ref.read(audioRecorderNotifierProvider.notifier).setExtractingAudioState();
      final audioFile = await _extractAudioFromVideo(videoFilePath, pickedFile.name);
      ref.read(audioRecorderNotifierProvider.notifier).setIdleState();
      
      final recording = AudioRecording(
        id: AppUtils.filePathToID(audioFile.path),
        filePath: audioFile.path,
        duration: Duration.zero, // Duration will be determined during analysis
        fileSizeBytes: await audioFile.length(),
        isRecording: false,
        createdAt: DateTime.now(),
      );

      LoggerService.info('Video import and audio extraction completed: ${recording.id}');
      return recording;
      
    } catch (e, stackTrace) {
      ref.read(audioRecorderNotifierProvider.notifier).setIdleState();
      LoggerService.error('Error importing video file', e, stackTrace);
      rethrow;
    }
  }

  Future<File> _extractAudioFromVideo(String videoFilePath, String originalFileName) async {
    try {
      final audioDir = await AppUtils.getAudioDirectory();
      
      final nameWithoutExtension = path.basenameWithoutExtension(originalFileName);
      final audioFileName = '$nameWithoutExtension.aac';
      
      // Check if file already exists and add suffix if needed
      var finalAudioPath = '${audioDir.path}/$audioFileName';
      var counter = 1;
      while (await File(finalAudioPath).exists()) {
        final newAudioFileName = '${nameWithoutExtension}_$counter.aac';
        finalAudioPath = '${audioDir.path}/$newAudioFileName';
        counter++;
      }

      LoggerService.info('Extracting audio from video: $videoFilePath to $finalAudioPath');
      
      // FFmpeg command to extract audio in AAC format
      final command = '-i "$videoFilePath" -vn -acodec aac -ab 128k "$finalAudioPath"';
      
      final session = await FFmpegKit.execute(command);
      final returnCode = await session.getReturnCode();
      
      if (ReturnCode.isSuccess(returnCode)) {
        LoggerService.info('Audio extraction successful: $finalAudioPath');
        final audioFile = File(finalAudioPath);
        
        // Verify the audio file was created and has content
        if (await audioFile.exists() && await audioFile.length() > 0) {
          return audioFile;
        } else {
          throw Exception('Audio extraction failed: Output file is empty or does not exist');
        }
      } else {
        final logs = await session.getAllLogsAsString();
        LoggerService.error('FFmpeg audio extraction failed with return code: $returnCode');
        LoggerService.error('FFmpeg logs: $logs');
        throw Exception('Failed to extract audio from video. Return code: $returnCode');
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error extracting audio from video', e, stackTrace);
      rethrow;
    }
  }
}