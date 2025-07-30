import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vocario/features/about/data/models/about_data.dart';

part 'about_data_provider.g.dart';

@riverpod
AboutData aboutData(Ref ref) {
  return const AboutData(
    companyName: 'Brain Station 23',
    companyTagline: 'Leading Software Development & IT Service Provider',
    bannerImagePath: 'assets/images/brain_station_23_banner.jpg',
    logoImagePath: 'assets/images/brain_station_23_logo.png',
    mission: 'Your trusted companion for digital leadership by empowering people to achieve more with less',
    vision: 'To be the fastest digital transformation and innovation partner by engaging global talents thus creating positive impact.',
    appPurpose: 'We developed Vocario as part of our commitment to serve our country by providing innovative solutions that help people communicate more effectively and efficiently through voice technology.',
    websiteUrl: 'https://brainstation-23.com',
    email: 'info@brainstation-23.com',
    copyright: '© 2025 Brain Station 23. All rights reserved.',
  );
}