import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/analytics_provider.dart';
import '../providers/package_info_provider.dart';
import '../router/app_router.dart';
import 'analytics_consent_dialog.dart';

/// Runs analytics consent flow once the root navigator is available.
class AnalyticsConsentHost extends ConsumerStatefulWidget {
  const AnalyticsConsentHost({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AnalyticsConsentHost> createState() =>
      _AnalyticsConsentHostState();
}

class _AnalyticsConsentHostState extends ConsumerState<AnalyticsConsentHost> {
  var _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleConsent());
  }

  Future<void> _handleConsent() async {
    if (_started) return;
    _started = true;

    final analytics = ref.read(analyticsServiceProvider);
    final consent = await analytics.getConsentStatus();

    if (!mounted) return;

    if (consent == null) {
      final dialogContext = rootNavigatorKey.currentContext;
      if (dialogContext == null || !dialogContext.mounted) return;

      final accepted = await showAnalyticsConsentDialog(dialogContext);
      if (!mounted || accepted == null) return;

      if (accepted) {
        final appVersion = await _appVersionLabel();
        await analytics.optIn(appVersion: appVersion);
      } else {
        await analytics.optOut();
      }
      return;
    }

    if (consent) {
      final appVersion = await _appVersionLabel();
      await analytics.restoreConsent(appVersion: appVersion);
    }
  }

  Future<String?> _appVersionLabel() async {
    final info = await ref.read(packageInfoProvider.future);
    return info.version;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
