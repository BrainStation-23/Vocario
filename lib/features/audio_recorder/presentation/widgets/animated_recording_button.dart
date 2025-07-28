import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/core/utils/format_utils.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/audio_recorder_provider.dart';

class AnimatedRecordingButton extends ConsumerStatefulWidget {
  const AnimatedRecordingButton({super.key});

  @override
  ConsumerState<AnimatedRecordingButton> createState() => _AnimatedRecordingButtonState();
}

class _AnimatedRecordingButtonState extends ConsumerState<AnimatedRecordingButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _waveController.repeat(reverse: true);
  }

  void _stopAnimations() {
    _pulseController.stop();
    _waveController.stop();
    _pulseController.reset();
    _waveController.reset();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = Theme.of(context).extension<AppColors>()!;
    final recording = ref.watch(audioRecorderNotifierProvider);
    final isRecording = recording?.isRecording ?? false;
    final recordingDuration = recording?.duration ?? Duration.zero;

    if (isRecording && !_pulseController.isAnimating) {
      _startAnimations();
    } else if (!isRecording && _pulseController.isAnimating) {
      _stopAnimations();
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_pulseAnimation, _waveAnimation]),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (isRecording) ..._buildSoundWaves(appColors),
                  Transform.scale(
                    scale: isRecording ? _pulseAnimation.value : 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isRecording
                              ? [Colors.red.shade400, Colors.red.shade600]
                              : [
                                  appColors.micButtonGradientStart,
                                  appColors.micButtonGradientEnd,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => ref.read(audioRecorderNotifierProvider.notifier).toggleRecording(),
                        icon: Icon(
                          isRecording ? Icons.stop : Icons.mic,
                          size: 70,
                          color: Colors.white,
                        ),
                        iconSize: 120,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          if (isRecording) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.fiber_manual_record,
                    color: Colors.red,
                    size: 12,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    FormatUtils.formatDuration(recordingDuration),
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildSoundWaves(AppColors appColors) {
    return List.generate(3, (index) {
      final delay = index * 0.2;
      final scale = 1.0 + (_waveAnimation.value * (1.0 - delay));
      final opacity = 1.0 - (_waveAnimation.value * 0.8);
      
      return Transform.scale(
        scale: scale,
        child: Container(
          width: 140 + (index * 20),
          height: 140 + (index * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.red.withValues(alpha: opacity * 0.5),
              width: 2,
            ),
          ),
        ),
      );
    });
  }
}