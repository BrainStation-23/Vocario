import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/core/services/logger_service.dart';

class ImportAudioUseCase {
  static const int maxFileSizeBytes = 20 * 1024 * 1024; // 20MB
  static const List<String> allowedExtensions = ['mp3', 'wav', 'aac', 'm4a', 'ogg', 'flac'];

  Future<AudioRecording?> call() async {
    try {
      LoggerService.info('Starting audio file import');
      
      // Open file picker for audio files
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        LoggerService.info('No file selected');
        return null;
      }

      final pickedFile = result.files.first;
      
      // Validate file size
      if (pickedFile.size > maxFileSizeBytes) {
        throw Exception('File size exceeds 20MB limit. Selected file: ${(pickedFile.size / (1024 * 1024)).toStringAsFixed(1)}MB');
      }

      // Validate file extension
      final extension = pickedFile.extension?.toLowerCase();
      if (extension == null || !allowedExtensions.contains(extension)) {
        throw Exception('Unsupported file format. Allowed formats: ${allowedExtensions.join(', ')}');
      }

      LoggerService.info('Selected file: ${pickedFile.name}, Size: ${(pickedFile.size / (1024 * 1024)).toStringAsFixed(2)}MB');

      // Copy file to internal storage
      final copiedFile = await _copyToInternalStorage(pickedFile);
      
      // Create AudioRecording entity
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final recording = AudioRecording(
        id: timestamp.toString(),
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
      final appDir = await getApplicationDocumentsDirectory();
      final recordingsDir = Directory('${appDir.path}/recordings');
      
      // Create recordings directory if it doesn't exist
      if (!await recordingsDir.exists()) {
        await recordingsDir.create(recursive: true);
      }

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = pickedFile.extension;
      final fileName = 'imported_${timestamp}.$extension';
      final destinationPath = '${recordingsDir.path}/$fileName';

      // Copy file to internal storage
      final sourceFile = File(pickedFile.path!);
      final destinationFile = await sourceFile.copy(destinationPath);
      
      LoggerService.info('File copied to internal storage: $destinationPath');
      return destinationFile;
    } catch (e) {
      LoggerService.error('Failed to copy file to internal storage', e);
      rethrow;
    }
  }
}