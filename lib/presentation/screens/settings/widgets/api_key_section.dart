import 'package:flutter/material.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'settings_card.dart';
import 'custom_text_field.dart';
import 'info_box.dart';

class ApiKeySection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onLaunchURL;

  const ApiKeySection({super.key, required this.controller, required this.onLaunchURL});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return SettingsCard(
      icon: Icons.key,
      iconColor: appColors.gradientStart,
      title: localizations.geminiApiKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: controller,
            hintText: localizations.apiKeyHint,
            obscureText: true,
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => onLaunchURL('https://aistudio.google.com/app/apikey'),
            child: Row(
              children: [
                Icon(Icons.open_in_new, color: appColors.gradientStart, size: 16),
                const SizedBox(width: 8),
                Text(
                  localizations.getApiKey,
                  style: TextStyle(
                    color: appColors.gradientStart,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          InfoBox(
            text: localizations.apiKeyInfo,
          ),
        ],
      ),
    );
  }
}