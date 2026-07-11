import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/database_provider.dart';
import '../../activities/domain/entities/activity.dart';
import '../../activities/domain/enums/reminder_type.dart';
import '../../occurrences/domain/entities/occurrence.dart';

/// Handles JSON export/import for offline backup.
class BackupService {
  BackupService(this._ref);

  final Ref _ref;
  static const currentVersion = 1;

  Future<Map<String, dynamic>> exportToJson() async {
    final activityRepo = _ref.read(activityRepositoryProvider);
    final occurrenceRepo = _ref.read(occurrenceRepositoryProvider);

    final activities = await activityRepo.getAll();
    final exportActivities = <Map<String, dynamic>>[];
    final exportOccurrences = <Map<String, dynamic>>[];

    for (final activity in activities) {
      exportActivities.add({
        'uuid': activity.uuid,
        'title': activity.title,
        'category': activity.category,
        'notes': activity.notes,
        'reminderDays': activity.reminderDays,
        'reminderType': activity.reminderType.index,
        'createdAt': activity.createdAt.toIso8601String(),
        'updatedAt': activity.updatedAt.toIso8601String(),
      });

      final occurrences =
          await occurrenceRepo.getByActivityId(activity.id, limit: 10000);
      for (final occurrence in occurrences) {
        exportOccurrences.add({
          'activityUuid': activity.uuid,
          'doneAt': occurrence.doneAt.toIso8601String(),
          'note': occurrence.note,
        });
      }
    }

    return {
      'version': currentVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'activities': exportActivities,
      'occurrences': exportOccurrences,
    };
  }

  String encodeExport(Map<String, dynamic> data) {
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Future<BackupImportResult> importFromJson(
    String jsonString, {
    bool merge = true,
  }) async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final version = decoded['version'] as int? ?? 0;
    if (version > currentVersion) {
      throw BackupException('Unsupported backup version: $version');
    }

    final activityRepo = _ref.read(activityRepositoryProvider);
    final occurrenceRepo = _ref.read(occurrenceRepositoryProvider);

    if (!merge) {
      final existing = await activityRepo.getAll();
      for (final activity in existing) {
        await activityRepo.delete(activity.id);
      }
    }

    final activitiesJson = decoded['activities'] as List<dynamic>? ?? [];
    final occurrencesJson = decoded['occurrences'] as List<dynamic>? ?? [];

    var importedActivities = 0;
    var importedOccurrences = 0;
    final uuidToId = <String, int>{};

    for (final raw in activitiesJson) {
      final map = raw as Map<String, dynamic>;
      final uuid = map['uuid'] as String;
      final existing = await activityRepo.getByUuid(uuid);
      final now = DateTime.now();

      final activity = Activity(
        id: existing?.id ?? 0,
        uuid: uuid,
        title: map['title'] as String,
        category: map['category'] as String?,
        notes: map['notes'] as String?,
        reminderDays: map['reminderDays'] as int?,
        reminderType:
            ReminderType.fromIndex(map['reminderType'] as int? ?? 0),
        createdAt: existing?.createdAt ??
            DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            now,
        updatedAt: now,
      );

      if (existing != null) {
        await activityRepo.update(activity);
        uuidToId[uuid] = existing.id;
      } else {
        final id = await activityRepo.insert(activity);
        uuidToId[uuid] = id;
        importedActivities++;
      }
    }

    for (final raw in occurrencesJson) {
      final map = raw as Map<String, dynamic>;
      final activityUuid = map['activityUuid'] as String;
      final activityId = uuidToId[activityUuid];
      if (activityId == null) continue;

      await occurrenceRepo.insert(
        Occurrence(
          id: 0,
          activityId: activityId,
          doneAt: DateTime.parse(map['doneAt'] as String),
          note: map['note'] as String?,
        ),
      );
      importedOccurrences++;
    }

    return BackupImportResult(
      activities: importedActivities,
      occurrences: importedOccurrences,
    );
  }
}

class BackupImportResult {
  const BackupImportResult({
    required this.activities,
    required this.occurrences,
  });

  final int activities;
  final int occurrences;
}

class BackupException implements Exception {
  BackupException(this.message);
  final String message;

  @override
  String toString() => message;
}

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref);
});
