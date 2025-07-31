import 'package:flutter/material.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/services/storage_service.dart';
import 'package:vocario/core/utils/context_extensions.dart';
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return SettingsCard(
      icon: Icons.key,
      iconColor: primaryColor,
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
                  color: primaryColor,
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
                Icon(Icons.open_in_new, color: primaryColor, size: 16),
                const SizedBox(width: 8),
                Text(
                  localizations.getApiKey,
                  style: TextStyle(
                    color: primaryColor,
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
    final localizations = AppLocalizations.of(context)!;
    final apiKey = controller.text.trim();
    
    if (apiKey.isEmpty) {
      context.showSnackBar(localizations.pleaseEnterApiKey, isError: true);
      return;
    }

    try {
      await StorageService.saveApiKey(apiKey);
      
      if (context.mounted) {
        context.showSnackBar(localizations.apiKeySavedSuccessfully);
      }
      
      onApiKeySaved?.call();
    } catch (e) {
      if (context.mounted) {
        context.showSnackBar(
          '${localizations.failedToSaveApiKey}: $e',
          isError: true,
        );
      }
    }
  }
}