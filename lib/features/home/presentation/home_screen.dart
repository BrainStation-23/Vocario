import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/core/theme/app_text_styles.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/constants/app_constants.dart';
import 'package:vocario/features/home/presentation/widgets/home_widgets.dart';
import 'package:vocario/features/audio_recorder/presentation/widgets/animated_recording_button.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/recording_flow_provider.dart';
import 'package:vocario/features/audio_recorder/presentation/widgets/usage_context_display.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/audio_recorder_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final appTextStyles = Theme.of(context).extension<AppTextStyles>()!;
    final localizations = AppLocalizations.of(context)!;
    final recorder = ref.watch(audioRecorderNotifierProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  appColors.gradientStart,
                  appColors.gradientMiddle,
                  appColors.gradientEnd,
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  AppConstants.defaultPadding,
                  MediaQuery.of(context).size.height * 0.08,
                  AppConstants.defaultPadding,
                  AppConstants.defaultPadding
              ),
              child: Column(
                children: [
                  Center(
                    child: WelcomeCard(
                      title: localizations.welcomeTitle,
                      subtitle: localizations.welcomeSubtitle,
                      titleStyle: appTextStyles.welcomeTitle,
                      subtitleStyle: appTextStyles.welcomeSubtitle,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // Show usage context if available
                        Consumer(
                          builder: (context, ref, child) {
                            final flowState = ref.watch(recordingFlowNotifierProvider);
                            if (flowState.selectedUsageContext != null) {
                              return UsageContextDisplay(
                                usageContext: flowState.selectedUsageContext!,
                                onUsageChanged: (usageContext) {
                                  ref.read(recordingFlowNotifierProvider.notifier).changeUsageContext(usageContext);
                                },
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        const Expanded(
                          child: Center(
                            child: AnimatedRecordingButton(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 32.0),
                    child: BottomButtons(),
                  ),
                ],
              ),
            ),
          ),
          if (recorder.state == RecorderState.extractingAudio)
            const _BlockingProgressModal(title: 'Extracting audio...'),
        ],
      ),
    );
  }
}

class _BlockingProgressModal extends StatelessWidget {
  final String title;
  const _BlockingProgressModal({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
          color: Colors.black.withAlpha(45),
          child: Center(
            child: Container(
              width: 260,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 48,
                    height: 48,
                    child: CircularProgressIndicator(strokeWidth: 4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}