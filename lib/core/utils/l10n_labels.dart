import '../../features/activities/domain/enums/reminder_type.dart';
import '../../l10n/app_localizations.dart';
import 'activity_status.dart';

extension ActivityStatusL10n on ActivityStatus {
  String l10nLabel(AppLocalizations l10n) {
    switch (this) {
      case ActivityStatus.neverLogged:
        return l10n.statusNeverLogged;
      case ActivityStatus.noReminder:
        return l10n.statusLogged;
      case ActivityStatus.recent:
        return l10n.statusRecent;
      case ActivityStatus.dueSoon:
        return l10n.statusDueSoon;
      case ActivityStatus.overdue:
        return l10n.statusOverdue;
    }
  }
}

extension ReminderTypeL10n on ReminderType {
  String l10nLabel(AppLocalizations l10n) {
    switch (this) {
      case ReminderType.none:
        return l10n.reminderNone;
      case ReminderType.daily:
        return l10n.reminderDaily;
      case ReminderType.weekly:
        return l10n.reminderWeekly;
      case ReminderType.monthly:
        return l10n.reminderMonthly;
      case ReminderType.custom:
        return l10n.reminderCustom;
    }
  }
}
