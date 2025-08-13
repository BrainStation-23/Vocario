import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/utils/context_extensions.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/core/theme/app_text_styles.dart';
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
    final appColors = Theme.of(context).extension<AppColors>()!;
    final appTextStyles = Theme.of(context).extension<AppTextStyles>()!;

    return Center(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: ElevatedButton.icon(
          onPressed: () => _showImportOptions(context, ref),
          icon: const Icon(Icons.upload_file, size: 24),
          label: Text(
            localizations.importMedia,
            style: appTextStyles.buttonText.copyWith(fontSize: 16),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: appColors.micButtonGradientStart,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            shadowColor: appColors.micButtonGradientStart.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  void _showImportOptions(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    final appTextStyles = Theme.of(context).extension<AppTextStyles>()!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Text(
                  localizations.importMedia,
                  style: appTextStyles.headlineText.copyWith(fontSize: 20),
                ),
              ),
              // Import options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Column(
                  children: [
                    _ImportOptionCard(
                      icon: Icons.audiotrack,
                      title: localizations.importAudio,
                      subtitle: 'Import audio files',
                      onTap: () {
                        Navigator.pop(context);
                        _importMedia(context, ref, true);
                      },
                    ),
                    const SizedBox(height: 12),
                    _ImportOptionCard(
                      icon: Icons.video_file,
                      title: localizations.importVideo,
                      subtitle: 'Import video files and extract audio',
                      onTap: () {
                        Navigator.pop(context);
                        _importMedia(context, ref, false);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
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

class _ImportOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ImportOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final appTextStyles = Theme.of(context).extension<AppTextStyles>()!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      appColors.micButtonGradientStart,
                      appColors.micButtonGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: appTextStyles.buttonText.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: appTextStyles.bodyText.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
