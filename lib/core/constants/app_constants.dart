/// Central brand, marketing, and store configuration for RememberLast.
///
/// Update store / privacy URLs here once listings are live. Until then,
/// placeholders mark values that are not yet known.
abstract final class AppConstants {
  /// First half of the two-tone wordmark (ambient text color).
  static const brandPrefix = 'Remember';

  /// Second half of the two-tone wordmark (brand primary).
  static const brandSuffix = 'Last';

  /// Full display name used in titles, share subjects, and copy.
  static const appName = '$brandPrefix$brandSuffix';

  /// Light (and current default) app logo mark asset.
  /// Use for both themes until a dedicated dark logo ships.
  static const appLogoLight = 'assets/images/app_logo_light.png';

  /// Short tagline for About / marketing.
  static const tagline =
      'Offline-first Last Done Tracker — remember when you last did anything.';

  /// Footer / About label, e.g. `RememberLast v1.0.0 (1)`.
  static String versionLabel({
    required String version,
    required String buildNumber,
  }) => '$appName v$version ($buildNumber)';

  // --- URLs (replace placeholders when available) ---

  /// Hosted privacy policy. In-app policy lives at Settings → Privacy policy.
  static const privacyPolicyUrl =
      'https://example.com/remember-last/privacy'; // TODO: replace

  /// Apple App Store listing.
  static const appStoreUrl =
      'https://apps.apple.com/app/idXXXXXXXXX'; // TODO: replace

  /// Google Play Store listing.
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.example.remember_last'; // TODO: replace

  /// Contact Us email
  static const contactUsEmail = 'dr.usman7860@gmail.com';
}
