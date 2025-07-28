import 'package:flutter/material.dart';

@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.gradientStart,
    required this.gradientMiddle,
    required this.gradientEnd,
    required this.micButtonGradientStart,
    required this.micButtonGradientEnd,
    required this.menuButtonBackground,
    required this.menuButtonIcon,
  });

  final Color gradientStart;
  final Color gradientMiddle;
  final Color gradientEnd;
  final Color micButtonGradientStart;
  final Color micButtonGradientEnd;
  final Color menuButtonBackground;
  final Color menuButtonIcon;

  @override
  AppColors copyWith({
    Color? gradientStart,
    Color? gradientMiddle,
    Color? gradientEnd,
    Color? micButtonGradientStart,
    Color? micButtonGradientEnd,
    Color? menuButtonBackground,
    Color? menuButtonIcon,
  }) {
    return AppColors(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientMiddle: gradientMiddle ?? this.gradientMiddle,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      micButtonGradientStart: micButtonGradientStart ?? this.micButtonGradientStart,
      micButtonGradientEnd: micButtonGradientEnd ?? this.micButtonGradientEnd,
      menuButtonBackground: menuButtonBackground ?? this.menuButtonBackground,
      menuButtonIcon: menuButtonIcon ?? this.menuButtonIcon,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientMiddle: Color.lerp(gradientMiddle, other.gradientMiddle, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      micButtonGradientStart: Color.lerp(micButtonGradientStart, other.micButtonGradientStart, t)!,
      micButtonGradientEnd: Color.lerp(micButtonGradientEnd, other.micButtonGradientEnd, t)!,
      menuButtonBackground: Color.lerp(menuButtonBackground, other.menuButtonBackground, t)!,
      menuButtonIcon: Color.lerp(menuButtonIcon, other.menuButtonIcon, t)!,
    );
  }

  // Light theme colors
  static const light = AppColors(
    gradientStart: Color(0xFF6A4C93),
    gradientMiddle: Color(0xFF007FFF),
    gradientEnd: Color(0xFF8B5CF6),
    micButtonGradientStart: Color(0xFF007FFF),
    micButtonGradientEnd: Color(0xFF6A4C93),
    menuButtonBackground: Color(0xFFFFFFFF),
    menuButtonIcon: Color(0xFF000000),
  );

  // Dark theme colors
  static const dark = AppColors(
    gradientStart: Color(0xFF2D1B69),
    gradientMiddle: Color(0xFF1A1A2E),
    gradientEnd: Color(0xFF16213E),
    micButtonGradientStart: Color(0xFF6A4C93),
    micButtonGradientEnd: Color(0xFF007FFF),
    menuButtonBackground: Color(0xFF2D2D2D),
    menuButtonIcon: Color(0xFFFFFFFF),
  );
}