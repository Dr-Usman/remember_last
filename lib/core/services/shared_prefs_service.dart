import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences] for typed get/set helpers.
class SharedPrefsService {
  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool?> getBool(String key) async => (await _prefs).getBool(key);

  Future<bool> setBool(String key, bool value) async =>
      (await _prefs).setBool(key, value);

  Future<String?> getString(String key) async => (await _prefs).getString(key);

  Future<bool> setString(String key, String value) async =>
      (await _prefs).setString(key, value);

  Future<bool> remove(String key) async => (await _prefs).remove(key);
}

/// Preference keys used across the app.
abstract final class PrefsKeys {
  static const themeMode = 'theme_mode';
  static const hasSeededSamples = 'has_seeded_samples';
  static const analyticsConsent = 'analytics_consent';
  static const analyticsConsentGranted = 'granted';
  static const analyticsConsentDenied = 'denied';
  static const locale = 'locale';
}

final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  return SharedPrefsService();
});
