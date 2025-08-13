import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vocario/core/constants/app_constants.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:vocario/core/utils/context_extensions.dart';
import 'package:vocario/core/utils/format_utils.dart';
import 'package:vocario/features/audio_analyzer/domain/entities/audio_analysis.dart';
import 'package:vocario/features/audio_recorder/domain/entities/audio_recording.dart';
import 'package:vocario/core/l10n/app_localizations.dart';

class AppUtils {
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
            if (message != null) ...[const SizedBox(height: 16), Text(message)],
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
  static String generateErrorMessage(
    String template,
    Map<String, String> parameters,
  ) {
    String message = template;
    parameters.forEach((key, value) {
      message = message.replaceAll('{$key}', value);
    });
    return message;
  }

  static Future<Directory> getAudioDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final audioDir = Directory('${appDir.path}/audio');
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }

    return audioDir;
  }

  /// Converts a file path to an ID by removing the file extension and replacing spaces with underscores.
  static String filePathToID(String path) {
    final fileName = path.split('/').last;
    final fileNameWithoutExtension = fileName.replaceAll(
      RegExp(r'\.[^.]*$'),
      '',
    );
    return fileNameWithoutExtension.replaceAll(RegExp(r'\s+'), '_');
  }

  // Share audio file
  static Future<void> shareAudioFile(
    AudioRecording recording,
    BuildContext context,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final file = File(recording.filePath);
      if (await file.exists()) {
        final xFile = XFile(recording.filePath);
        await Share.shareXFiles(
          [xFile],
          text: localizations.audioRecordingFrom(
            FormatUtils.formatDate(recording.createdAt),
          ),
        );
      } else {
        if (context.mounted) {
          context.showSnackBar(localizations.audioFileNotFound, isError: true);
        }
      }
    } catch (e) {
      LoggerService.error('Failed to share audio file', e);
      if (context.mounted) {
        context.showSnackBar(
          localizations.failedToShareAudioFile(e.toString()),
          isError: true,
        );
      }
    }
  }

  // Share analysis text
  static Future<void> shareAnalysisText(
    AsyncValue<AudioAnalysis?> analysisAsync,
    BuildContext context,
  ) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      final analysis = analysisAsync.value;
      if (analysis != null && analysis.content.isNotEmpty) {
        String textContent = analysis.content
            // Remove headings (# H1, ## H2...) anywhere
            .replaceAll(RegExp(r'^#{1,6}\s+', multiLine: true), '')
            // Bold (**bold**)
            .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1')
            // Italics with *italic* but not bold (**)
            .replaceAll(RegExp(r'(?<!\*)\*(?!\*)(.*?)\*(?<!\*)'), r'$1')
            // Italics with _italic_ (avoid matching URLs/emails)
            .replaceAll(RegExp(r'(?<!\w)_(?!_)(.*?)_(?!\w)'), r'$1')
            // Inline code `code`
            .replaceAll(RegExp(r'`([^`]*)`'), r'$1')
            // Links [text](url)
            .replaceAll(RegExp(r'\[(.*?)\]\(.*?\)'), r'$1')
            // Bullet points
            .replaceAll(RegExp(r'^\s*[-*+]\s+', multiLine: true), '')
            // Numbered lists
            .replaceAll(RegExp(r'^\s*\d+\.\s+', multiLine: true), '')
            // Blockquotes >
            .replaceAll(RegExp(r'^\s*>\s+', multiLine: true), '')
            // Normalize multiple newlines
            .replaceAll(RegExp(r'\n\s*\n'), '\n')
            // Normalize multiple spaces
            .replaceAll(RegExp(r'[ \t]+'), ' ')
            .trim();

        await Share.share(
          textContent,
          subject: localizations.audioAnalysisResults,
        );
      } else {
        if (context.mounted) {
          context.showSnackBar(
            localizations.noAnalysisContentToShare,
            isError: true,
          );
        }
      }
    } catch (e) {
      LoggerService.error('Failed to share analysis text', e);
      if (context.mounted) {
        context.showSnackBar(
          localizations.failedToShareAnalysisText(e.toString()),
          isError: true,
        );
      }
    }
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
