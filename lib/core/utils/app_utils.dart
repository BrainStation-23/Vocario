import 'package:flutter/material.dart';
import 'package:vocario/core/constants/app_constants.dart';

class AppUtils {
  // File size validation
  static bool isFileSizeValid(int fileSizeBytes) {
    final fileSizeMB = fileSizeBytes / (1024 * 1024);
    return fileSizeMB <= AppConstants.maxFileSizeMB;
  }

  // Audio format validation
  static bool isAudioFormatSupported(String fileName) {
    final extension = getFileExtension(fileName).toLowerCase();
    return AppConstants.supportedAudioFormats.contains(extension);
  }

  // Video format validation
  static bool isVideoFormatSupported(String fileName) {
    final extension = getFileExtension(fileName).toLowerCase();
    return AppConstants.supportedVideoFormats.contains(extension);
  }

  // Get file extension
  static String getFileExtension(String fileName) {
    return fileName.split('.').last;
  }

  // Format file size
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  // Format duration
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
      ),
    );
  }

  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }

  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Generate error message with parameters
  static String generateErrorMessage(String template, Map<String, String> parameters) {
    String message = template;
    parameters.forEach((key, value) {
      message = message.replaceAll('{$key}', value);
    });
    return message;
  }
}

// Extensions
extension StringExtensions on String {
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }
}

extension DurationExtensions on Duration {
  String get formatted => AppUtils.formatDuration(this);
}

extension IntExtensions on int {
  String get formattedFileSize => AppUtils.formatFileSize(this);
}