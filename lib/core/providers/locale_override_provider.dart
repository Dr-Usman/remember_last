import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/shared_prefs_service.dart';
import '../../l10n/app_locales.dart';

/// Persisted locale override (`null` follows the device locale).
final localeOverrideProvider =
    StateNotifierProvider<LocaleOverrideNotifier, Locale?>((ref) {
      return LocaleOverrideNotifier(ref.watch(sharedPrefsServiceProvider));
    });

class LocaleOverrideNotifier extends StateNotifier<Locale?> {
  LocaleOverrideNotifier(this._prefs) : super(null) {
    _load();
  }

  final SharedPrefsService _prefs;

  Future<void> _load() async {
    state = AppLocales.parse(await _prefs.getString(PrefsKeys.locale));
  }

  Future<void> setLocale(Locale? locale) async {
    state = locale;
    if (locale == null) {
      await _prefs.setString(PrefsKeys.locale, PrefsLocale.system);
    } else {
      await _prefs.setString(PrefsKeys.locale, locale.languageCode);
    }
  }
}
