import 'package:flutter/material.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'settings_card.dart';
import 'custom_text_field.dart';

class EmailSection extends StatelessWidget {
  final TextEditingController controller;

  const EmailSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appColors = Theme.of(context).extension<AppColors>()!;
    
    return SettingsCard(
      icon: Icons.email_outlined,
      iconColor: Colors.green,
      title: localizations.emailAddress,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextField(
            controller: controller,
            hintText: localizations.emailHint,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          Text(
            localizations.emailDescription,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}