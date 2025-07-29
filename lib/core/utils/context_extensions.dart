import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocario/core/constants/app_constants.dart';
import 'package:vocario/core/theme/app_colors.dart';

extension ContextExtensions on BuildContext {
  Future<void> launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  void showSnackBar(String msg, {bool isError = false, VoidCallback? onClick}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError 
            ? Theme.of(this).colorScheme.error 
            : Theme.of(this).extension<AppColors>()!.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        action: onClick != null 
            ? SnackBarAction(
                label: 'Dismiss',
                textColor: isError
                    ? Theme.of(this).colorScheme.onError
                    : Colors.white,
                onPressed: onClick,
              )
            : null,
      ),
    );
  }

  void hideSnackBar() {
    ScaffoldMessenger.of(this).hideCurrentSnackBar();
  }
}