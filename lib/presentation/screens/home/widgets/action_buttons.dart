import 'package:flutter/material.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:vocario/core/routing/app_router.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;

    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              appColors.micButtonGradientStart,
              appColors.micButtonGradientEnd,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IconButton(
          onPressed: () => context.push(AppRouter.audioSummarizer),
          icon: const Icon(Icons.mic, size: 70, color: Colors.white),
          iconSize: 120,
        ),
      ),
    );
  }
}
