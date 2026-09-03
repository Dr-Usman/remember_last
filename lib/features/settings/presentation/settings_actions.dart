import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../l10n/app_localizations.dart';

/// External About-section actions (share, rate, contact, developer page).
class SettingsActions {
  const SettingsActions();

  static bool get canShareApp => storeListingUrl != null;

  static bool get canRateApp => storeListingUrl != null;

  static bool get canShowDeveloperPage =>
      AppConstants.isUsableUrl(AppConstants.developerPageUrl);

  static String? get storeListingUrl => resolveStoreListingUrl(
    isWeb: kIsWeb,
    isAndroid: !kIsWeb && Platform.isAndroid,
    isIOS: !kIsWeb && Platform.isIOS,
  );

  Future<void> shareApp(BuildContext context) async {
    final storeUrl = storeListingUrl;
    if (storeUrl == null) return;

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: '${AppConstants.tagline}\n\n$storeUrl',
          subject: AppConstants.appName,
        ),
      );
    } catch (_) {
      if (context.mounted) {
        _showSnackBar(context, AppLocalizations.of(context).couldNotShareApp);
      }
    }
  }

  Future<void> rateApp(BuildContext context) async {
    final storeUrl = storeListingUrl;
    if (storeUrl == null) return;

    await _launchExternalUrl(
      context,
      Uri.parse(storeUrl),
      failureMessage: AppLocalizations.of(context).couldNotOpenAppStore,
    );
  }

  Future<void> contactUs(BuildContext context) async {
    await _launchExternalUrl(
      context,
      buildContactMailtoUri(
        email: AppConstants.contactUsEmail,
        subject: AppConstants.contactFeedbackSubject,
      ),
      failureMessage: AppLocalizations.of(context).couldNotOpenEmail,
    );
  }

  Future<void> openDeveloperPage(BuildContext context) async {
    if (!canShowDeveloperPage) return;
    await _launchExternalUrl(
      context,
      Uri.parse(AppConstants.developerPageUrl),
      failureMessage: AppLocalizations.of(context).couldNotOpenDeveloperPage,
    );
  }

  Future<void> _launchExternalUrl(
    BuildContext context,
    Uri uri, {
    required String failureMessage,
  }) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        _showSnackBar(context, failureMessage);
      }
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

@visibleForTesting
String? resolveStoreListingUrl({
  required bool isWeb,
  required bool isAndroid,
  required bool isIOS,
}) {
  if (isWeb) return null;
  if (isAndroid) {
    return AppConstants.isUsableUrl(AppConstants.playStoreUrl)
        ? AppConstants.playStoreUrl
        : null;
  }
  if (isIOS) {
    return AppConstants.isUsableUrl(AppConstants.appStoreUrl)
        ? AppConstants.appStoreUrl
        : null;
  }
  return null;
}

/// Builds a mailto URI with spaces encoded as `%20` (not `+`).
///
/// Some mail apps leave `+` literal in the subject when using
/// [Uri.queryParameters], which application/x-www-form-urlencoded uses.
@visibleForTesting
Uri buildContactMailtoUri({required String email, required String subject}) {
  return Uri(
    scheme: 'mailto',
    path: email,
    query: 'subject=${Uri.encodeComponent(subject)}',
  );
}
