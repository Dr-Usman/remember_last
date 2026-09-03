import 'package:flutter/material.dart';
import 'package:remember_last/l10n/app_localizations.dart';

/// Test wrapper that provides generated localizations delegates.
Widget wrapApp(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  );
}
