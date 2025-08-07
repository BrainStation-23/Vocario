import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:vocario/core/utils/context_extensions.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/audio_analyzer_provider.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/recordings_provider.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/audio_recorder_provider.dart';

class DeleteConfirmationDialog extends ConsumerWidget {
  final AudioRecording recording;
  final AsyncValue<AudioAnalysis?> analysisAsync;
  final String recordingId;

  const DeleteConfirmationDialog({
    super.key,
    required this.recording,
    required this.analysisAsync,
    required this.recordingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(localizations.deleteRecording),
      content: Text(
        localizations.deleteConfirmationMessage,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            await _deleteRecordingAndAnalysis(context, ref);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
          child: Text(localizations.delete),
        ),
      ],
    );
  }

  Future<void> _deleteRecordingAndAnalysis(BuildContext context, WidgetRef ref) async {
    try {
      final analysis = analysisAsync.value;
      if (analysis != null) {
        await ref.read(audioAnalyzerRepositoryProvider).deleteAnalysis(analysis.id);
      }
      
      await ref.read(audioRecorderRepositoryProvider).deleteRecording(recording.id);
      
      ref.invalidate(recordingByIdProvider(recordingId));
      ref.invalidate(audioAnalysisByRecordingIdProvider(recordingId));
      ref.invalidate(recordingsNotifierProvider);
      
      if (context.mounted) {
        final localizations = AppLocalizations.of(context)!;
        context.showSnackBar(localizations.recordingDeletedSuccessfully);
        context.pop();
      }
    } catch (e) {
      LoggerService.error('Failed to delete recording and analysis', e);
      if (context.mounted) {
        final localizations = AppLocalizations.of(context)!;
        context.showSnackBar(localizations.failedToDelete(e.toString()), isError: true);
      }
    }
  }
}