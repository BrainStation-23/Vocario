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
        Row(
          children: [
            Container(
              width: 60,
              height: 60,
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
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: audioPlayerState.isLoading 
                      ? null 
                      : () => audioPlayerNotifier.togglePlayback(filePath),
                  child: Center(
                    child: audioPlayerState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            audioPlayerState.isPlaying ? Icons.stop : Icons.play_arrow,
                            size: 28,
                            color: Colors.white,
                          ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Soundwave widget
            Expanded(
              child: SoundwaveWidget(
                isPlaying: audioPlayerState.isPlaying,
                currentPosition: audioPlayerState.currentPosition,
                totalDuration: duration,
                activeColor: appColors?.gradientStart ?? Theme.of(context).colorScheme.primary,
                inactiveColor: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
                height: 60,
                barCount: 40,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Time display
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Duration: ${FormatUtils.formatDuration(duration)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}