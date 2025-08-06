import 'dart:async';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:vocario/core/utils/app_utils.dart';
import 'package:vocario/features/audio_recorder/data/models/audio_recording_model.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/features/audio_recorder/domain/repositories/audio_recorder_repository.dart';
import 'package:vocario/core/services/logger_service.dart';

class AudioRecorderRepositoryImpl implements AudioRecorderRepository {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  Timer? _durationTimer;
  Timer? _fileSizeTimer;
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();
  final StreamController<int> _fileSizeController = StreamController<int>.broadcast();
  Duration _currentDuration = Duration.zero;
  String? _currentFilePath;
  bool _isInitialized = false;
  bool _isRecording = false;

  @override
  Future<bool> hasPermission() async {
    try {
      final status = await Permission.microphone.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      LoggerService.error('Failed to check microphone permission', e);
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final status = await Permission.microphone.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      LoggerService.error('Failed to request microphone permission', e);
      return false;
    }
  }

  @override
  Future<String> startRecording() async {
    try {
      if (!_isInitialized) {
        await _recorder.openRecorder();
        _isInitialized = true;
      }
      
      final audioDir = await AppUtils.getAudioDirectory();
      final timestamp = DateTime.now();
      final fileName = 'recording_${timestamp.year}${timestamp.month.toString().padLeft(2, '0')}${timestamp.day.toString().padLeft(2, '0')}_${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}.aac';
      final filePath = '${audioDir.path}/$fileName';
      
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );
      
      _isRecording = true;
      _currentFilePath = filePath;
      _startTimers();
      
      LoggerService.info('Recording started: $filePath');
      return filePath;
    } catch (e) {
      LoggerService.error('Failed to start recording', e);
      rethrow;
    }
  }

  @override
  Future<AudioRecording?> stopRecording() async {
    try {
      await _recorder.stopRecorder();
      _isRecording = false;
      _stopTimers();
      
      if (_currentFilePath != null) {
        final file = File(_currentFilePath!);
        final fileSize = await file.length();
        
        final recordingId = AppUtils.filePathToID(_currentFilePath ?? '');
        final createdAt = DateTime.now();
        
        final recording = AudioRecordingModel(
          id: recordingId,
          filePath: _currentFilePath!,
          createdAt: createdAt,
          duration: _currentDuration,
          fileSizeBytes: fileSize,
          isRecording: false,
        );
        
        // Recording file is automatically saved to disk by flutter_sound
        
        _currentDuration = Duration.zero;
        final stoppedFilePath = _currentFilePath;
        _currentFilePath = null;
        
        LoggerService.info('Recording stopped: $stoppedFilePath');
        return recording;
      }
      return null;
    } catch (e) {
      LoggerService.error('Failed to stop recording', e);
      return null;
    }
  }

  @override
  Future<bool> isRecording() async {
    try {
      return _isRecording && _recorder.isRecording;
    } catch (e) {
      LoggerService.error('Failed to check recording status', e);
      return false;
    }
  }

  @override
  Future<void> cancelRecording() async {
    try {
      await _recorder.stopRecorder();
      _isRecording = false;
      _stopTimers();
      
      if (_currentFilePath != null) {
        final file = File(_currentFilePath!);
        if (await file.exists()) {
          await file.delete();
          LoggerService.info('Recording file deleted: $_currentFilePath');
        }
      }
      
      _currentDuration = Duration.zero;
      _currentFilePath = null;
      LoggerService.info('Recording cancelled');
    } catch (e) {
      LoggerService.error('Failed to cancel recording', e);
    }
  }

  @override
  Stream<Duration> getRecordingDuration() {
    return _durationController.stream;
  }

  @override
  Stream<int> getRecordingFileSize() {
    return _fileSizeController.stream;
  }

  void _startTimers() {
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _currentDuration = Duration(seconds: timer.tick);
      _durationController.add(_currentDuration);
    });

    _fileSizeTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_currentFilePath != null) {
        try {
          final file = File(_currentFilePath!);
          if (await file.exists()) {
            final fileSize = await file.length();
            _fileSizeController.add(fileSize);
          }
        } catch (e) {
          LoggerService.error('Failed to check file size', e);
        }
      }
    });
  }

  void _stopTimers() {
    _durationTimer?.cancel();
    _fileSizeTimer?.cancel();
    _durationTimer = null;
    _fileSizeTimer = null;
  }

  @override
  Future<List<AudioRecording>> getAllRecordings() async {
    try {
      final audioDir = await AppUtils.getAudioDirectory();

      
      final recordingFiles = audioDir
          .listSync()
          .whereType<File>()
          .toList();
      
      final recordings = <AudioRecording>[];
      
      for (final file in recordingFiles) {
        try {
          final id = AppUtils.filePathToID(file.path);
          final fileStat = await file.stat();
          final fileSize = fileStat.size;
          final createdAt = fileStat.modified;
          
          // For AAC files, rough estimation: ~128kbps = 16KB/s
          final estimatedDurationSeconds = (fileSize / 16000).round();
          final duration = Duration(seconds: estimatedDurationSeconds);
          
          final recording = AudioRecordingModel(
            id: id,
            filePath: file.path,
            createdAt: createdAt,
            duration: duration,
            fileSizeBytes: fileSize,
            isRecording: false,
          );
          
          recordings.add(recording);
        } catch (e) {
          LoggerService.error('Failed to process recording file: ${file.path}', e);
        }
      }
      
      // Sort by creation date (newest first)
      recordings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return recordings;
    } catch (e) {
      LoggerService.error('Failed to get all recordings from disk', e);
      return [];
    }
  }

  @override
  Future<AudioRecording?> getRecordingById(String id) async {
    try {
      final audioDir = await AppUtils.getAudioDirectory();
      final files = audioDir.listSync().whereType<File>();
      
      for (final file in files) {
        final fileId = AppUtils.filePathToID(file.path);
        
        if (fileId == id) {
          final fileStat = await file.stat();
          final fileSize = fileStat.size;
          final createdAt = fileStat.modified;
          
          // Estimate duration based on file size
          // For AAC files, rough estimation: ~128kbps = 16KB/s
          final estimatedDurationSeconds = (fileSize / 16000).round();
          final duration = Duration(seconds: estimatedDurationSeconds);
          
          return AudioRecordingModel(
            id: id,
            filePath: file.path,
            createdAt: createdAt,
            duration: duration,
            fileSizeBytes: fileSize,
            isRecording: false,
          );
        }
      }
      
      LoggerService.info('Recording file not found for id: $id');
      return null;
    } catch (e) {
      LoggerService.error('Failed to get recording by id: $id', e);
      return null;
    }
  }



  @override
  Future<void> deleteRecording(String id) async {
    try {
      final audioDir = await AppUtils.getAudioDirectory();
      final files = audioDir.listSync().whereType<File>();
      
      for (final file in files) {
        final fileId = AppUtils.filePathToID(file.path);
        
        if (fileId == id) {
          await file.delete();
          LoggerService.info('Recording file deleted: ${file.path}');
          return;
        }
      }
      
      LoggerService.warning('Recording file not found for deletion with id: $id');
    } catch (e) {
      LoggerService.error('Failed to delete recording: $id', e);
      rethrow;
    }
  }

  void dispose() {
    _stopTimers();
    _durationController.close();
    _fileSizeController.close();
    if (_isInitialized) {
      _recorder.closeRecorder();
    }
  }
}