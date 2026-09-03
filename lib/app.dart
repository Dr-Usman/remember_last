import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bootstrap/seed_data.dart';
import 'core/constants/app_constants.dart';
import 'core/database/database_provider.dart';
import 'core/providers/locale_override_provider.dart';
import 'core/providers/theme_mode_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/analytics_consent_host.dart';
import 'l10n/app_localizations.dart';

class RememberLastApp extends ConsumerStatefulWidget {
  const RememberLastApp({super.key});

  @override
  ConsumerState<RememberLastApp> createState() => _RememberLastAppState();
}

class _RememberLastAppState extends ConsumerState<RememberLastApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await seedDatabaseIfEmpty(ref);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(databaseProvider);
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final localeOverride = ref.watch(localeOverrideProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: localeOverride,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: router,
      builder: (context, child) {
        return AnalyticsConsentHost(child: child ?? const SizedBox.shrink());
      },
    );
  }
}
