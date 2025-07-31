import 'package:flutter/material.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/features/about/data/models/about_data.dart';
import 'package:vocario/features/about/presentation/widgets/contact_item.dart';

class ContactSection extends StatelessWidget {
  final AboutData aboutData;

  const ContactSection({
    super.key,
    required this.aboutData,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.contactUs,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ContactItem(
          icon: Icons.web,
          title: localizations.website,
          subtitle: aboutData.websiteUrl.replaceFirst('https://', ''),
          url: aboutData.websiteUrl,
        ),
        ContactItem(
          icon: Icons.email,
          title: localizations.email,
          subtitle: aboutData.email,
          url: 'mailto:${aboutData.email}',
        ),
      ],
    );
  }
}