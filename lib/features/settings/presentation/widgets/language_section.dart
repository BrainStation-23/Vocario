import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/providers/language_provider.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'settings_card.dart';

class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageNotifierProvider);
    final localizations = AppLocalizations.of(context)!;
    
    return SettingsCard(
      icon: Icons.language,
      iconColor: Colors.blue,
      title: localizations.language,
      child: DropdownButtonFormField<String>(
        value: currentLocale.languageCode,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        items: [
          DropdownMenuItem<String>(
            value: 'en',
            child: Text(localizations.english),
          ),
          DropdownMenuItem<String>(
            value: 'bn',
            child: Text(localizations.bengali),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            ref.read(languageNotifierProvider.notifier).setLanguage(Locale(value));
          }
        },
      ),
    );
  }
}