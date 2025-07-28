import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/core/utils/format_utils.dart';
import 'package:vocario/presentation/screens/summaries/providers/audio_player_provider.dart';
import 'package:vocario/presentation/screens/summaries/widgets/soundwave_widget.dart';

class AudioPlayerWidget extends ConsumerWidget {
  final String filePath;
  final Duration duration;

  const AudioPlayerWidget({
    super.key,
    required this.filePath,
    required this.duration,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioPlayerNotifier = ref.read(audioPlayerNotifierProvider.notifier);
    final audioPlayerState = ref.watch(audioPlayerNotifierProvider);
    
    // Initialize player on first build
    ref.listen(audioPlayerNotifierProvider, (previous, next) {
      if (previous?.isInitialized == false && next.isInitialized == false) {
        audioPlayerNotifier.initializePlayer();
      }
    });
    
    // Auto-initialize if not initialized
    if (!audioPlayerState.isInitialized && audioPlayerState.player == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        audioPlayerNotifier.initializePlayer();
      });
    }
    final appColors = Theme.of(context).extension<AppColors>();
    
    if (!audioPlayerState.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            SoundwaveWidget(
              isPlaying: audioPlayerState.isPlaying,
              currentPosition: audioPlayerState.currentPosition,
              totalDuration: duration,
              activeColor: appColors?.gradientStart ?? Theme.of(context).colorScheme.primary,
              inactiveColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
              height: 60,
              barCount: 40,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    FormatUtils.formatDuration(audioPlayerState.currentPosition),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    FormatUtils.formatDuration(duration),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Play/Stop button
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                appColors?.gradientStart ?? Theme.of(context).colorScheme.primary,
                appColors?.gradientEnd ?? Theme.of(context).colorScheme.primary,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: (appColors?.gradientStart ?? Theme.of(context).colorScheme.primary)
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(40),
              onTap: audioPlayerState.isLoading 
                  ? null 
                  : () => audioPlayerNotifier.togglePlayback(filePath),
              child: Center(
                child: audioPlayerState.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        audioPlayerState.isPlaying ? Icons.stop : Icons.play_arrow,
                        size: 36,
                        color: Colors.white,
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          audioPlayerState.isPlaying ? 'Playing...' : 'Tap to play',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}