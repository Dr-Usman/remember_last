import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/locale_override_provider.dart';
import '../../../../l10n/app_locales.dart';
import '../../../../l10n/app_localizations.dart';
import 'settings_tile.dart';

/// Appearance tile that opens a locale picker (system default or override).
class LanguagePickerTile extends ConsumerWidget {
  const LanguagePickerTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final override = ref.watch(localeOverrideProvider);
    final subtitle = override == null
        ? l10n.languageSystemDefault
        : AppLocales.nativeName(override);

    return SettingsTile(
      icon: Icons.language,
      title: l10n.language,
      subtitle: subtitle,
      showChevron: true,
      onTap: () => _openPicker(context, ref, l10n, override),
    );
  }

  Future<void> _openPicker(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    Locale? current,
  ) async {
    final selected = await showDialog<Object>(
      context: context,
      builder: (context) {
        final groupValue = current == null
            ? PrefsLocale.system
            : current.languageCode;
        return AlertDialog(
          title: Text(l10n.language),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text(l10n.languageSystemDefault),
                  trailing: groupValue == PrefsLocale.system
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () => Navigator.pop(context, PrefsLocale.system),
                ),
                for (final locale in AppLocales.supported)
                  ListTile(
                    title: Text(AppLocales.nativeName(locale)),
                    trailing: groupValue == locale.languageCode
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.pop(context, locale.languageCode),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null) return;
    if (selected == PrefsLocale.system) {
      await ref.read(localeOverrideProvider.notifier).setLocale(null);
    } else if (selected is String) {
      await ref
          .read(localeOverrideProvider.notifier)
          .setLocale(AppLocales.parse(selected));
    }
  }
}
