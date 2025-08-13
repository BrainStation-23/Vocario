import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/features/audio_analyzer/presentation/screens/widgets/recording_list_item.dart';
import 'package:vocario/features/audio_analyzer/presentation/providers/recordings_provider.dart';

class RecordingListScreen extends ConsumerStatefulWidget {
  const RecordingListScreen({super.key});

  @override
  ConsumerState<RecordingListScreen> createState() => _RecordingListScreenState();
}

class _RecordingListScreenState extends ConsumerState<RecordingListScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh recordings when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recordingsNotifierProvider.notifier).refreshRecordings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final recordingsAsync = ref.watch(recordingsNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.summarize,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    localizations.summaries,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // Refresh button
                  IconButton(
                    onPressed: () {
                      ref.read(recordingsNotifierProvider.notifier).refreshRecordings();
                    },
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: recordingsAsync.when(
                data: (recordings) {
                  if (recordings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.summarize_outlined,
                            size: 64,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            localizations.noRecordingsYet,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            localizations.startRecordingMessage,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: recordings.length,
                    itemBuilder: (context, index) {
                      final recording = recordings[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RecordingListItem(
                          recording: recording,
                          onTap: () => context.push('/summaries/${recording.id}'),
                        ),
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
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
                        localizations.failedToLoadRecordings,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(recordingsNotifierProvider.notifier).refreshRecordings();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}