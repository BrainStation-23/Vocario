import 'dart:math';
import 'package:flutter/material.dart';

class SoundwaveWidget extends StatefulWidget {
  final bool isPlaying;
  final Duration currentPosition;
  final Duration totalDuration;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final int barCount;
  final VoidCallback? onTap;

  const SoundwaveWidget({
    super.key,
    required this.isPlaying,
    required this.currentPosition,
    required this.totalDuration,
    this.activeColor,
    this.inactiveColor,
    this.height = 60,
    this.barCount = 50,
    this.onTap,
  });

  @override
  State<SoundwaveWidget> createState() => _SoundwaveWidgetState();
}

class _SoundwaveWidgetState extends State<SoundwaveWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _barControllers;
  late List<Animation<double>> _barAnimations;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _barControllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + _random.nextInt(400)),
        vsync: this,
      ),
    );

    _barAnimations = _barControllers.map((controller) {
      return Tween<double>(
        begin: 0.1,
        end: 0.3 + _random.nextDouble() * 0.7,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    if (widget.isPlaying) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    for (int i = 0; i < _barControllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 20), () {
        if (mounted && widget.isPlaying) {
          _barControllers[i].repeat(reverse: true);
        }
      });
    }
  }

  void _stopAnimation() {
    for (final controller in _barControllers) {
      controller.stop();
      controller.reset();
    }
  }

  @override
  void didUpdateWidget(SoundwaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (final controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  double _getProgressRatio() {
    if (widget.totalDuration.inMilliseconds == 0) return 0.0;
    return widget.currentPosition.inMilliseconds / widget.totalDuration.inMilliseconds;
  }

  @override
  Widget build(BuildContext context) {
    final progressRatio = _getProgressRatio();
    final activeColor = widget.activeColor ?? Theme.of(context).colorScheme.primary;
    final inactiveColor = widget.inactiveColor ?? 
        Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: widget.height,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: List.generate(widget.barCount, (index) {
            final barProgress = index / widget.barCount;
            final isActive = barProgress <= progressRatio;
            
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1),
                child: AnimatedBuilder(
                  animation: widget.isPlaying ? _barAnimations[index] : _animationController,
                  builder: (context, child) {
                    double barHeight;
                    if (widget.isPlaying) {
                      barHeight = widget.height * _barAnimations[index].value;
                    } else {
                      // Flatline when not playing
                      barHeight = 2;
                    }
                    
                    return Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: isActive ? activeColor : inactiveColor,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}