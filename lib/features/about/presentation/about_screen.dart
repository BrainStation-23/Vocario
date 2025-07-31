import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/features/about/presentation/providers/about_data_provider.dart';
import 'package:vocario/features/about/presentation/widgets/company_header.dart';
import 'package:vocario/features/about/presentation/widgets/about_section.dart';
import 'package:vocario/features/about/presentation/widgets/contact_section.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutData = ref.watch(aboutDataProvider(context));
    final localizations = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.aboutUs),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompanyHeader(aboutData: aboutData),
            const SizedBox(height: 32),
            
            AboutSection(
              title: aboutData.ourMissionTitle,
              content: aboutData.mission,
              icon: Icons.flag,
            ),
            
            AboutSection(
              title: aboutData.ourVisionTitle,
              content: aboutData.vision,
              icon: Icons.visibility,
            ),
            
            AboutSection(
              title: aboutData.whyWeBuildVocarioTitle,
              content: aboutData.appPurpose,
              icon: Icons.mic,
            ),
            
            ContactSection(aboutData: aboutData),
            
            const SizedBox(height: 32),
            
            Center(
              child: Text(
                aboutData.copyright,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).disabledColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}