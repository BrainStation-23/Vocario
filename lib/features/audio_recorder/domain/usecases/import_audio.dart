import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocario/core/constants/app_constants.dart';
import 'package:vocario/core/utils/app_utils.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/core/services/logger_service.dart';

part 'import_audio.g.dart';

@riverpod
ImportAudioUseCase importAudioUseCase(Ref ref) {
  return ImportAudioUseCase();
}

class ImportAudioUseCase {
  Future<AudioRecording?> call() async {
    try {
      LoggerService.info('Starting audio file import');
      
      // Open file picker for audio files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: AppConstants.supportedAudioFormats,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        LoggerService.info('No file selected');
        return null;
      }

      final pickedFile = result.files.first;

      // Validate file extension
      final extension = pickedFile.extension?.toLowerCase();
      if (extension == null || !AppConstants.supportedAudioFormats.contains(extension)) {
        throw Exception('Unsupported file format. Allowed formats: ${AppConstants.supportedAudioFormats.join(', ')}');
      }

      LoggerService.info('Selected file: ${pickedFile.name}, Size: ${(pickedFile.size / (1024 * 1024)).toStringAsFixed(2)}MB');

      final copiedFile = await _copyToInternalStorage(pickedFile);
      
      final recordingId = AppUtils.filePathToID(copiedFile.path);
      final recording = AudioRecording(
        id: recordingId,
        filePath: copiedFile.path,
        duration: Duration.zero, // Will be updated during analysis if needed
        fileSizeBytes: pickedFile.size,
        createdAt: DateTime.now(),
        isRecording: false,
      );

      LoggerService.info('Audio file imported successfully: ${recording.id}');
      return recording;
    } catch (e) {
      LoggerService.error('Failed to import audio file', e);
      rethrow;
    }
  }

  Future<File> _copyToInternalStorage(PlatformFile pickedFile) async {
    try {
      final audioDir = await AppUtils.getAudioDirectory();

      final fileName = pickedFile.name;
      final destinationPath = '${audioDir.path}/$fileName';
      
      // Check if file already exists and add suffix if needed
      var finalDestinationPath = destinationPath;
      var counter = 1;
      while (await File(finalDestinationPath).exists()) {
        final nameWithoutExtension = fileName.replaceAll(RegExp(r'\.[^.]*$'), '');
        final extension = pickedFile.extension;
        final newFileName = '${nameWithoutExtension}_$counter.$extension';
        finalDestinationPath = '${audioDir.path}/$newFileName';
        counter++;
      }

      // Copy file to internal storage
      final sourceFile = File(pickedFile.path!);
      final destinationFile = await sourceFile.copy(finalDestinationPath);
      
      LoggerService.info('File copied to internal storage: $finalDestinationPath');
      return destinationFile;
    } catch (e) {
      LoggerService.error('Failed to copy file to internal storage', e);
      rethrow;
    }
  }
}