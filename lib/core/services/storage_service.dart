import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vocario/core/constants/app_constants.dart';
import 'package:vocario/core/services/logger_service.dart';

class StorageService {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Save string value
  static Future<void> saveString(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      LoggerService.debug('Saved string to storage: $key');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to save string to storage: $key', e, stackTrace);
      rethrow;
    }
  }

  // Get string value
  static Future<String?> getString(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      LoggerService.debug('Retrieved string from storage: $key');
      return value;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get string from storage: $key', e, stackTrace);
      return null;
    }
  }

  // Save boolean value
  static Future<void> saveBool(String key, bool value) async {
    await saveString(key, value.toString());
  }

  // Get boolean value
  static Future<bool?> getBool(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return value.toLowerCase() == 'true';
  }

  // Save integer value
  static Future<void> saveInt(String key, int value) async {
    await saveString(key, value.toString());
  }

  // Get integer value
  static Future<int?> getInt(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return int.tryParse(value);
  }

  // Save double value
  static Future<void> saveDouble(String key, double value) async {
    await saveString(key, value.toString());
  }

  // Get double value
  static Future<double?> getDouble(String key) async {
    final value = await getString(key);
    if (value == null) return null;
    return double.tryParse(value);
  }

  // Remove value
  static Future<void> remove(String key) async {
    try {
      await _secureStorage.delete(key: key);
      LoggerService.debug('Removed from storage: $key');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to remove from storage: $key', e, stackTrace);
      rethrow;
    }
  }

  // Clear all storage
  static Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
      LoggerService.info('Cleared all storage');
    } catch (e, stackTrace) {
      LoggerService.error('Failed to clear all storage', e, stackTrace);
      rethrow;
    }
  }

  // Check if key exists
  static Future<bool> containsKey(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      return value != null;
    } catch (e, stackTrace) {
      LoggerService.error('Failed to check key existence: $key', e, stackTrace);
      return false;
    }
  }

  // Get all keys
  static Future<Set<String>> getAllKeys() async {
    try {
      final all = await _secureStorage.readAll();
      return all.keys.toSet();
    } catch (e, stackTrace) {
      LoggerService.error('Failed to get all keys', e, stackTrace);
      return <String>{};
    }
  }

  // User-specific storage methods
  static Future<void> saveUserToken(String token) async {
    await saveString(AppConstants.userTokenKey, token);
  }

  static Future<String?> getUserToken() async {
    return await getString(AppConstants.userTokenKey);
  }

  static Future<void> removeUserToken() async {
    await remove(AppConstants.userTokenKey);
  }

  static Future<bool> isUserLoggedIn() async {
    final token = await getUserToken();
    return token != null && token.isNotEmpty;
  }

  // Theme storage methods
  static Future<void> saveThemeMode(String themeMode) async {
    await saveString(AppConstants.themeKey, themeMode);
  }

  static Future<String?> getThemeMode() async {
    return await getString(AppConstants.themeKey);
  }

  // Language storage methods
  static Future<void> saveLanguage(String language) async {
    await saveString(AppConstants.languageKey, language);
  }

  static Future<String?> getLanguage() async {
    return await getString(AppConstants.languageKey);
  }

  // User preferences storage
  static Future<void> saveUserPreferences(String preferences) async {
    await saveString(AppConstants.userPreferencesKey, preferences);
  }

  static Future<String?> getUserPreferences() async {
    return await getString(AppConstants.userPreferencesKey);
  }

  // API key storage methods
  static Future<void> saveApiKey(String apiKey) async {
    await saveString(AppConstants.apiKeyKey, apiKey);
  }

  static Future<String?> getApiKey() async {
    return await getString(AppConstants.apiKeyKey);
  }

  static Future<void> removeApiKey() async {
    await remove(AppConstants.apiKeyKey);
  }

  static Future<bool> hasApiKey() async {
    return await containsKey(AppConstants.apiKeyKey);
  }
}