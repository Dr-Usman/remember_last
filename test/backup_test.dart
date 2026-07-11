import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:remember_last/features/activities/domain/enums/reminder_type.dart';
import 'package:remember_last/features/backup/domain/backup_service.dart';

void main() {
  test('backup JSON structure has required fields', () {
    final json = {
      'version': BackupService.currentVersion,
      'exportedAt': DateTime(2026, 7, 11).toIso8601String(),
      'activities': [
        {
          'uuid': 'abc-123',
          'title': 'Water plants',
          'category': 'Home',
          'notes': null,
          'reminderDays': 3,
          'reminderType': ReminderType.custom.index,
          'createdAt': DateTime(2026, 1, 1).toIso8601String(),
          'updatedAt': DateTime(2026, 1, 1).toIso8601String(),
        },
      ],
      'occurrences': [
        {
          'activityUuid': 'abc-123',
          'doneAt': DateTime(2026, 7, 1).toIso8601String(),
          'note': 'Done',
        },
      ],
    };

    final decoded = jsonDecode(jsonEncode(json)) as Map<String, dynamic>;
    expect(decoded['version'], 1);
    expect(decoded['activities'], isA<List>());
    expect(decoded['occurrences'], isA<List>());
    expect((decoded['activities'] as List).first['title'], 'Water plants');
  });
}
