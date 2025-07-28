import 'package:flutter/material.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:vocario/core/routing/app_router.dart';
import 'package:vocario/features/audio_recorder/presentation/widgets/animated_recording_button.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: const AnimatedRecordingButton(),
    );
  }
}
