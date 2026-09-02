import 'package:flutter/material.dart';

/// First-launch dialog asking for optional analytics consent.
Future<bool?> showAnalyticsConsentDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: const Text('Help improve RememberLast?'),
      content: const Text(
        'You can optionally share anonymous usage analytics with Mixpanel '
        '(such as which screens you visit and when you log activities). '
        'We never send your activity titles, notes, or other personal content. '
        'You can change this anytime in Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Decline'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Accept'),
        ),
      ],
    ),
  );
}
