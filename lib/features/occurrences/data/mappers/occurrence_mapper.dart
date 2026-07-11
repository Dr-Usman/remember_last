import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/occurrence.dart' as domain;

/// Maps between Drift rows and domain [Occurrence] entities.
class OccurrenceMapper {
  const OccurrenceMapper();

  domain.Occurrence toDomain(OccurrenceRow row) {
    return domain.Occurrence(
      id: row.id,
      activityId: row.activityId,
      doneAt: row.doneAt,
      note: row.note,
    );
  }

  OccurrencesCompanion toCompanion(domain.Occurrence occurrence,
      {bool isInsert = false}) {
    return OccurrencesCompanion(
      id: isInsert ? const Value.absent() : Value(occurrence.id),
      activityId: Value(occurrence.activityId),
      doneAt: Value(occurrence.doneAt),
      note: Value(occurrence.note),
    );
  }
}
