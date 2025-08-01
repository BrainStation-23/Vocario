import 'package:flutter/material.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/core/utils/format_utils.dart';

class RecordingListItem extends StatelessWidget {
  final AudioRecording recording;
  final VoidCallback onTap;

  const RecordingListItem({
    super.key,
    required this.recording,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            Icons.audiotrack,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        title: Text(
          FormatUtils.getFileName(recording.filePath),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${localizations.duration}: ${FormatUtils.formatDuration(recording.duration)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${localizations.created}: ${FormatUtils.formatDate(recording.createdAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }


}