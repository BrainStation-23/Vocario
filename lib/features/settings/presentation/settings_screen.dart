import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/core/utils/context_extensions.dart';
import 'package:vocario/core/services/storage_service.dart';
import 'package:vocario/features/settings/presentation/widgets/settings_widgets.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.settings),
      ),
      body: SingleChildScrollView(
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
                  // EmailSection(controller: _emailController),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}