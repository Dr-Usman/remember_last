import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/activity_status.dart';
import '../utils/l10n_labels.dart';
import '../../l10n/app_localizations.dart';

/// Small colored badge showing activity status.
class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    super.key,
    required this.status,
    this.compact = false,
  });

  final ActivityStatus status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _colorForStatus(status);
    if (compact) {
      return Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
    }
    final labelStyle = Theme.of(
      context,
    ).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w600);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            status.l10nLabel(AppLocalizations.of(context)),
            style: labelStyle,
          ),
        ],
      ),
    );
  }

  Color _colorForStatus(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.recent:
      case ActivityStatus.noReminder:
        return AppColors.recent;
      case ActivityStatus.dueSoon:
        return AppColors.dueSoon;
      case ActivityStatus.overdue:
        return AppColors.overdue;
      case ActivityStatus.neverLogged:
        return AppColors.neutral;
    }
  }
}

Color statusColor(ActivityStatus status) {
  switch (status) {
    case ActivityStatus.recent:
    case ActivityStatus.noReminder:
      return AppColors.recent;
    case ActivityStatus.dueSoon:
      return AppColors.dueSoon;
    case ActivityStatus.overdue:
      return AppColors.overdue;
    case ActivityStatus.neverLogged:
      return AppColors.neutral;
  }
}
