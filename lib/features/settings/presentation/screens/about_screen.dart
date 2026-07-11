import 'package:flutter/material.dart';

import 'settings_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Icon(Icons.event_available_rounded, size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            'RememberLast',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          Text(
            'Version ${SettingsScreen.appVersion}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            'RememberLast is a simple, offline-first app that helps you track when you last did anything — water plants, wash your car, call family, and more.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'No streaks. No pressure. Just a clear answer to "when did I last do that?"',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Text('Features', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          const _Bullet('Track unlimited activities'),
          const _Bullet('See time elapsed since last done'),
          const _Bullet('Optional reminders with due status'),
          const _Bullet('Full history with custom entries'),
          const _Bullet('100% offline — your data stays on your device'),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
