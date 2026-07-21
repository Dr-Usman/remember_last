import '../../../../core/database/app_database.dart';
import '../../domain/entities/occurrence.dart' as domain;
import '../../domain/repositories/occurrence_repository.dart';
import '../mappers/occurrence_mapper.dart';

class OccurrenceRepositoryImpl implements OccurrenceRepository {
  OccurrenceRepositoryImpl(this._db);

  final AppDatabase _db;
  final _mapper = const OccurrenceMapper();

  @override
  Stream<List<domain.Occurrence>> watchByActivityId(int activityId) {
    return _db
        .watchOccurrencesForActivity(activityId)
        .map((rows) => rows.map(_mapper.toDomain).toList());
  }

  @override
  Future<List<domain.Occurrence>> getByActivityId(
    int activityId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = await _db.getOccurrencesForActivity(
      activityId,
      limit: limit,
      offset: offset,
    );
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<domain.Occurrence?> getLatestForActivity(int activityId) async {
    final row = await _db.getLatestOccurrenceForActivity(activityId);
    return row == null ? null : _mapper.toDomain(row);
  }

  @override
  Future<int> insert(domain.Occurrence occurrence) async {
    return _db.insertOccurrence(
      _mapper.toCompanion(occurrence, isInsert: true),
    );
  }

  @override
  Future<void> delete(int id) async {
    await _db.deleteOccurrence(id);
  }

  @override
  Future<void> update(domain.Occurrence occurrence) async {
    await _db.updateOccurrence(_mapper.toCompanion(occurrence));
  }

  @override
  Future<int> countForActivity(int activityId) async {
    return _db.countOccurrencesForActivity(activityId);
  }

  @override
  Future<int> countAll() async {
    return _db.countAllOccurrences();
  }
}
