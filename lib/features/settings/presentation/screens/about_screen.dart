import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/package_info_provider.dart';
import '../../../../core/widgets/app_brand_title.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final versionLabel = ref
        .watch(packageInfoProvider)
        .when(
          data: (info) => AppConstants.versionLabel(
            version: info.version,
            buildNumber: info.buildNumber,
          ),
          loading: () => '${AppConstants.appName} …',
          error: (_, _) => AppConstants.appName,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: _AppLogoIcon()),
          const SizedBox(height: 16),
          AppBrandTitle(
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            versionLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Text(
            '${AppConstants.appName} is a simple, offline-first app that helps you '
            'track when you last did anything — water plants, wash your car, '
            'call family, and more.',
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
          const _Bullet('Track unlimited activities with optional reminders'),
          const _Bullet(
            'See time elapsed since last done, with Recent / Due soon / Overdue status',
          ),
          const _Bullet('Organize with custom categories'),
          const _Bullet('Full history with custom backdated entries'),
          const _Bullet('Insights with average intervals and charts'),
          const _Bullet('Light and dark brand themes (follows system)'),
          const _Bullet('JSON export/import backup'),
          const _Bullet('100% offline — your data stays on your device'),
        ],
      ),
    );
  }
}

/// Home-screen-style app icon for the About header:
/// elevated rounded-square plate with the logo mark clipped inside.
class _AppLogoIcon extends StatelessWidget {
  const _AppLogoIcon();

  static const double _size = 92;
  static const double _radius = 20;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 6,
      shadowColor: scheme.shadow.withValues(alpha: 0.35),
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(_radius),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: _size,
        height: _size,
        padding: const EdgeInsets.all(8),
        child: Image.asset(AppConstants.appLogoLight, fit: BoxFit.cover),
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
