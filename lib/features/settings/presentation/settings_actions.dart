import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';

/// External About-section actions (share, rate, contact, developer page).
class SettingsActions {
  const SettingsActions();

  static bool get canShareApp => storeListingUrl != null;

  static bool get canRateApp =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

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
        _showSnackBar(context, 'Could not share app');
      }
    }
  }

  Future<void> rateApp(BuildContext context) async {
    if (!canRateApp) return;

    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) {
        await review.requestReview();
        return;
      }
    } catch (_) {
      // Fall through to store listing.
    }

    if (!context.mounted) return;

    final storeUrl = storeListingUrl;
    if (storeUrl != null) {
      await _launchExternalUrl(
        context,
        Uri.parse(storeUrl),
        failureMessage: 'Could not open app store',
      );
    } else if (context.mounted) {
      _showSnackBar(context, 'App store is not available');
    }
  }

  Future<void> contactUs(BuildContext context) async {
    await _launchExternalUrl(
      context,
      buildContactMailtoUri(
        email: AppConstants.contactUsEmail,
        subject: AppConstants.contactFeedbackSubject,
      ),
      failureMessage: 'Could not open email app',
    );
  }

  Future<void> openDeveloperPage(BuildContext context) async {
    if (!canShowDeveloperPage) return;
    await _launchExternalUrl(
      context,
      Uri.parse(AppConstants.developerPageUrl),
      failureMessage: 'Could not open developer page',
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
