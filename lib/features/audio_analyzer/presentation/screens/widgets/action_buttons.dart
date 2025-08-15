import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/utils/app_utils.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/recordings_provider.dart';
import 'package:vocario/features/audio_analyzer/presentation/screens/widgets/delete_confirmation_dialog.dart';
import 'package:vocario/features/audio_analyzer/presentation/screens/widgets/share_options_dialog.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';

class ActionButtons extends ConsumerWidget {
  final AudioRecording recording;
  final AsyncValue<AudioAnalysis?> analysisAsync;
  final VoidCallback onReanalyze;
  final String recordingId;

  const ActionButtons({
    super.key,
    required this.recording,
    required this.analysisAsync,
    required this.onReanalyze,
    required this.recordingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    
    return Row(
      children: [
        SizedBox(
          width: 160,
          child: OutlinedButton.icon(
            onPressed: ref.watch(reanalysisNotifierProvider) ? null : onReanalyze,
            icon: const Icon(Icons.refresh),
            label: Text(localizations.reanalyze),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => AppUtils.copyAnalysisText(analysisAsync, context),
          icon: const Icon(Icons.copy_all),
          tooltip: localizations.copy,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => _showShareOptions(context, recording, analysisAsync),
          icon: const Icon(Icons.share),
          tooltip: localizations.share,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => _showDeleteConfirmation(context, recording, analysisAsync),
          icon: const Icon(Icons.delete),
          tooltip: localizations.delete,
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
        ),
      ],
    );
  }

  void _showShareOptions(BuildContext context, AudioRecording recording, AsyncValue<AudioAnalysis?> analysisAsync) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ShareOptionsDialog(
          recording: recording,
          analysisAsync: analysisAsync,
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, AudioRecording recording, AsyncValue<AudioAnalysis?> analysisAsync) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DeleteConfirmationDialog(
          recording: recording,
          analysisAsync: analysisAsync,
          recordingId: recordingId,
        );
      },
    );
  }
}