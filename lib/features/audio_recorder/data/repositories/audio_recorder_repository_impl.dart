import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
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
  static const int maxFileSizeBytes = 20 * 1024 * 1024; // 20MB
  bool _isInitialized = false;

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
      
      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'recording_${DateTime.now().millisecondsSinceEpoch}.aac';
      final filePath = '${directory.path}/$fileName';
      
      await _recorder.startRecorder(
        toFile: filePath,
        codec: Codec.aacADTS,
        bitRate: 128000,
        sampleRate: 44100,
      );
      
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
      _stopTimers();
      
      if (_currentFilePath != null) {
        final file = File(_currentFilePath!);
        final fileSize = await file.length();
        
        final recording = AudioRecordingModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          filePath: _currentFilePath!,
          createdAt: DateTime.now(),
          duration: _currentDuration,
          fileSizeBytes: fileSize,
          isRecording: false,
        );
        
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
      return _recorder.isRecording;
    } catch (e) {
      LoggerService.error('Failed to check recording status', e);
      return false;
    }
  }

  @override
  Future<void> cancelRecording() async {
    try {
      await _recorder.stopRecorder();
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
            
            if (fileSize >= maxFileSizeBytes) {
              LoggerService.info('Max file size reached, stopping recording');
              await stopRecording();
            }
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

  void dispose() {
    _stopTimers();
    _durationController.close();
    _fileSizeController.close();
    if (_isInitialized) {
      _recorder.closeRecorder();
    }
  }
}