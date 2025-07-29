import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:vocario/presentation/screens/summaries/providers/summaries_provider.dart';
import 'package:vocario/presentation/screens/summaries/widgets/audio_player_widget.dart';
import 'package:vocario/core/utils/format_utils.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/audio_analyzer_provider.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/audio_recorder_provider.dart';
import 'package:vocario/core/services/logger_service.dart';

class SummaryDetailsScreen extends ConsumerStatefulWidget {
  final String recordingId;

  const SummaryDetailsScreen({
    super.key,
    required this.recordingId,
  });

  @override
  ConsumerState<SummaryDetailsScreen> createState() => _SummaryDetailsScreenState();
}

class _SummaryDetailsScreenState extends ConsumerState<SummaryDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Check if analysis exists, if not start analysis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndStartAnalysis();
    });
  }

  void _checkAndStartAnalysis() async {
    final analysis = await ref.read(audioAnalysisByRecordingIdProvider(widget.recordingId).future);
    if (analysis == null) {
      final recording = await ref.read(recordingByIdProvider(widget.recordingId).future);
      if (recording != null) {
        ref.read(audioAnalyzerNotifierProvider.notifier).analyzeAudio(recording);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recordingAsync = ref.watch(recordingByIdProvider(widget.recordingId));
    final analysisAsync = ref.watch(audioAnalysisByRecordingIdProvider(widget.recordingId));
    final analyzerState = ref.watch(audioAnalyzerNotifierProvider);

    // Listen for analysis failures
    ref.listen<AudioAnalyzerState>(audioAnalyzerNotifierProvider, (previous, next) {
      if (next == AudioAnalyzerState.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Analysis failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            action: SnackBarAction(
              label: 'Dismiss',
              textColor: Theme.of(context).colorScheme.onError,
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recording Details'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: recordingAsync.when(
        data: (recording) {
          if (recording == null) {
            return _buildErrorWidget('Recording not found');
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRecordingInfoCard(context, recording),
                      const SizedBox(height: 16),
                      _buildAudioPlayerCard(context, recording),
                      const SizedBox(height: 16),
                      _buildAnalysisCard(context, analysisAsync, analyzerState, recording),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  border: Border(
                    top: BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    ),
                  ),
                ),
                child: SafeArea(
                  child: _buildActionButtons(context, recording, analysisAsync),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorWidget('Failed to load recording: $error'),
      ),
    );
  }

  Widget _buildRecordingInfoCard(BuildContext context, recording) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.mic,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Recording Information',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, 'File Name', FormatUtils.getFileName(recording.filePath)),
            const SizedBox(height: 8),
            _buildInfoRow(context, 'Duration', FormatUtils.formatDuration(recording.duration)),
            const SizedBox(height: 8),
            _buildInfoRow(context, 'File Size', FormatUtils.formatFileSize(recording.fileSizeBytes)),
            const SizedBox(height: 8),
            _buildInfoRow(context, 'Created', FormatUtils.formatDate(recording.createdAt)),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayerCard(BuildContext context, recording) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.play_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Audio Player',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            AudioPlayerWidget(
              filePath: recording.filePath,
              duration: recording.duration,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(BuildContext context, AsyncValue<AudioAnalysis?> analysisAsync, AudioAnalyzerState analyzerState, AudioRecording recording) {
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
                  'Analysis Results',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            analysisAsync.when(
              data: (analysis) {
                 if (analysis != null && analysis.status == AnalysisStatus.completed) {
                   return _buildAnalysisContent(context, analysis);
                 } else if (analyzerState == AudioAnalyzerState.analyzing) {
                   return _buildAnalysisLoading(context);
                 } else if (analyzerState == AudioAnalyzerState.error) {
                   return _buildAnalysisError(context, 'Analysis failed', recording);
                 } else {
                   return _buildNoAnalysis(context);
                 }
               },
              loading: () => _buildAnalysisLoading(context),
              error: (error, stack) => _buildAnalysisError(context, error.toString(), recording),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisContent(BuildContext context, AudioAnalysis analysis) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Analysis Complete',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (analysis.content.isNotEmpty)
          _buildMarkdownContent(context, analysis.content),
      ],
    );
  }

  Widget _buildAnalysisLoading(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TweenAnimationBuilder<double>(
                duration: const Duration(seconds: 2),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Icon(
                      Icons.analytics,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'AI is processing your recording...',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This may take a few moments',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisError(BuildContext context, String? errorMessage, recording) {
    return Column(
      children: [
        Icon(
          Icons.error_outline,
          size: 48,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        Text(
          'Analysis Failed',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          errorMessage ?? 'An error occurred during analysis',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(audioAnalyzerNotifierProvider.notifier).analyzeAudio(recording);
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Retry Analysis'),
        ),
      ],
    );
  }

  Widget _buildNoAnalysis(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.analytics_outlined,
          size: 48,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        Text(
          'No Analysis Available',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Start analysis to get insights from your recording',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, recording, analysisAsync) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(audioAnalyzerNotifierProvider.notifier).analyzeAudio(recording);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reanalyze'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showDeleteConfirmation(context, recording, analysisAsync),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildCopyableText(BuildContext context, String text) {
    return GestureDetector(
      onLongPress: () => _copyToClipboard(context, text),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Copied to clipboard'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, recording, analysisAsync) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Recording'),
          content: const Text(
            'Are you sure you want to delete this recording and its analysis? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteRecordingAndAnalysis(recording, analysisAsync);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRecordingAndAnalysis(recording, analysisAsync) async {
    try {
      // Delete analysis if it exists
      final analysis = await analysisAsync.value;
      if (analysis != null) {
        await ref.read(audioAnalyzerRepositoryProvider).deleteAnalysis(analysis.id);
      }
      
      // Delete recording file
      await ref.read(audioRecorderRepositoryProvider).deleteRecording(recording.id);
      
      // Invalidate providers to refresh data
      ref.invalidate(recordingByIdProvider(widget.recordingId));
      ref.invalidate(audioAnalysisByRecordingIdProvider(widget.recordingId));
      ref.invalidate(allRecordingsProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording and analysis deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      LoggerService.error('Failed to delete recording and analysis', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildMarkdownContent(BuildContext context, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Html(
        data: content,
        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,
            fontSize: FontSize(14),
            color: Theme.of(context).colorScheme.onSurface,
          ),
          "h1": Style(
            fontSize: FontSize(20),
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
            margin: Margins.only(bottom: 12),
          ),
          "h2": Style(
            fontSize: FontSize(18),
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
            margin: Margins.only(top: 16, bottom: 8),
          ),
          "p": Style(
            margin: Margins.only(bottom: 8),
            lineHeight: LineHeight(1.5),
          ),
          "ul": Style(
            margin: Margins.only(left: 16, bottom: 8),
          ),
          "li": Style(
            margin: Margins.only(bottom: 4),
          ),
        },
      ),
    );
  }
}