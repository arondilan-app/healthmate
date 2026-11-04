import 'package:intl/intl.dart';

/// Helper functions for converting between [DateTime] and the
/// `yyyy-MM-dd` text format that is stored in the SQLite `date` column.
class AppDateUtils {
  AppDateUtils._();

  static final DateFormat _keyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _prettyFormat = DateFormat('d MMMM yyyy');
  static final DateFormat _weekdayFormat = DateFormat('E');

  /// `DateTime` -> `2026-08-18`
  static String toKey(DateTime date) => _keyFormat.format(date);

  /// `2026-08-18` -> `DateTime`
  static DateTime parseKey(String key) => _keyFormat.parseStrict(key);

  /// Key for today's date.
  static String todayKey() => toKey(DateTime.now());

  /// `2026-08-18` -> `18 August 2026`
  static String pretty(String key) {
    try {
      return _prettyFormat.format(parseKey(key));
    } catch (_) {
      return key;
    }
  }

  /// `2026-08-18` -> `Tue`
  static String weekday(String key) {
    try {
      return _weekdayFormat.format(parseKey(key));
    } catch (_) {
      return '';
    }
  }

  /// Returns the keys of the last [days] days, oldest first, ending today.
  static List<String> lastDays(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List<String>.generate(
      days,
      (i) => toKey(today.subtract(Duration(days: days - 1 - i))),
    );
  }
}
