import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/activity.dart' as domain;
import '../../domain/enums/reminder_type.dart';

/// Maps between Drift rows and domain [Activity] entities.
class ActivityMapper {
  const ActivityMapper();

  domain.Activity toDomain(ActivityRow row) {
    return domain.Activity(
      id: row.id,
      uuid: row.uuid,
      title: row.title,
      category: row.category,
      notes: row.notes,
      reminderDays: row.reminderDays,
      reminderType: ReminderType.fromIndex(row.reminderType),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  ActivitiesCompanion toCompanion(domain.Activity activity, {bool isInsert = false}) {
    return ActivitiesCompanion(
      id: isInsert ? const Value.absent() : Value(activity.id),
      uuid: Value(activity.uuid),
      title: Value(activity.title),
      category: Value(activity.category),
      notes: Value(activity.notes),
      reminderDays: Value(activity.reminderDays),
      reminderType: Value(activity.reminderType.index),
      createdAt: Value(activity.createdAt),
      updatedAt: Value(activity.updatedAt),
    );
  }
}

/// Result row from the activities-with-last-done join query.
class ActivityWithLastDoneRow {
  ActivityWithLastDoneRow({
    required this.activity,
    this.lastDoneAt,
  });

  final ActivityRow activity;
  final DateTime? lastDoneAt;

  domain.ActivityWithLastDone toDomain(ActivityMapper mapper) {
    return domain.ActivityWithLastDone(
      activity: mapper.toDomain(activity),
      lastDoneAt: lastDoneAt,
    );
  }
}
