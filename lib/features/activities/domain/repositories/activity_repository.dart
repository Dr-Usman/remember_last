import '../entities/activity.dart';

abstract class ActivityRepository {
  Stream<List<ActivityWithLastDone>> watchAllWithLastDone();

  Future<List<Activity>> getAll();

  Future<Activity?> getById(int id);

  Stream<Activity?> watchById(int id);

  Future<Activity?> getByUuid(String uuid);

  Future<int> insert(Activity activity);

  Future<void> update(Activity activity);

  Future<void> delete(int id);

  Future<List<String>> getCategories();

  Future<bool> isEmpty();
}
