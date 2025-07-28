import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:vocario/core/services/storage_service.dart';
import 'package:vocario/core/services/logger_service.dart';

// Language provider
final languageNotifierProvider = StateNotifierProvider<LanguageNotifier, Locale>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<Locale> {
  LanguageNotifier() : super(const Locale('en')) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final savedLanguage = await StorageService.getLanguage();
      if (savedLanguage != null) {
        state = Locale(savedLanguage);
      }
    } catch (e) {
      LoggerService.error('Failed to load language', e);
    }
  }

  Future<void> setLanguage(Locale locale) async {
    try {
      state = locale;
      await StorageService.saveLanguage(locale.languageCode);
      LoggerService.info('Language changed to: ${locale.languageCode}');
    } catch (e) {
      LoggerService.error('Failed to save language', e);
    }
  }
}