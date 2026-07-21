import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../features/activities/domain/entities/activity.dart';
import '../features/activities/domain/enums/reminder_type.dart';
import '../features/occurrences/domain/entities/occurrence.dart';
import '../core/database/database_provider.dart';
import '../core/services/shared_prefs_service.dart';

/// Inserts sample activities once on first launch so the app isn't empty.
///
/// After the first seed (or if the user already has activities), this never
/// runs again — deleting every activity will leave the list empty on restart.
Future<void> seedDatabaseIfEmpty(WidgetRef ref) async {
  final prefs = ref.read(sharedPrefsServiceProvider);
  if (await prefs.getBool(PrefsKeys.hasSeededSamples) == true) return;

  final activityRepo = ref.read(activityRepositoryProvider);
  if (!await activityRepo.isEmpty()) {
    // Existing install with data — don't reseed later if they clear everything.
    await prefs.setBool(PrefsKeys.hasSeededSamples, true);
    return;
  }

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
      Occurrence(id: 0, activityId: activityId, doneAt: sample.lastDone),
    );
  }

  await prefs.setBool(PrefsKeys.hasSeededSamples, true);
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
