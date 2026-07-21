import '../../../../core/database/app_database.dart';
import '../../domain/entities/activity.dart' as domain;
import '../../domain/repositories/activity_repository.dart';
import '../mappers/activity_mapper.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  ActivityRepositoryImpl(this._db);

  final AppDatabase _db;
  final _mapper = const ActivityMapper();

  @override
  Stream<List<domain.ActivityWithLastDone>> watchAllWithLastDone() {
    return _db.watchActivitiesWithLastDone().map(
      (rows) => rows.map((r) => r.toDomain(_mapper)).toList(),
    );
  }

  @override
  Future<List<domain.Activity>> getAll() async {
    final rows = await _db.getAllActivities();
    return rows.map(_mapper.toDomain).toList();
  }

  @override
  Future<domain.Activity?> getById(int id) async {
    final row = await _db.getActivityById(id);
    return row == null ? null : _mapper.toDomain(row);
  }

  @override
  Stream<domain.Activity?> watchById(int id) {
    return _db
        .watchActivityById(id)
        .map((row) => row == null ? null : _mapper.toDomain(row));
  }

  @override
  Future<domain.Activity?> getByUuid(String uuid) async {
    final row = await _db.getActivityByUuid(uuid);
    return row == null ? null : _mapper.toDomain(row);
  }

  @override
  Future<int> insert(domain.Activity activity) async {
    return _db.insertActivity(_mapper.toCompanion(activity, isInsert: true));
  }

  @override
  Future<void> update(domain.Activity activity) async {
    await _db.updateActivity(_mapper.toCompanion(activity));
  }

  @override
  Future<void> delete(int id) async {
    await _db.deleteActivity(id);
  }

  @override
  Future<List<String>> getCategories() async {
    return _db.getDistinctCategories();
  }

  @override
  Future<bool> isEmpty() async {
    return _db.isActivitiesEmpty();
  }
}
