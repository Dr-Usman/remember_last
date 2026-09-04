import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../l10n/app_localizations.dart';

const _privacyPolicyAsset = 'docs/privacy_policy.md';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.privacyPolicy),
        actions: [
          IconButton(
            tooltip: l10n.openOnline,
            icon: const Icon(Icons.open_in_new),
            onPressed: () => _openOnlinePolicy(context),
          ),
        ],
      ),
      body: FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(_privacyPolicyAsset),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.privacyUnableToLoad,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final theme = Theme.of(context);
          return Markdown(
            data: snapshot.data!,
            padding: const EdgeInsets.all(24),
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              h1: theme.textTheme.headlineSmall,
              h2: theme.textTheme.titleMedium,
              p: theme.textTheme.bodyMedium,
              listBullet: theme.textTheme.bodyMedium,
              strong: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            onTapLink: (text, href, title) {
              if (href == null) return;
              launchUrl(Uri.parse(href));
            },
          );
        },
      ),
    );
  }

  Future<void> _openOnlinePolicy(BuildContext context) async {
    final uri = Uri.parse(AppConstants.privacyPolicyUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).couldNotOpenPrivacyUrl),
        ),
      );
    }
  }
}
