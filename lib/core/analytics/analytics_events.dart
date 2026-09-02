import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

/// Typed property maps for Mixpanel events.
abstract final class AnalyticsEvents {
  static Map<String, dynamic> screenViewed({required String screenName}) => {
    'screen_name': screenName,
    'platform': platformName,
  };

  static Map<String, dynamic> occurrenceLogged({
    required String source,
    required bool hasNote,
    required bool isBackdated,
  }) => {
    'source': source,
    'has_note': hasNote,
    'is_backdated': isBackdated,
    'platform': platformName,
  };

  static String get platformName {
    if (kIsWeb) return 'web';
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }

  static bool isBackdatedEntry(DateTime doneAt) {
    return DateTime.now().difference(doneAt).inMinutes > 1;
  }
}
