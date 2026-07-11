import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../features/activities/domain/entities/activity.dart';
import '../features/activities/domain/enums/reminder_type.dart';
import '../features/occurrences/domain/entities/occurrence.dart';
import '../core/database/database_provider.dart';

/// Inserts sample activities on first launch so the app isn't empty.
Future<void> seedDatabaseIfEmpty(WidgetRef ref) async {
  final activityRepo = ref.read(activityRepositoryProvider);
  if (!await activityRepo.isEmpty()) return;

  const uuid = Uuid();
  final now = DateTime.now();

  final samples = [
    _Sample(
      title: 'Water plants',
      category: 'Home',
      reminderDays: 3,
      reminderType: ReminderType.custom,
      lastDone: now.subtract(const Duration(days: 2)),
    ),
    _Sample(
      title: 'Car wash',
      category: 'Vehicle',
      reminderDays: 14,
      reminderType: ReminderType.custom,
      lastDone: now.subtract(const Duration(days: 10)),
    ),
    _Sample(
      title: 'Fuel refill',
      category: 'Vehicle',
      reminderDays: 7,
      reminderType: ReminderType.weekly,
      lastDone: now.subtract(const Duration(days: 8)),
    ),
    _Sample(
      title: 'Called parents',
      category: 'Personal',
      reminderDays: 7,
      reminderType: ReminderType.weekly,
      lastDone: now.subtract(const Duration(days: 3)),
    ),
  ];

  final occurrenceRepo = ref.read(occurrenceRepositoryProvider);

  for (final sample in samples) {
    final activityId = await activityRepo.insert(
      Activity(
        id: 0,
        uuid: uuid.v4(),
        title: sample.title,
        category: sample.category,
        reminderDays: sample.reminderDays,
        reminderType: sample.reminderType,
        createdAt: now,
        updatedAt: now,
      ),
    );

    await occurrenceRepo.insert(
      Occurrence(
        id: 0,
        activityId: activityId,
        doneAt: sample.lastDone,
      ),
    );
  }
}

class _Sample {
  const _Sample({
    required this.title,
    required this.category,
    required this.reminderDays,
    required this.reminderType,
    required this.lastDone,
  });

  final String title;
  final String category;
  final int reminderDays;
  final ReminderType reminderType;
  final DateTime lastDone;
}
