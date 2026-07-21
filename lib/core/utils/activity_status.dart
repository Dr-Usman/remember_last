import '../../features/activities/domain/entities/activity.dart' show Activity;
import '../../features/activities/domain/enums/reminder_type.dart';

/// Visual status for an activity based on reminder configuration.
enum ActivityStatus { neverLogged, noReminder, recent, dueSoon, overdue }

extension ActivityStatusX on ActivityStatus {
  String get label {
    switch (this) {
      case ActivityStatus.neverLogged:
        return 'Never logged';
      case ActivityStatus.noReminder:
        return 'Logged';
      case ActivityStatus.recent:
        return 'Recent';
      case ActivityStatus.dueSoon:
        return 'Due soon';
      case ActivityStatus.overdue:
        return 'Overdue';
    }
  }

  String get emoji {
    switch (this) {
      case ActivityStatus.neverLogged:
        return '○';
      case ActivityStatus.noReminder:
        return '✓';
      case ActivityStatus.recent:
        return '✅';
      case ActivityStatus.dueSoon:
        return '⚠️';
      case ActivityStatus.overdue:
        return '🔴';
    }
  }
}

/// Whether the activity has an active reminder configured.
bool activityHasActiveReminder(Activity activity) {
  final reminderDays = activity.reminderDays;
  return reminderDays != null &&
      reminderDays > 0 &&
      activity.reminderType != ReminderType.none;
}

/// Computes due status from last done date and reminder interval.
class ActivityStatusCalculator {
  const ActivityStatusCalculator();

  ActivityStatus compute({
    required Activity activity,
    DateTime? lastDoneAt,
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();

    if (lastDoneAt == null) {
      return ActivityStatus.neverLogged;
    }

    if (!activityHasActiveReminder(activity)) {
      return ActivityStatus.noReminder;
    }

    final reminderDays = activity.reminderDays!;

    final dueDate = lastDoneAt.add(Duration(days: reminderDays));
    final bufferDays = _bufferDays(reminderDays);
    final warningStart = dueDate.subtract(Duration(days: bufferDays));

    if (current.isBefore(warningStart)) {
      return ActivityStatus.recent;
    }
    if (current.isBefore(dueDate)) {
      return ActivityStatus.dueSoon;
    }
    return ActivityStatus.overdue;
  }

  DateTime? nextDueDate({required Activity activity, DateTime? lastDoneAt}) {
    if (lastDoneAt == null) return null;
    if (!activityHasActiveReminder(activity)) return null;
    return lastDoneAt.add(Duration(days: activity.reminderDays!));
  }

  int _bufferDays(int reminderDays) {
    final calculated = (reminderDays * 0.2).ceil();
    return calculated < 1 ? 1 : calculated;
  }
}
