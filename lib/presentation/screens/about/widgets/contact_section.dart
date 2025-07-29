import 'package:flutter/material.dart';
import 'package:vocario/presentation/screens/about/models/about_data.dart';
import 'package:vocario/presentation/screens/about/widgets/contact_item.dart';

class ContactSection extends StatelessWidget {
  final AboutData aboutData;

  const ContactSection({
    super.key,
    required this.aboutData,
  });

  @override
  Widget build(BuildContext context) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contact Us',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ContactItem(
          icon: Icons.web,
          title: 'Website',
          subtitle: aboutData.websiteUrl.replaceFirst('https://', ''),
          url: aboutData.websiteUrl,
        ),
        ContactItem(
          icon: Icons.email,
          title: 'Email',
          subtitle: aboutData.email,
          url: 'mailto:${aboutData.email}',
        ),
      ],
    );
  }
}