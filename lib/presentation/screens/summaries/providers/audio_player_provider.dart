import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'audio_player_provider.g.dart';

class AudioPlayerState {
  final bool isPlaying;
  final bool isInitialized;
  final Duration currentPosition;
  final bool isLoading;
  final FlutterSoundPlayer? player;

  const AudioPlayerState({
    this.isPlaying = false,
    this.isInitialized = false,
    this.currentPosition = Duration.zero,
    this.isLoading = false,
    this.player,
  });

  AudioPlayerState copyWith({
    bool? isPlaying,
    bool? isInitialized,
    Duration? currentPosition,
    bool? isLoading,
    FlutterSoundPlayer? player,
  }) {
    return AudioPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isInitialized: isInitialized ?? this.isInitialized,
      currentPosition: currentPosition ?? this.currentPosition,
      isLoading: isLoading ?? this.isLoading,
      player: player ?? this.player,
    );
  }
}

@riverpod
class AudioPlayerNotifier extends _$AudioPlayerNotifier {
  StreamSubscription<PlaybackDisposition>? _positionSubscription;

  @override
  AudioPlayerState build() {
    ref.onDispose(() {
      _disposePlayer();
    });
    return const AudioPlayerState();
  }

  Future<void> initializePlayer() async {
    try {
      final player = FlutterSoundPlayer();
      await player.openPlayer();
      state = state.copyWith(
        player: player,
        isInitialized: true,
      );
    } catch (e) {
      debugPrint('Error initializing player: $e');
    }
  }

  Future<void> _disposePlayer() async {
    try {
      await _positionSubscription?.cancel();
      _positionSubscription = null;
      
      if (state.player != null) {
        await state.player!.stopPlayer();
        await state.player!.closePlayer();
      }
    } catch (e) {
      debugPrint('Error disposing player: $e');
    }
  }

  Future<void> togglePlayback(String filePath) async {
    if (!state.isInitialized || state.player == null) return;

    try {
      state = state.copyWith(isLoading: true);

      if (state.isPlaying) {
        await state.player!.stopPlayer();
        await _positionSubscription?.cancel();
        _positionSubscription = null;
        
        state = state.copyWith(
          isPlaying: false,
          currentPosition: Duration.zero,
        );
      } else {
        await state.player!.startPlayer(
          fromURI: filePath,
          whenFinished: () {
            state = state.copyWith(
              isPlaying: false,
              currentPosition: Duration.zero,
            );
          },
        );
        
        state = state.copyWith(isPlaying: true);
        _startPositionTracking();
      }
    } catch (e) {
      debugPrint('Error toggling playback: $e');
      state = state.copyWith(isPlaying: false);
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void _startPositionTracking() {
    if (state.player != null && state.isPlaying) {
      _positionSubscription = state.player!.onProgress!.listen((event) {
        if (state.isPlaying) {
          state = state.copyWith(currentPosition: event.position);
        }
      });
    }
  }

  Future<void> seekTo(double value) async {
    if (!state.isInitialized || state.player == null) return;

    final newPosition = Duration(milliseconds: value.toInt());
    
    try {
      if (state.isPlaying) {
        await state.player!.seekToPlayer(newPosition);
      }
      state = state.copyWith(currentPosition: newPosition);
    } catch (e) {
      debugPrint('Error seeking: $e');
    }
  }
}