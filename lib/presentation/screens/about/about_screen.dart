import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocario/presentation/screens/about/providers/about_data_provider.dart';
import 'package:vocario/presentation/screens/about/widgets/company_header.dart';
import 'package:vocario/presentation/screens/about/widgets/about_section.dart';
import 'package:vocario/presentation/screens/about/widgets/contact_section.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aboutData = ref.watch(aboutDataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CompanyHeader(aboutData: aboutData),
            const SizedBox(height: 32),
            
            AboutSection(
              title: 'Our Mission',
              content: aboutData.mission,
              icon: Icons.flag,
            ),
            
            AboutSection(
              title: 'Our Vision',
              content: aboutData.vision,
              icon: Icons.visibility,
            ),
            
            AboutSection(
              title: 'Why We Built Vocario',
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