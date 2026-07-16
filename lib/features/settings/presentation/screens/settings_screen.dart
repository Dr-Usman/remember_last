import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/package_info_provider.dart';
import '../../../backup/presentation/backup_actions.dart';

/// Main settings hub for backup, categories, and app info.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final versionLabel = ref.watch(packageInfoProvider).when(
          data: (info) => AppConstants.versionLabel(
            version: info.version,
            buildNumber: info.buildNumber,
          ),
          loading: () => '${AppConstants.appName} …',
          error: (_, _) => AppConstants.appName,
        );

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _SectionHeader(title: 'Data', theme: theme),
                ListTile(
                  leading: const Icon(Icons.upload_outlined),
                  title: const Text('Export backup'),
                  subtitle: const Text('Save your data as JSON'),
                  onTap: () => BackupActions(ref).exportBackup(context),
                ),
                ListTile(
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Import backup'),
                  subtitle: const Text('Restore from a JSON file'),
                  onTap: () => BackupActions(ref).importBackup(context),
                ),
                const Divider(height: 1),
                _SectionHeader(title: 'Organize', theme: theme),
                ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: const Text('Manage categories'),
                  subtitle: const Text('Add or remove activity categories'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/categories'),
                ),
                const Divider(height: 1),
                _SectionHeader(title: 'About', theme: theme),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text('About ${AppConstants.appName}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/about'),
                ),
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy policy'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push('/settings/privacy'),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Text(
                versionLabel,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.theme});

  final String title;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
