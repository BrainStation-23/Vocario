import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/audio_analyzer_provider.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/recordings_provider.dart';
import 'package:vocario/features/audio_analyzer/presentation/screens/widgets/analysis_content.dart';
import 'package:vocario/features/audio_analyzer/presentation/screens/widgets/analysis_error.dart';
import 'package:vocario/features/audio_analyzer/presentation/screens/widgets/analysis_loading.dart';
import 'package:vocario/features/audio_analyzer/presentation/screens/widgets/no_analysis.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';

class AnalysisCard extends ConsumerWidget {
  final AsyncValue<AudioAnalysis?> analysisAsync;
  final AudioAnalyzerState analyzerState;
  final AudioRecording recording;

  const AnalysisCard({
    super.key,
    required this.analysisAsync,
    required this.analyzerState,
    required this.recording,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context)!;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  localizations.analysisResults,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ref.watch(reanalysisNotifierProvider)
                ? const AnalysisLoading()
                : analysisAsync.when(
                    data: (analysis) {
                      if (analysis != null && analysis.status == AnalysisStatus.completed) {
                        return AnalysisContent(analysis: analysis);
                      } else if (analyzerState == AudioAnalyzerState.analyzing) {
                        return const AnalysisLoading();
                      } else if (analyzerState == AudioAnalyzerState.error) {
                        return AnalysisError(
                          errorMessage: localizations.analysisFailed,
                          recording: recording,
                        );
                      } else {
                        return const NoAnalysis();
                      }
                    },
                    loading: () => const AnalysisLoading(),
                    error: (error, stack) => AnalysisError(
                      errorMessage: error.toString(),
                      recording: recording,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}