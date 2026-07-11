import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/activity_status.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(status.emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
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
