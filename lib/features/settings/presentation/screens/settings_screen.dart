import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/analytics_provider.dart';
import '../../../../core/providers/package_info_provider.dart';
import '../../../../core/providers/theme_mode_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../backup/presentation/backup_actions.dart';
import '../widgets/settings_tile.dart';

/// Main settings hub for backup, categories, and app info.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool? _analyticsEnabled;
  bool _loadingAnalytics = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsConsent();
  }

  Future<void> _loadAnalyticsConsent() async {
    final consent = await ref.read(analyticsServiceProvider).getConsentStatus();
    if (!mounted) return;
    setState(() {
      _analyticsEnabled = consent ?? false;
      _loadingAnalytics = false;
    });
  }

  Future<void> _setAnalyticsEnabled(bool enabled) async {
    setState(() => _analyticsEnabled = enabled);

    final analytics = ref.read(analyticsServiceProvider);
    if (enabled) {
      final info = await ref.read(packageInfoProvider.future);
      await analytics.optIn(appVersion: info.version);
    } else {
      await analytics.optOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
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
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _SectionHeader(title: 'Appearance', theme: theme),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.brightness_auto_outlined, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_outlined, size: 18),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_outlined, size: 18),
                      ),
                    ],
                    selected: {themeMode},
                    onSelectionChanged: (selected) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(selected.single);
                    },
                  ),
                ),
                const Divider(height: 1),
                _SectionHeader(title: 'Organize', theme: theme),
                SettingsTile(
                  icon: Icons.category_outlined,
                  title: 'Manage categories',
                  subtitle: 'Add or remove activity categories',
                  showChevron: true,
                  onTap: () => context.push(AppRoutes.categories),
                ),
                const Divider(height: 1),
                _SectionHeader(title: 'Data', theme: theme),
                SettingsTile(
                  icon: Icons.upload_outlined,
                  title: 'Export backup',
                  subtitle: 'Save your data as JSON',
                  onTap: () => BackupActions(ref).exportBackup(context),
                ),
                SettingsTile(
                  icon: Icons.download_outlined,
                  title: 'Import backup',
                  subtitle: 'Restore from a JSON file',
                  onTap: () => BackupActions(ref).importBackup(context),
                ),
                const Divider(height: 1),
                _SectionHeader(title: 'Privacy', theme: theme),
                SwitchListTile(
                  secondary: const Icon(Icons.analytics_outlined),
                  title: const Text('Usage analytics'),
                  subtitle: const Text(
                    'Share anonymous screen and feature usage via Mixpanel',
                  ),
                  value: _analyticsEnabled ?? false,
                  onChanged: _loadingAnalytics
                      ? null
                      : (value) => _setAnalyticsEnabled(value),
                ),
                const Divider(height: 1),
                _SectionHeader(title: 'About', theme: theme),
                SettingsTile(
                  icon: Icons.info_outline,
                  title: 'About ${AppConstants.appName}',
                  showChevron: true,
                  onTap: () => context.push(AppRoutes.about),
                ),
                SettingsTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy policy',
                  showChevron: true,
                  onTap: () => context.push(AppRoutes.privacy),
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
