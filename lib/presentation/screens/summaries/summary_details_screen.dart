import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vocario/presentation/screens/summaries/providers/summaries_provider.dart';
import 'package:vocario/presentation/screens/summaries/widgets/audio_player_widget.dart';
import 'package:vocario/core/utils/format_utils.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/audio_analyzer_provider.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/audio_recorder_provider.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:vocario/core/utils/context_extensions.dart';
import 'dart:io';

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
  AudioAnalysis? _previousAnalysis;

  @override
  Widget build(BuildContext context) {
    final recordingAsync = ref.watch(recordingByIdProvider(widget.recordingId));
    final analysisAsync = ref.watch(audioAnalysisByRecordingIdProvider(widget.recordingId));
    final analyzerState = ref.watch(audioAnalyzerNotifierProvider);

    // Listen for analysis failures
    ref.listen<AudioAnalyzerState>(audioAnalyzerNotifierProvider, (previous, next) {
      if (next == AudioAnalyzerState.error) {
        context.showSnackBar(
          'Analysis failed. Please try again.',
          isError: true,
          onClick: () => context.hideSnackBar(),
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

  Widget _buildRecordingInfoCard(BuildContext context, AudioRecording recording) {
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

  Widget _buildAudioPlayerCard(BuildContext context, AudioRecording recording) {
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
            ref.watch(reanalysisNotifierProvider)
                ? _buildAnalysisLoading(context)
                : analysisAsync.when(
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

  Widget _buildAnalysisError(BuildContext context, String? errorMessage, AudioRecording recording) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          size: 36,
          color: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            errorMessage ?? 'Analysis Failed',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
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

  Widget _buildActionButtons(BuildContext context, AudioRecording recording, AsyncValue<AudioAnalysis?> analysisAsync) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: ref.watch(reanalysisNotifierProvider) ? null : () => _reanalyzeRecording(recording),
            icon: const Icon(Icons.refresh),
            label: const Text('Reanalyze'),
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => _showShareOptions(context, recording, analysisAsync),
          icon: const Icon(Icons.share),
          tooltip: 'Share',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: () => _showDeleteConfirmation(context, recording, analysisAsync),
          icon: const Icon(Icons.delete),
          tooltip: 'Delete',
          style: IconButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
          ),
        ),
      ],
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


  void _showDeleteConfirmation(BuildContext context, AudioRecording recording, AsyncValue<AudioAnalysis?> analysisAsync) {
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

  Future<void> _reanalyzeRecording(AudioRecording recording) async {
    if (ref.read(reanalysisNotifierProvider)) return;
    
    try {
      ref.read(reanalysisNotifierProvider.notifier).setReanalyzing(true);
      
      // Store previous analysis for potential restoration
      final currentAnalysis = await ref.read(audioAnalysisByRecordingIdProvider(widget.recordingId).future);
      _previousAnalysis = currentAnalysis;
      
      await ref.read(audioAnalyzerNotifierProvider.notifier).analyzeAudio(recording);
      
      // Invalidate providers to refresh the UI after analysis completes
      ref.invalidate(audioAnalysisByRecordingIdProvider(widget.recordingId));
      ref.invalidate(audioAnalysesListProvider);
      
      ref.read(reanalysisNotifierProvider.notifier).setReanalyzing(false);
    } catch (e) {
      LoggerService.error('Failed to reanalyze recording', e);
      
      ref.read(reanalysisNotifierProvider.notifier).setReanalyzing(false);
      
      if (mounted) {
        context.showSnackBar(
          'Reanalysis failed. Previous analysis restored.',
          isError: true,
        );
      }
      
      // Restore previous analysis if available
      if (_previousAnalysis != null) {
        ref.invalidate(audioAnalysisByRecordingIdProvider(widget.recordingId));
      }
    }
  }

  Future<void> _deleteRecordingAndAnalysis(AudioRecording recording, AsyncValue<AudioAnalysis?> analysisAsync) async {
    try {
      final analysis = analysisAsync.value;
      if (analysis != null) {
        await ref.read(audioAnalyzerRepositoryProvider).deleteAnalysis(analysis.id);
      }
      
      await ref.read(audioRecorderRepositoryProvider).deleteRecording(recording.id);
      
      ref.invalidate(recordingByIdProvider(widget.recordingId));
      ref.invalidate(audioAnalysisByRecordingIdProvider(widget.recordingId));
      ref.invalidate(allRecordingsProvider);
      
      if (mounted) {
        context.showSnackBar('Recording and analysis deleted successfully');
        context.pop();
      }
    } catch (e) {
      LoggerService.error('Failed to delete recording and analysis', e);
      if (mounted) {
        context.showSnackBar('Failed to delete: $e', isError: true);
      }
    }
  }

  void _showShareOptions(BuildContext context, AudioRecording recording, AsyncValue<AudioAnalysis?> analysisAsync) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share Options'),
          content: const Text('What would you like to share?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _shareAudioFile(recording);
              },
              icon: const Icon(Icons.audiotrack),
              label: const Text('Share Audio File'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _shareAnalysisText(analysisAsync);
              },
              icon: const Icon(Icons.text_snippet),
              label: const Text('Share Analysis Text'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _shareAudioFile(AudioRecording recording) async {
    try {
      final file = File(recording.filePath);
      if (await file.exists()) {
        final xFile = XFile(recording.filePath);
        await Share.shareXFiles(
          [xFile],
          text: 'Audio recording from ${FormatUtils.formatDate(recording.createdAt)}',
        );
      } else {
        if (mounted) {
          context.showSnackBar('Audio file not found', isError: true);
        }
      }
    } catch (e) {
      LoggerService.error('Failed to share audio file', e);
      if (mounted) {
        context.showSnackBar('Failed to share audio file: $e', isError: true);
      }
    }
  }

  Future<void> _shareAnalysisText(AsyncValue<AudioAnalysis?> analysisAsync) async {
    try {
      final analysis = analysisAsync.value;
      if (analysis != null && analysis.content.isNotEmpty) {
        // Convert markdown to plain text for sharing
        String textContent = analysis.content
            .replaceAll(RegExp(r'^#{1,6}\s+'), '') // Remove headers
            .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // Remove bold
            .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // Remove italic
            .replaceAll(RegExp(r'_(.*?)_'), r'$1') // Remove italic underscore
            .replaceAll(RegExp(r'`(.*?)`'), r'$1') // Remove inline code
            .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1') // Remove links, keep text
            .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '') // Remove bullet points
            .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '') // Remove numbered lists
            .replaceAll(RegExp(r'^\s*>\s+', multiLine: true), '') // Remove blockquotes
            .replaceAll(RegExp(r'\n\s*\n'), '\n') // Remove extra blank lines
            .trim();
        
        await Share.share(
          textContent,
          subject: 'Audio Analysis Results',
        );
      } else {
        if (mounted) {
          context.showSnackBar('No analysis content available to share', isError: true);
        }
      }
    } catch (e) {
      LoggerService.error('Failed to share analysis text', e);
      if (mounted) {
        context.showSnackBar(
          'Failed to share analysis text: $e',
          isError: true,
        );
      }
    }
  }

  Widget _buildMarkdownContent(BuildContext context, String content) {
    return SizedBox(
      width: double.infinity,
      child: MarkdownBlock(data: content),
    );
  }
}