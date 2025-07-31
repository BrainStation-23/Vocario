import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/utils/app_utils.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';

class ShareOptionsDialog extends StatelessWidget {
  final AudioRecording recording;
  final AsyncValue<AudioAnalysis?> analysisAsync;

  const ShareOptionsDialog({
    super.key,
    required this.recording,
    required this.analysisAsync,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return AlertDialog(
      title: Text(localizations.shareOptions),
      content: Text(localizations.shareOptionsDescription),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(localizations.cancel),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            AppUtils.shareAudioFile(recording, context);
          },
          icon: const Icon(Icons.audiotrack),
          label: Text(localizations.shareAudioFile),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.of(context).pop();
            AppUtils.shareAnalysisText(analysisAsync, context);
          },
          icon: const Icon(Icons.text_snippet),
          label: Text(localizations.shareAnalysisText),
        ),
      ],
    );
  }
}