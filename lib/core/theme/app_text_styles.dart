import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class AppTextStyles extends ThemeExtension<AppTextStyles> {
  const AppTextStyles({
    required this.welcomeTitle,
    required this.welcomeSubtitle,
    required this.buttonText,
    required this.bodyText,
    required this.headlineText,
  });

  final TextStyle welcomeTitle;
  final TextStyle welcomeSubtitle;
  final TextStyle buttonText;
  final TextStyle bodyText;
  final TextStyle headlineText;

  @override
  AppTextStyles copyWith({
    TextStyle? welcomeTitle,
    TextStyle? welcomeSubtitle,
    TextStyle? buttonText,
    TextStyle? bodyText,
    TextStyle? headlineText,
  }) {
    return AppTextStyles(
      welcomeTitle: welcomeTitle ?? this.welcomeTitle,
      welcomeSubtitle: welcomeSubtitle ?? this.welcomeSubtitle,
      buttonText: buttonText ?? this.buttonText,
      bodyText: bodyText ?? this.bodyText,
      headlineText: headlineText ?? this.headlineText,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) {
      return this;
    }
    return AppTextStyles(
      welcomeTitle: TextStyle.lerp(welcomeTitle, other.welcomeTitle, t)!,
      welcomeSubtitle: TextStyle.lerp(welcomeSubtitle, other.welcomeSubtitle, t)!,
      buttonText: TextStyle.lerp(buttonText, other.buttonText, t)!,
      bodyText: TextStyle.lerp(bodyText, other.bodyText, t)!,
      headlineText: TextStyle.lerp(headlineText, other.headlineText, t)!,
    );
  }

  // Light theme text styles
  static final light = AppTextStyles(
    welcomeTitle: GoogleFonts.roboto(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    welcomeSubtitle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white.withValues(alpha: 0.9),
    ),
    buttonText: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    bodyText: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.black87,
    ),
    headlineText: GoogleFonts.roboto(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    ),
  );

  // Dark theme text styles
  static final dark = AppTextStyles(
    welcomeTitle: GoogleFonts.roboto(
      fontSize: 28,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    welcomeSubtitle: GoogleFonts.roboto(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: Colors.white.withValues(alpha: 0.9),
    ),
    buttonText: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    bodyText: GoogleFonts.roboto(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: Colors.white70,
    ),
    headlineText: GoogleFonts.roboto(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );
}