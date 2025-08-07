import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/utils/context_extensions.dart';
import 'package:vocario/core/services/storage_service.dart';
import 'package:vocario/core/theme/app_colors.dart';
import 'package:vocario/core/theme/app_text_styles.dart';
import 'package:vocario/features/settings/presentation/widgets/settings_widgets.dart';
import 'package:vocario/features/settings/presentation/widgets/version_section.dart';
import 'package:vocario/core/routing/app_router.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedApiKey();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedApiKey() async {
    final savedApiKey = await StorageService.getApiKey();
    if (savedApiKey != null && mounted) {
      _apiKeyController.text = savedApiKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final appColors = Theme.of(context).extension<AppColors>()!;
    final appTextStyles = Theme.of(context).extension<AppTextStyles>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    child: Column(
                      children: [
                        const AppearanceSection(),
                        const SizedBox(height: 16),
                        const LanguageSection(),
                        const SizedBox(height: 16),
                        ApiKeySection(
                          controller: _apiKeyController,
                          onLaunchURL: context.launchURL,
                          onApiKeySaved: () {
                            // No op
                          },
                        ),
                        const SizedBox(height: 16),
                        const VersionSection(),
                        const SizedBox(height: 16),
                        // EmailSection(controller: _emailController),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.info_outline, size: 22),
                label: Text(
                  localizations.aboutUs,
                  style: appTextStyles.buttonText.copyWith(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: appColors.micButtonGradientStart,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  shadowColor: appColors.micButtonGradientStart.withValues(alpha: 0.2),
                ),
                onPressed: () async {
                  // Use GoRouter for navigation, and pop back to settings on return
                  await context.push(AppRouter.about);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}