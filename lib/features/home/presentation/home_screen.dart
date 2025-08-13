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

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final appTextStyles = Theme.of(context).extension<AppTextStyles>()!;
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
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
                    Expanded(
                      child: Center(
                        child: const AnimatedRecordingButton(),
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
    );
  }
}