import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';
import '../../features/activities/data/repositories/activity_repository_impl.dart';
import '../../features/activities/domain/repositories/activity_repository.dart';
import '../../features/occurrences/data/repositories/occurrence_repository_impl.dart';
import '../../features/occurrences/domain/repositories/occurrence_repository.dart';

/// Singleton Drift database instance.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final activityRepositoryProvider = Provider<ActivityRepository>((ref) {
  return ActivityRepositoryImpl(ref.watch(databaseProvider));
});

final occurrenceRepositoryProvider = Provider<OccurrenceRepository>((ref) {
  return OccurrenceRepositoryImpl(ref.watch(databaseProvider));
});
