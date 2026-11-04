import '../../../core/utils/date_utils.dart';
import '../../../data/database/database_helper.dart';
import '../models/day_summary.dart';
import '../models/health_record.dart';

/// Repository layer: the ViewModel talks to this class and never to SQL.
/// It hides where the data comes from (today: SQLite) and prepares data
/// in the shape the UI needs.
class HealthRepository {
  HealthRepository(this._db);

  final DatabaseHelper _db;

  Future<List<HealthRecord>> getRecords({String? date}) =>
      _db.getAll(date: date);

  Future<int> add(HealthRecord record) => _db.insert(record);

  Future<void> update(HealthRecord record) async {
    await _db.update(record);
  }

  Future<void> delete(int id) async {
    await _db.delete(id);
  }

  /// Puts back a record that was deleted by mistake (undo).
  Future<void> restore(HealthRecord record) async {
    await _db.insert(record);
  }

  Future<DaySummary> getSummaryForDate(String date) =>
      _db.getSummaryForDate(date);

  /// Totals for the last [days] days (oldest first). Days without any
  /// record are filled with zeros so the chart always has [days] bars.
  Future<List<DaySummary>> getLastDays(int days) async {
    final keys = AppDateUtils.lastDays(days);
    final totals = await _db.getDailyTotals(keys.first, keys.last);
    final byDate = {for (final t in totals) t.date: t};
    return [for (final k in keys) byDate[k] ?? DaySummary.empty(k)];
  }
}
