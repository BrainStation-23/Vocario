import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/l10n/app_localizations.dart';

class BottomButtons extends ConsumerWidget {
  const BottomButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;

    return OutlinedButton.icon(
      onPressed: () {
        // import audio
      },
      icon: const Icon(Icons.upload_file),
      label: Text(localizations.importAudio),
      style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(16)),
    );
  }
}
