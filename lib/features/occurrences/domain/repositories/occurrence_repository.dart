import '../entities/occurrence.dart';

abstract class OccurrenceRepository {
  Stream<List<Occurrence>> watchByActivityId(int activityId);

  Future<List<Occurrence>> getByActivityId(
    int activityId, {
    int limit = 50,
    int offset = 0,
  });

  Future<Occurrence?> getLatestForActivity(int activityId);

  Future<int> insert(Occurrence occurrence);

  Future<void> delete(int id);

  Future<void> update(Occurrence occurrence);

  Future<int> countForActivity(int activityId);

  Future<int> countAll();
}
