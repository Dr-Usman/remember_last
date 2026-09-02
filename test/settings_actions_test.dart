import 'package:flutter_test/flutter_test.dart';
import 'package:remember_last/core/constants/app_constants.dart';
import 'package:remember_last/features/settings/presentation/settings_actions.dart';

void main() {
  group('AppConstants.isUsableUrl', () {
    test('returns false for empty string', () {
      expect(AppConstants.isUsableUrl(''), isFalse);
    });

    test('returns false for placeholder URLs', () {
      expect(AppConstants.isUsableUrl(AppConstants.appStoreUrl), isFalse);
    });

    test('returns true for real URLs', () {
      expect(AppConstants.isUsableUrl(AppConstants.playStoreUrl), isTrue);
      expect(AppConstants.isUsableUrl(AppConstants.developerPageUrl), isTrue);
    });
  });

  group('resolveStoreListingUrl', () {
    test('returns null on web', () {
      expect(
        resolveStoreListingUrl(isWeb: true, isAndroid: false, isIOS: false),
        isNull,
      );
    });

    test('returns Play Store URL on Android', () {
      expect(
        resolveStoreListingUrl(isWeb: false, isAndroid: true, isIOS: false),
        AppConstants.playStoreUrl,
      );
    });

    test('returns null on iOS when App Store URL is placeholder', () {
      expect(
        resolveStoreListingUrl(isWeb: false, isAndroid: false, isIOS: true),
        isNull,
      );
    });

    test('returns null on desktop', () {
      expect(
        resolveStoreListingUrl(isWeb: false, isAndroid: false, isIOS: false),
        isNull,
      );
    });
  });

  group('SettingsActions visibility', () {
    test('canShowDeveloperPage is true with real developer URL', () {
      expect(SettingsActions.canShowDeveloperPage, isTrue);
    });
  });

  group('buildContactMailtoUri', () {
    test('encodes subject spaces as %20 not +', () {
      final uri = buildContactMailtoUri(
        email: AppConstants.contactUsEmail,
        subject: AppConstants.contactFeedbackSubject,
      );

      expect(uri.scheme, 'mailto');
      expect(uri.path, AppConstants.contactUsEmail);
      expect(uri.query, 'subject=RememberLast%20feedback');
      expect(uri.toString(), isNot(contains('+')));
    });
  });
}
