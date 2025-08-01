import 'package:flutter/material.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/services/storage_service.dart';
import 'package:vocario/core/utils/context_extensions.dart';
import 'settings_card.dart';
import 'info_box.dart';

class ApiKeySection extends StatefulWidget {
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
  State<ApiKeySection> createState() => _ApiKeySectionState();
}

class _ApiKeySectionState extends State<ApiKeySection> {
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

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
                child: TextField(
                   controller: widget.controller,
                   focusNode: _focusNode,
                   obscureText: true,
                   textInputAction: TextInputAction.done,
                   onSubmitted: (_) => _saveApiKey(context),
                  decoration: InputDecoration(
                    hintText: localizations.apiKeyHint,
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
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
            onTap: () => widget.onLaunchURL('https://aistudio.google.com/app/apikey'),
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
    final apiKey = widget.controller.text.trim();
    
    // Remove focus and close keyboard
     _focusNode.unfocus();
    
    if (apiKey.isEmpty) {
      context.showSnackBar(localizations.pleaseEnterApiKey, isError: true);
      return;
    }

    try {
      await StorageService.saveApiKey(apiKey);
      
      if (context.mounted) {
        context.showSnackBar(localizations.apiKeySavedSuccessfully);
      }
      
      widget.onApiKeySaved?.call();
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