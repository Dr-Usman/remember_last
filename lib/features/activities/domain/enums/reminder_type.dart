/// Reminder frequency presets stored with each activity.
enum ReminderType {
  none,
  daily,
  weekly,
  monthly,
  custom;

  /// Presets shown when due intervals are enabled (`none` is the switch-off state).
  static const selectable = [daily, weekly, monthly, custom];

  /// Fixed day count for daily / weekly / monthly; null for none / custom.
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

  bool get hasFixedDays => defaultDays != null;

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
