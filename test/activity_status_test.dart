import 'package:flutter_test/flutter_test.dart';
import 'package:remember_last/core/utils/activity_status.dart';
import 'package:remember_last/features/activities/domain/entities/activity.dart';
import 'package:remember_last/features/activities/domain/enums/reminder_type.dart';

void main() {
  group('ActivityStatusCalculator', () {
    const calculator = ActivityStatusCalculator();

    final activity = Activity(
      id: 1,
      uuid: 'test',
      title: 'Test',
      reminderDays: 10,
      reminderType: ReminderType.custom,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('returns neverLogged when no last done date', () {
      expect(
        calculator.compute(activity: activity, lastDoneAt: null),
        ActivityStatus.neverLogged,
      );
    });

    test('returns recent when well before due date', () {
      final lastDone = DateTime(2026, 7, 1);
      final now = DateTime(2026, 7, 5); // 4 days ago, due at 10 days
      expect(
        calculator.compute(activity: activity, lastDoneAt: lastDone, now: now),
        ActivityStatus.recent,
      );
    });

    test('returns dueSoon within buffer window', () {
      final lastDone = DateTime(2026, 7, 1);
      final now = DateTime(2026, 7, 10); // day 9, buffer is 2 days, due day 10
      expect(
        calculator.compute(activity: activity, lastDoneAt: lastDone, now: now),
        ActivityStatus.dueSoon,
      );
    });

    test('returns overdue after due date', () {
      final lastDone = DateTime(2026, 7, 1);
      final now = DateTime(2026, 7, 12);
      expect(
        calculator.compute(activity: activity, lastDoneAt: lastDone, now: now),
        ActivityStatus.overdue,
      );
    });

    test('computes next due date', () {
      final lastDone = DateTime(2026, 7, 1);
      expect(
        calculator.nextDueDate(activity: activity, lastDoneAt: lastDone),
        DateTime(2026, 7, 11),
      );
    });
  });
}
