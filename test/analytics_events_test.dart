import 'package:flutter_test/flutter_test.dart';
import 'package:remember_last/core/analytics/analytics_events.dart';

void main() {
  group('AnalyticsEvents', () {
    test('screenViewed includes screen name and platform', () {
      final properties = AnalyticsEvents.screenViewed(screenName: 'home');

      expect(properties['screen_name'], 'home');
      expect(properties['platform'], isNotEmpty);
    });

    test('occurrenceLogged includes source and flags', () {
      final properties = AnalyticsEvents.occurrenceLogged(
        source: 'quick_log',
        hasNote: false,
        isBackdated: false,
      );

      expect(properties['source'], 'quick_log');
      expect(properties['has_note'], false);
      expect(properties['is_backdated'], false);
    });

    test('isBackdatedEntry is true when doneAt is more than one minute ago', () {
      final doneAt = DateTime.now().subtract(const Duration(minutes: 2));

      expect(AnalyticsEvents.isBackdatedEntry(doneAt), isTrue);
    });

    test('isBackdatedEntry is false for recent timestamps', () {
      expect(AnalyticsEvents.isBackdatedEntry(DateTime.now()), isFalse);
    });
  });
}
