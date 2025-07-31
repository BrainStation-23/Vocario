import 'package:flutter/material.dart';
import 'package:vocario/core/utils/format_utils.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';

class RecordingInfoCard extends StatelessWidget {
  final AudioRecording recording;

  const RecordingInfoCard({
    super.key,
    required this.recording,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mic,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recording Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'File Name',
              value: FormatUtils.getFileName(recording.filePath),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Duration',
              value: FormatUtils.formatDuration(recording.duration),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'File Size',
              value: FormatUtils.formatFileSize(recording.fileSizeBytes),
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Created',
              value: FormatUtils.formatDate(recording.createdAt),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}