import '../enums/reminder_type.dart';

/// Domain model for a trackable activity/event.
class Activity {
  const Activity({
    required this.id,
    required this.uuid,
    required this.title,
    this.category,
    this.notes,
    this.reminderDays,
    this.reminderType = ReminderType.none,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String uuid;
  final String title;
  final String? category;
  final String? notes;
  final int? reminderDays;
  final ReminderType reminderType;
  final DateTime createdAt;
  final DateTime updatedAt;

  Activity copyWith({
    int? id,
    String? uuid,
    String? title,
    String? category,
    String? notes,
    int? reminderDays,
    bool clearReminderDays = false,
    ReminderType? reminderType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Activity(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      title: title ?? this.title,
      category: category ?? this.category,
      notes: notes ?? this.notes,
      reminderDays:
          clearReminderDays ? null : (reminderDays ?? this.reminderDays),
      reminderType: reminderType ?? this.reminderType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Activity paired with its most recent occurrence timestamp.
class ActivityWithLastDone {
  const ActivityWithLastDone({
    required this.activity,
    this.lastDoneAt,
  });

  final Activity activity;
  final DateTime? lastDoneAt;
}
