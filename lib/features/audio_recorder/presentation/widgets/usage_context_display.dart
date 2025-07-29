import 'package:flutter/material.dart';
import 'package:vocario/core/theme/app_text_styles.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_summarization_context.dart';
import 'package:vocario/features/audio_recorder/presentation/widgets/usage_context_selection_dialog.dart';

class UsageContextDisplay extends StatelessWidget {
  final AudioSummarizationContext usageContext;
  final Function(AudioSummarizationContext) onUsageChanged;

  const UsageContextDisplay({
    super.key,
    required this.usageContext,
    required this.onUsageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final appTextStyles = Theme.of(context).extension<AppTextStyles>()!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surfaceContainerLow.withValues(alpha: 0.8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.category_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Recording Mode',
                style: appTextStyles.bodyText.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showUsageContextDialog(context),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Change',
                  style: appTextStyles.buttonText.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            usageContext.displayName,
            style: appTextStyles.headlineText.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            usageContext.description,
            style: appTextStyles.bodyText.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showUsageContextDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UsageContextSelectionDialog(
        onUsageSelected: onUsageChanged,
      ),
    );
  }
}