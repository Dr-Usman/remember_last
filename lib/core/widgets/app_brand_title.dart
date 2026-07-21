import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Two-tone [AppConstants.appName] wordmark — prefix uses ambient text color,
/// suffix uses the brand primary.
class AppBrandTitle extends StatelessWidget {
  const AppBrandTitle({super.key, this.style, this.textAlign});

  /// Base style for both spans (weight, size, letterSpacing). Color is applied
  /// per span; only non-color properties from [style] are shared.
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base =
        (style ?? theme.textTheme.titleLarge)?.copyWith(
          fontWeight: style?.fontWeight ?? FontWeight.w700,
          letterSpacing: style?.letterSpacing ?? -0.3,
        ) ??
        const TextStyle(fontWeight: FontWeight.w700, letterSpacing: -0.3);

    final prefixColor = base.color ?? theme.colorScheme.onSurface;
    final suffixColor = theme.colorScheme.primary;

    return Text.rich(
      TextSpan(
        style: base,
        children: [
          TextSpan(
            text: AppConstants.brandPrefix,
            style: TextStyle(color: prefixColor),
          ),
          TextSpan(
            text: AppConstants.brandSuffix,
            style: TextStyle(color: suffixColor),
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
