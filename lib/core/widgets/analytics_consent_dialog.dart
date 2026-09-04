import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// First-launch dialog asking for optional analytics consent.
Future<bool?> showAnalyticsConsentDialog(BuildContext context) {
  final l10n = AppLocalizations.of(context);
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Text(l10n.analyticsConsentTitle),
      content: Text(l10n.analyticsConsentBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.decline),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.accept),
        ),
      ],
    ),
  );
}
