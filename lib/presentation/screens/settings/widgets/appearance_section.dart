import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/providers/app_providers.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'settings_card.dart';

class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final localizations = AppLocalizations.of(context)!;

    return SettingsCard(
      icon: isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
      iconColor: isDarkMode
          ? Theme.of(context).colorScheme.primary
          : Colors.orange,
      title: localizations.appearance,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localizations.darkMode,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              ref
                  .read(themeModeNotifierProvider.notifier)
                  .setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
            },
          ),
        ],
      ),
    );
  }
}
