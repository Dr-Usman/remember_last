/// Reminder frequency presets stored with each activity.
enum ReminderType {
  none,
  daily,
  weekly,
  monthly,
  custom;

  int? get defaultDays {
    switch (this) {
      case ReminderType.none:
        return null;
      case ReminderType.daily:
        return 1;
      case ReminderType.weekly:
        return 7;
      case ReminderType.monthly:
        return 30;
      case ReminderType.custom:
        return null;
    }
  }

  String get label {
    switch (this) {
      case ReminderType.none:
        return 'None';
      case ReminderType.daily:
        return 'Daily';
      case ReminderType.weekly:
        return 'Weekly';
      case ReminderType.monthly:
        return 'Monthly';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  static ReminderType fromIndex(int index) {
    if (index < 0 || index >= ReminderType.values.length) {
      return ReminderType.none;
    }
    return ReminderType.values[index];
  }
}
