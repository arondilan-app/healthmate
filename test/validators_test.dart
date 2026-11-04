import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/utils/validators.dart';

void main() {
  group('Validators.steps', () {
    test('rejects empty value', () {
      expect(Validators.steps(''), 'Steps is required');
      expect(Validators.steps(null), 'Steps is required');
    });

    test('rejects non numeric text', () {
      expect(Validators.steps('abc'), 'Steps must be a whole number');
      expect(Validators.steps('12.5'), 'Steps must be a whole number');
    });

    test('rejects negative and too large values', () {
      expect(Validators.steps('-5'), 'Steps cannot be negative');
      expect(Validators.steps('100001'), isNotNull);
    });

    test('accepts valid values', () {
      expect(Validators.steps('0'), isNull);
      expect(Validators.steps('7850'), isNull);
      expect(Validators.steps('100000'), isNull);
    });
  });

  group('Validators.calories / water', () {
    test('calories limit is 20000', () {
      expect(Validators.calories('20000'), isNull);
      expect(Validators.calories('20001'), isNotNull);
    });

    test('water limit is 10000 ml', () {
      expect(Validators.water('2000'), isNull);
      expect(Validators.water('10001'), isNotNull);
    });
  });

  group('Validators.date', () {
    test('requires yyyy-MM-dd', () {
      expect(Validators.date(''), isNotNull);
      expect(Validators.date('18/08/2026'), isNotNull);
      expect(Validators.date('2026-08-18'), isNull);
    });
  });

  group('Validators.goal', () {
    test('goal must be greater than zero', () {
      expect(Validators.goal('0', label: 'Steps', max: 100000), isNotNull);
      expect(Validators.goal('8000', label: 'Steps', max: 100000), isNull);
    });
  });
}
