import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/date_utils.dart';
import '../../features/health/models/day_summary.dart';
import '../../features/health/models/health_record.dart';

/// Low level access to the embedded SQLite database (sqflite).
///
/// This class is the only place in the app that writes SQL.
/// All queries use `?` placeholders (`whereArgs`) so user input is never
/// concatenated into SQL strings (prevents SQL injection).
class DatabaseHelper {
  DatabaseHelper._internal();

  /// Single shared instance (Singleton pattern).
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Future<Database>? _opening;

  /// Lazily opens the database exactly once.
  Future<Database> get database => _opening ??= _open();

  Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.tableHealthRecords} (
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        date     TEXT    NOT NULL,
        steps    INTEGER NOT NULL DEFAULT 0,
        calories INTEGER NOT NULL DEFAULT 0,
        water    INTEGER NOT NULL DEFAULT 0
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_health_records_date '
      'ON ${AppConstants.tableHealthRecords}(date)',
    );
    await _insertDummyData(db);
  }

  /// Dummy records so the app can be tested immediately after install.
  Future<void> _insertDummyData(Database db) async {
    final days = AppDateUtils.lastDays(14); // oldest -> today
    final batch = db.batch();

    for (var i = 0; i < days.length; i++) {
      final isToday = i == days.length - 1;
      batch.insert(AppConstants.tableHealthRecords, {
        'date': days[i],
        // today's values match the example in the coursework brief
        'steps': isToday ? 7850 : 4500 + ((i * 1373) % 7000),
        'calories': isToday ? 420 : 220 + ((i * 97) % 380),
        'water': isToday ? 2000 : 1200 + ((i * 311) % 1800),
      });

      // every third day gets a second small entry (extra water + walk)
      if (i % 3 == 0) {
        batch.insert(AppConstants.tableHealthRecords, {
          'date': days[i],
          'steps': 600,
          'calories': 40,
          'water': 500,
        });
      }
    }
    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------- CREATE
  Future<int> insert(HealthRecord record) async {
    final db = await database;
    return db.insert(
      AppConstants.tableHealthRecords,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ------------------------------------------------------------------ READ
  /// Returns all records (newest first). When [date] is given only the
  /// records of that exact day are returned (search / filter by date).
  Future<List<HealthRecord>> getAll({String? date}) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.tableHealthRecords,
      where: date == null ? null : 'date = ?',
      whereArgs: date == null ? null : [date],
      orderBy: 'date DESC, id DESC',
    );
    return rows.map(HealthRecord.fromMap).toList();
  }

  Future<HealthRecord?> getById(int id) async {
    final db = await database;
    final rows = await db.query(
      AppConstants.tableHealthRecords,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : HealthRecord.fromMap(rows.first);
  }

  /// Totals (SUM) for one day - used by the dashboard.
  Future<DaySummary> getSummaryForDate(String date) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT date,
             SUM(steps)    AS steps,
             SUM(calories) AS calories,
             SUM(water)    AS water,
             COUNT(*)      AS entries
      FROM ${AppConstants.tableHealthRecords}
      WHERE date = ?
      GROUP BY date
      ''',
      [date],
    );
    return rows.isEmpty
        ? DaySummary.empty(date)
        : DaySummary.fromMap(rows.first);
  }

  /// Daily totals between [from] and [to] (inclusive) - used by the chart.
  Future<List<DaySummary>> getDailyTotals(String from, String to) async {
    final db = await database;
    final rows = await db.rawQuery(
      '''
      SELECT date,
             SUM(steps)    AS steps,
             SUM(calories) AS calories,
             SUM(water)    AS water,
             COUNT(*)      AS entries
      FROM ${AppConstants.tableHealthRecords}
      WHERE date >= ? AND date <= ?
      GROUP BY date
      ORDER BY date ASC
      ''',
      [from, to],
    );
    return rows.map(DaySummary.fromMap).toList();
  }

  // ---------------------------------------------------------------- UPDATE
  Future<int> update(HealthRecord record) async {
    if (record.id == null) {
      throw ArgumentError('Cannot update a record without an id');
    }
    final db = await database;
    return db.update(
      AppConstants.tableHealthRecords,
      record.toMap(),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // ---------------------------------------------------------------- DELETE
  Future<int> delete(int id) async {
    final db = await database;
    return db.delete(
      AppConstants.tableHealthRecords,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
