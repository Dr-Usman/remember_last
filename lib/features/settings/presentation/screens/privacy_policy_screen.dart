import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Last updated: July 2026', style: theme.textTheme.labelMedium),
          const SizedBox(height: 16),
          _Section(
            title: 'Your data stays on your device',
            body:
                '${AppConstants.appName} stores all your activities and logs locally on your device. We do not collect, transmit, or store any of your personal data on external servers.',
          ),
          _Section(
            title: 'No account required',
            body:
                'There is no sign-up, login, or user account. The app works entirely offline without an internet connection.',
          ),
          _Section(
            title: 'No analytics or tracking',
            body:
                'We do not use analytics, advertising SDKs, or any third-party tracking. Your usage patterns are never monitored or shared.',
          ),
          _Section(
            title: 'Backup & export',
            body:
                'When you export a backup, the JSON file is created on your device and shared through your chosen app (email, cloud storage, etc.). We have no access to exported files.',
          ),
          _Section(
            title: 'Data deletion',
            body:
                'You can delete individual activities, log entries, or all data by uninstalling the app. Deleted data cannot be recovered unless you have a backup.',
          ),
          _Section(
            title: 'Contact',
            body:
                'If you have questions about this privacy policy, please contact the app developer through the app store listing.',
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(body, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
