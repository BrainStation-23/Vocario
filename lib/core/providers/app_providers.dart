import 'package:flutter/material.dart';
import 'package:riverpod/riverpod.dart';
import 'package:vocario/core/services/storage_service.dart';
import 'package:vocario/core/services/logger_service.dart';
import 'package:vocario/features/audio_recorder/presentation/providers/audio_recorder_provider.dart';

// Theme Mode Provider
final themeModeNotifierProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    try {
      final savedTheme = await StorageService.getThemeMode();
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            state = ThemeMode.light;
            break;
          case 'dark':
            state = ThemeMode.dark;
            break;
          default:
            state = ThemeMode.system;
        }
      }
    } catch (e) {
      LoggerService.error('Failed to load theme mode', e);
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      state = themeMode;
      String themeString;
      switch (themeMode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      await StorageService.saveThemeMode(themeString);
      LoggerService.info('Theme mode changed to: $themeString');
    } catch (e) {
      LoggerService.error('Failed to save theme mode', e);
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newTheme);
  }
}

// Loading Provider
final loadingNotifierProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier();
});

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void setLoading(bool loading) {
    state = loading;
  }
}

// Error Provider
final errorNotifierProvider = StateNotifierProvider<ErrorNotifier, String?>((ref) {
  return ErrorNotifier();
});

class ErrorNotifier extends StateNotifier<String?> {
  ErrorNotifier() : super(null);

  void setError(String? error) {
    state = error;
  }

  void clearError() {
    state = null;
  }
}

// Connectivity Provider
final connectivityNotifierProvider = StateNotifierProvider<ConnectivityNotifier, bool>((ref) {
  return ConnectivityNotifier();
});

class ConnectivityNotifier extends StateNotifier<bool> {
  ConnectivityNotifier() : super(true);

  void setConnectivity(bool connected) {
    state = connected;
  }
}

// App Initialization Provider
final appInitializationProvider = FutureProvider<void>((ref) async {
  try {
    // Initialize core services
    LoggerService.info('App initialization completed');
  } catch (e) {
    LoggerService.error('App initialization failed', e);
    rethrow;
  }
});
