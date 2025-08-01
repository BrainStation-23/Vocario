import 'package:flutter/material.dart';
import 'package:vocario/core/l10n/app_localizations.dart';

class NoAnalysis extends StatelessWidget {
  const NoAnalysis({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      children: [
        Icon(
          Icons.analytics_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          localizations.noAnalysisAvailable,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          localizations.startAnalysisMessage,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}