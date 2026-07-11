import 'package:intl/intl.dart';

/// Formats dates for display across the app.
class DateFormatter {
  static final _absoluteDate = DateFormat('MMM d, yyyy');
  static final _absoluteDateTime = DateFormat('MMM d, yyyy • h:mm a');
  static final _timeOnly = DateFormat('h:mm a');

  /// Returns a human-readable elapsed string like "3 days ago".
  static String formatElapsed(DateTime dateTime, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final diff = current.difference(dateTime);

    if (diff.isNegative) {
      return 'Just now';
    }
    if (diff.inDays >= 365) {
      final years = diff.inDays ~/ 365;
      return years == 1 ? '1 year ago' : '$years years ago';
    }
    if (diff.inDays >= 30) {
      final months = diff.inDays ~/ 30;
      return months == 1 ? '1 month ago' : '$months months ago';
    }
    if (diff.inDays >= 1) {
      return diff.inDays == 1 ? '1 day ago' : '${diff.inDays} days ago';
    }
    if (diff.inHours >= 1) {
      return diff.inHours == 1 ? '1 hour ago' : '${diff.inHours} hours ago';
    }
    if (diff.inMinutes >= 1) {
      return diff.inMinutes == 1
          ? '1 minute ago'
          : '${diff.inMinutes} minutes ago';
    }
    return 'Just now';
  }

  static String formatAbsoluteDate(DateTime dateTime) {
    return _absoluteDate.format(dateTime);
  }

  static String formatAbsoluteDateTime(DateTime dateTime) {
    return _absoluteDateTime.format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return _timeOnly.format(dateTime);
  }
}
