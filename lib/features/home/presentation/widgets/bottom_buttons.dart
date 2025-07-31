import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/utils/context_extensions.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/import_audio.dart';
import 'package:vocario/features/audio_recorder/domain/usecases/import_video.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/audio_recorder_provider.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/recording_flow_provider.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/audio_analyzer_provider.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/core/routing/app_router.dart';
import 'package:flutter/scheduler.dart';
import 'package:vocario/features/audio_recorder/presentation/widgets/api_key_dialog.dart';
import 'package:vocario/features/audio_recorder/presentation/widgets/usage_context_selection_dialog.dart';

class BottomButtons extends ConsumerWidget {
  const BottomButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _importMedia(context, ref, true),
            icon: const Icon(Icons.upload_file),
            label: Text(localizations.importAudio),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _importMedia(context, ref, false),
            icon: const Icon(Icons.video_file),
            label: Text(localizations.importVideo),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
        ),
      ],
    );
  }

  Future<void> _importMedia(
    BuildContext context,
    WidgetRef ref,
    bool isAudio,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    final recorderNotifier = ref.read(audioRecorderNotifierProvider.notifier);
    if (recorderNotifier.isRecordOrAnalyzeOngoing()) {
      return;
    }

    if (!await _prerequisitesMet(context, ref)) {
      return;
    }

    try {
      LoggerService.info('Starting import process');

      final importation = isAudio
          ? await ref.read(importAudioUseCaseProvider).call()
          : await ref.read(importVideoUseCaseProvider).call();

      if (importation != null && context.mounted) {
        await _analyzeAudio(context, ref, importation);
      } else {
        LoggerService.info('Import cancelled by user');
      }
    } catch (e) {
      LoggerService.error('Error importing media: $e');
      if (context.mounted) {
        context.showSnackBar(
          '${localizations.failedToImportMedia}: $e',
          isError: true,
        );
      }
    } finally {
      recorderNotifier.setCompletedState();
    }
  }

  Future<void> _analyzeAudio(
    BuildContext context,
    WidgetRef ref,
    AudioRecording? recording,
  ) async {
    if (recording == null) {
      return;
    }

    final localizations = AppLocalizations.of(context)!;
    final recorderNotifier = ref.read(audioRecorderNotifierProvider.notifier);
    if (recorderNotifier.isRecordOrAnalyzeOngoing()) {
      return;
    }

    try {
      recorderNotifier.setAnalyzingState(recording);

      final analyzerNotifier = ref.read(audioAnalyzerNotifierProvider.notifier);
      final analysis = await analyzerNotifier.analyzeAudio(recording);

      LoggerService.info('Analysis completed with status: ${analysis.status}');

      // Navigate to summary if analysis was successful
      if (analysis.status == AnalysisStatus.completed) {
        LoggerService.info('Analysis successful, navigating to summary');
        SchedulerBinding.instance.addPostFrameCallback((_) {
          try {
            AppRouter.router.push('/summaries/${recording.id}');
            LoggerService.info(
              'Navigated to summary details for recording: ${recording.id}',
            );
          } catch (e) {
            LoggerService.error('Could not navigate to summary details: $e');
          }
        });
      } else {
        if (context.mounted) {
          context.showSnackBar(
            analysis.errorMessage ?? localizations.analysisFailed,
            isError: true,
          );
        }
      }
    } catch (e) {
      LoggerService.error('Error analyzing audio: $e');
      if (context.mounted) {
        context.showSnackBar(
          '${localizations.failedToAnalyzeMedia}: $e',
          isError: true,
        );
      }
    } finally {
      recorderNotifier.setCompletedState();
    }
  }

  Future<bool> _prerequisitesMet(BuildContext context, WidgetRef ref) async {
    final recordingFlowNotifier = ref.read(
      recordingFlowNotifierProvider.notifier,
    );
    final prerequisitesMet = await recordingFlowNotifier.checkPrerequisites();

    if (!prerequisitesMet) {
      final flowState = ref.read(recordingFlowNotifierProvider);

      if (flowState.state == RecordingFlowState.needsUsageContext) {
        if (context.mounted) {
          _showUsageContextDialog(context, ref);
        }
      } else if (flowState.state == RecordingFlowState.needsApiKey) {
        if (context.mounted) {
          _showApiKeyDialog(context, ref);
        }
      }
    }
    return prerequisitesMet;
  }

  void _showUsageContextDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => UsageContextSelectionDialog(
        onUsageSelected: (usageContext) {
          ref
              .read(recordingFlowNotifierProvider.notifier)
              .selectUsageContext(usageContext);
        },
      ),
    );
  }

  void _showApiKeyDialog(BuildContext context, WidgetRef ref) {
    showDialog(context: context, builder: (context) => const ApiKeyDialog());
  }
}
