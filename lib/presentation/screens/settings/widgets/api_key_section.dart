import 'package:flutter/material.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/services/storage_service.dart';
import 'settings_card.dart';
import 'custom_text_field.dart';
import 'info_box.dart';

class ApiKeySection extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onLaunchURL;
  final VoidCallback? onApiKeySaved;

  const ApiKeySection({
    super.key, 
    required this.controller, 
    required this.onLaunchURL,
    this.onApiKeySaved,
  });

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
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: controller,
                  hintText: localizations.apiKeyHint,
                  obscureText: true,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _saveApiKey(context),
                icon: Icon(
                  Icons.save,
                  color: appColors.gradientStart,
                ),
                tooltip: 'Save API Key',
              ),
            ],
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

  Future<void> _saveApiKey(BuildContext context) async {
    final apiKey = controller.text.trim();
    
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an API key'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await StorageService.saveApiKey(apiKey);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      onApiKeySaved?.call();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save API key: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}