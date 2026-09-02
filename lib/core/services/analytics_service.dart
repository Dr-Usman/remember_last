import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

import '../analytics/analytics_constants.dart';
import '../analytics/analytics_events.dart';
import 'shared_prefs_service.dart';

/// Consent-gated Mixpanel wrapper. Initializes only after the user opts in.
class AnalyticsService {
  AnalyticsService(this._prefs);

  final SharedPrefsService _prefs;
  Mixpanel? _mixpanel;

  static bool get isSupported {
    if (kIsWeb) return true;
    return !kIsWeb &&
        (AnalyticsEvents.platformName == 'android' ||
            AnalyticsEvents.platformName == 'ios' ||
            AnalyticsEvents.platformName == 'macos');
  }

  /// `null` when consent has not been requested yet.
  Future<bool?> getConsentStatus() async {
    final value = await _prefs.getString(PrefsKeys.analyticsConsent);
    if (value == null) return null;
    return value == PrefsKeys.analyticsConsentGranted;
  }

  Future<void> restoreConsent({String? appVersion}) async {
    final consent = await getConsentStatus();
    if (consent == true) {
      await _optIn(appVersion: appVersion, persist: false);
    }
  }

  Future<void> optIn({String? appVersion}) => _optIn(appVersion: appVersion);

  Future<void> optOut() async {
    await _prefs.setString(
      PrefsKeys.analyticsConsent,
      PrefsKeys.analyticsConsentDenied,
    );
    _mixpanel?.optOutTracking();
  }

  Future<void> trackScreenViewed(String screenName) {
    return track(
      AnalyticsConstants.screenViewed,
      AnalyticsEvents.screenViewed(screenName: screenName),
    );
  }

  Future<void> trackOccurrenceLogged({
    required String source,
    required bool hasNote,
    required DateTime doneAt,
  }) {
    return track(
      AnalyticsConstants.occurrenceLogged,
      AnalyticsEvents.occurrenceLogged(
        source: source,
        hasNote: hasNote,
        isBackdated: AnalyticsEvents.isBackdatedEntry(doneAt),
      ),
    );
  }

  Future<void> track(String event, Map<String, dynamic> properties) async {
    if (!isSupported || _mixpanel == null) return;

    final optedOut = await _mixpanel!.hasOptedOutTracking();
    if (optedOut != false) return;

    await _mixpanel!.track(event, properties: properties);
  }

  Future<void> _optIn({String? appVersion, bool persist = true}) async {
    if (persist) {
      await _prefs.setString(
        PrefsKeys.analyticsConsent,
        PrefsKeys.analyticsConsentGranted,
      );
    }

    if (!isSupported) return;

    await _ensureInitialized();
    _mixpanel!.optInTracking();
    await _mixpanel!.registerSuperProperties({
      'platform': AnalyticsEvents.platformName,
      'app_version': ?appVersion,
    });
  }

  Future<void> _ensureInitialized() async {
    if (_mixpanel != null) return;

    _mixpanel = await Mixpanel.init(
      AnalyticsConstants.projectToken,
      trackAutomaticEvents: false,
      optOutTrackingDefault: true,
    );
  }
}
