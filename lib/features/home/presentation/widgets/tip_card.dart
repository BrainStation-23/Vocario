import 'package:flutter/material.dart';
import 'package:vocario/core/l10n/app_localizations.dart';

class TipCard extends StatelessWidget {
  const TipCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                localizations.tipMessage,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}