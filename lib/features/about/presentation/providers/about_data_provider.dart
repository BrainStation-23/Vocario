import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocario/core/l10n/app_localizations.dart';
import 'package:vocario/features/about/data/models/about_data.dart';

part 'about_data_provider.g.dart';

@riverpod
AboutData aboutData(Ref ref, BuildContext context) {
  final localizations = AppLocalizations.of(context)!;
  
  return AboutData(
    companyName: localizations.companyName,
    companyTagline: localizations.companyTagline,
    bannerImagePath: 'assets/images/brain_station_23_banner.jpg',
    logoImagePath: 'assets/images/brain_station_23_logo.png',
    mission: localizations.missionContent,
    vision: localizations.visionContent,
    appPurpose: localizations.appPurposeContent,
    websiteUrl: 'https://brainstation-23.com',
    email: 'info@brainstation-23.com',
    copyright: localizations.copyright,
    ourMissionTitle: localizations.ourMission,
    ourVisionTitle: localizations.ourVision,
    whyWeBuildVocarioTitle: localizations.whyWeBuildVocario,
  );
}