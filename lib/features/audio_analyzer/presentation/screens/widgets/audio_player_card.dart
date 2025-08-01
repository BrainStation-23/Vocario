import 'package:flutter/material.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/features/audio_analyzer/presentation/screens/widgets/audio_player_widget.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';

class AudioPlayerCard extends StatelessWidget {
  final AudioRecording recording;

  const AudioPlayerCard({
    super.key,
    required this.recording,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.audioPlayer,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AudioPlayerWidget(
              filePath: recording.filePath,
              duration: recording.duration,
            ),
          ],
        ),
      ),
    );
  }
}