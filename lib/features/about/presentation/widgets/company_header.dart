import 'package:flutter/material.dart';
import 'package:vocario/features/about/data/models/about_data.dart';

class CompanyHeader extends StatelessWidget {
  final AboutData aboutData;

  const CompanyHeader({
    super.key,
    required this.aboutData,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Center(
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              aboutData.bannerImagePath,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 16),
          Image.asset(
            aboutData.logoImagePath,
            height: 80,
            errorBuilder: (context, error, stackTrace) {
              return Text(
                aboutData.companyName,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            aboutData.companyTagline,
            style: TextStyle(
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}