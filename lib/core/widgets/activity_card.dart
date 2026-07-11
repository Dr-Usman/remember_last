import 'package:flutter/material.dart';

import '../../features/activities/domain/entities/activity.dart';
import '../theme/app_colors.dart';
import '../utils/activity_status.dart';
import '../utils/date_formatter.dart';
import 'status_indicator.dart';

/// Card displaying an activity summary on the home screen.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.item,
    required this.status,
    required this.onTap,
    required this.onQuickLog,
    this.elapsedNow,
  });

  final ActivityWithLastDone item;
  final ActivityStatus status;
  final VoidCallback onTap;
  final VoidCallback onQuickLog;
  final DateTime? elapsedNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final activity = item.activity;
    final lastDone = item.lastDoneAt;
    final accent = statusColor(status);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: scheme.surfaceContainerLow,
            border: Border.all(
              color: accent.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.shadow.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Row(
              children: [
                Container(width: 4, height: 108, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                activity.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            StatusIndicator(status: status, compact: true),
                          ],
                        ),
                        if (activity.category != null &&
                            activity.category!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          _CategoryChip(label: activity.category!),
                        ],
                        const SizedBox(height: 10),
                        if (lastDone != null)
                          Text(
                            DateFormatter.formatElapsed(lastDone, now: elapsedNow),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          )
                        else
                          Text(
                            'Never logged',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.neutral,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        if (lastDone != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            DateFormatter.formatAbsoluteDateTime(lastDone),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Material(
                    color: scheme.primaryContainer,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: onQuickLog,
                      customBorder: const CircleBorder(),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Icon(
                          Icons.add_rounded,
                          color: scheme.onPrimaryContainer,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
