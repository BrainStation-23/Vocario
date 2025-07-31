import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/utils/context_extensions.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/import_audio.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/audio_recorder_provider.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/audio_analyzer_provider.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/core/routing/app_router.dart';
import 'package:flutter/scheduler.dart';

class BottomButtons extends ConsumerWidget {
  const BottomButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return OutlinedButton.icon(
      onPressed: () => _importAudio(context, ref),
      icon: const Icon(Icons.upload_file),
      label: Text(localizations.importAudio),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
    );
  }

  Future<void> _importAudio(BuildContext context, WidgetRef ref) async {
    final localizations = AppLocalizations.of(context)!;
    final recorderNotifier = ref.read(audioRecorderNotifierProvider.notifier);
    if (recorderNotifier.isRecordOrAnalyzeOngoing()) {
      return;
    }

    try {
      LoggerService.info('Starting audio import process');

      final importUseCase = ref.read(importAudioUseCaseProvider);
      final importation = await importUseCase();

      if (importation != null) {
        LoggerService.info('Audio imported successfully: ${importation.id}');
        recorderNotifier.setAnalyzingState(importation);

        final analyzerNotifier = ref.read(
          audioAnalyzerNotifierProvider.notifier,
        );
        final analysis = await analyzerNotifier.analyzeAudio(importation);

        LoggerService.info(
          'Analysis completed with status: ${analysis.status}',
        );

        // Navigate to summary if analysis was successful
        if (analysis.status == AnalysisStatus.completed) {
          LoggerService.info('Analysis successful, navigating to summary');
          SchedulerBinding.instance.addPostFrameCallback((_) {
            try {
              AppRouter.router.push('/summaries/${importation.id}');
              LoggerService.info(
                'Navigated to summary details for recording: ${importation.id}',
              );
            } catch (e) {
              LoggerService.error('Could not navigate to summary details: $e');
            }
          });
        } else {
          LoggerService.error(
            'Analysis failed with status: ${analysis.errorMessage}',
          );
          if (context.mounted) {
            context.showSnackBar(
              analysis.errorMessage ?? localizations.analysisFailed,
              isError: true,
            );
          }
        }
      } else {
        LoggerService.info('Audio import cancelled by user');
      }
    } catch (e) {
      LoggerService.error('Error importing audio: $e');
      if (context.mounted) {
        context.showSnackBar('${localizations.failedToImportAudio}: $e', isError: true);
      }
    } finally {
      recorderNotifier.setCompletedState();
    }
  }
}
