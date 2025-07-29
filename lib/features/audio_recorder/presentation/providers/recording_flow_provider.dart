import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocario/core/services/storage_service.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_summarization_context.dart';
import 'package:vocario/core/services/logger_service.dart';

part 'recording_flow_provider.g.dart';

enum RecordingFlowState {
  idle,
  checkingPrerequisites,
  needsUsageContext,
  needsApiKey,
  readyToRecord,
  error,
}

class RecordingFlowData {
  final RecordingFlowState state;
  final AudioSummarizationContext? selectedUsageContext;
  final bool hasApiKey;
  final String? errorMessage;

  const RecordingFlowData({
    required this.state,
    this.selectedUsageContext,
    this.hasApiKey = false,
    this.errorMessage,
  });

  RecordingFlowData copyWith({
    RecordingFlowState? state,
    AudioSummarizationContext? selectedUsageContext,
    bool? hasApiKey,
    String? errorMessage,
  }) {
    return RecordingFlowData(
      state: state ?? this.state,
      selectedUsageContext: selectedUsageContext ?? this.selectedUsageContext,
      hasApiKey: hasApiKey ?? this.hasApiKey,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

@Riverpod(keepAlive: true)
class RecordingFlowNotifier extends _$RecordingFlowNotifier {
  @override
  RecordingFlowData build() {
    // Initialize and load saved data
    _initializeFromStorage();
    return const RecordingFlowData(state: RecordingFlowState.idle);
  }

  Future<void> _initializeFromStorage() async {
    try {
      // Load saved usage context
      final savedUsageContext = await StorageService.getUsageContext();
      AudioSummarizationContext? usageContext;
      
      if (savedUsageContext != null) {
        try {
          usageContext = AudioSummarizationContext.values.firstWhere(
            (context) => context.name == savedUsageContext,
          );
          LoggerService.info('Loaded saved usage context: ${usageContext.displayName}');
        } catch (e) {
          LoggerService.warning('Invalid saved usage context: $savedUsageContext');
          await StorageService.removeUsageContext();
        }
      }
      
      // Check if API key is saved
      final hasApiKey = await StorageService.hasApiKey();
      
      // Update state with loaded data
      if (usageContext != null) {
        state = state.copyWith(
          selectedUsageContext: usageContext,
          hasApiKey: hasApiKey,
          state: hasApiKey ? RecordingFlowState.readyToRecord : RecordingFlowState.idle,
        );
      }
    } catch (e, stackTrace) {
      LoggerService.error('Error initializing from storage', e, stackTrace);
    }
  }

  Future<bool> checkPrerequisites() async {
    try {
      state = state.copyWith(state: RecordingFlowState.checkingPrerequisites);
      
      LoggerService.info('Checking recording prerequisites...');
      
      // Check if usage context is saved
      final savedUsageContext = await StorageService.getUsageContext();
      AudioSummarizationContext? usageContext;
      
      if (savedUsageContext != null) {
        try {
          usageContext = AudioSummarizationContext.values.firstWhere(
            (context) => context.name == savedUsageContext,
          );
          LoggerService.info('Found saved usage context: ${usageContext.displayName}');
        } catch (e) {
          LoggerService.warning('Invalid saved usage context: $savedUsageContext');
          await StorageService.removeUsageContext();
        }
      }
      
      if (usageContext == null) {
        LoggerService.info('No valid usage context found, prompting user');
        state = state.copyWith(
          state: RecordingFlowState.needsUsageContext,
          selectedUsageContext: null,
        );
        return false;
      }
      
      // Check if API key is saved
      final hasApiKey = await StorageService.hasApiKey();
      LoggerService.info('API key check result: $hasApiKey');
      
      if (!hasApiKey) {
        LoggerService.info('No API key found, prompting user');
        state = state.copyWith(
          state: RecordingFlowState.needsApiKey,
          selectedUsageContext: usageContext,
          hasApiKey: false,
        );
        return false;
      }
      
      // All prerequisites met
      LoggerService.info('All prerequisites met, ready to record');
      state = state.copyWith(
        state: RecordingFlowState.readyToRecord,
        selectedUsageContext: usageContext,
        hasApiKey: true,
      );
      return true;
      
    } catch (e, stackTrace) {
      LoggerService.error('Error checking prerequisites', e, stackTrace);
      state = state.copyWith(
        state: RecordingFlowState.error,
        errorMessage: 'Failed to check prerequisites: $e',
      );
      return false;
    }
  }

  Future<void> selectUsageContext(AudioSummarizationContext usageContext) async {
    try {
      LoggerService.info('Saving selected usage context: ${usageContext.displayName}');
      await StorageService.saveUsageContext(usageContext.name);
      
      state = state.copyWith(
        selectedUsageContext: usageContext,
      );
      
      // Re-check prerequisites after selecting usage context
      await checkPrerequisites();
    } catch (e, stackTrace) {
      LoggerService.error('Error saving usage context', e, stackTrace);
      state = state.copyWith(
        state: RecordingFlowState.error,
        errorMessage: 'Failed to save usage context: $e',
      );
    }
  }

  Future<void> changeUsageContext(AudioSummarizationContext usageContext) async {
    await selectUsageContext(usageContext);
  }

  void resetFlow() {
    state = const RecordingFlowData(state: RecordingFlowState.idle);
  }

  void markApiKeyAvailable() {
    if (state.selectedUsageContext != null) {
      state = state.copyWith(
        state: RecordingFlowState.readyToRecord,
        hasApiKey: true,
      );
    }
  }
}