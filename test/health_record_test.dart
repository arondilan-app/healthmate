import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/utils/date_utils.dart';
import 'package:healthmate/features/health/models/day_summary.dart';
import 'package:healthmate/features/health/models/health_record.dart';

void main() {
  group('HealthRecord', () {
    const record = HealthRecord(
      id: 1,
      date: '2026-08-18',
      steps: 7850,
      calories: 420,
      water: 2000,
    );

    test('toMap contains all table columns', () {
      expect(record.toMap(), {
        'id': 1,
        'date': '2026-08-18',
        'steps': 7850,
        'calories': 420,
        'water': 2000,
      });
    });

    test('toMap omits id for a new record', () {
      const fresh = HealthRecord(
        date: '2026-08-18',
        steps: 1,
        calories: 2,
        water: 3,
      );
      expect(fresh.toMap().containsKey('id'), isFalse);
    });

    test('fromMap(toMap) returns an equal object', () {
      expect(HealthRecord.fromMap(record.toMap()), record);
    });

    test('copyWith changes only the given fields', () {
      final updated = record.copyWith(steps: 9000);
      expect(updated.steps, 9000);
      expect(updated.water, record.water);
      expect(updated.id, record.id);
    });
  });

  group('DaySummary', () {
    test('empty summary has zero totals', () {
      final s = DaySummary.empty('2026-08-18');
      expect(s.steps, 0);
      expect(s.entries, 0);
    });

    test('fromMap reads SUM() columns', () {
      final s = DaySummary.fromMap({
        'date': '2026-08-18',
        'steps': 1000,
        'calories': 50,
        'water': 250,
        'entries': 2,
      });
      expect(s.water, 250);
      expect(s.entries, 2);
    });
  });

  group('AppDateUtils', () {
    test('toKey and parseKey are inverse', () {
      final d = DateTime(2026, 8, 18);
      expect(AppDateUtils.toKey(d), '2026-08-18');
      expect(AppDateUtils.parseKey('2026-08-18'), d);
    });

    test('pretty formats the date for display', () {
      expect(AppDateUtils.pretty('2026-08-18'), '18 August 2026');
    });

    test('lastDays returns N keys ending today', () {
      final keys = AppDateUtils.lastDays(7);
      expect(keys.length, 7);
      expect(keys.last, AppDateUtils.todayKey());
    });
  });
}
