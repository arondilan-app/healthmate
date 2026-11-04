/// Aggregated totals for one calendar day (sum of all records of that date).
class DaySummary {
  final String date; // yyyy-MM-dd
  final int steps;
  final int calories;
  final int water;
  final int entries;

  const DaySummary({
    required this.date,
    this.steps = 0,
    this.calories = 0,
    this.water = 0,
    this.entries = 0,
  });

  factory DaySummary.empty(String date) => DaySummary(date: date);

  factory DaySummary.fromMap(Map<String, Object?> map) {
    return DaySummary(
      date: map['date'] as String,
      steps: (map['steps'] as num?)?.toInt() ?? 0,
      calories: (map['calories'] as num?)?.toInt() ?? 0,
      water: (map['water'] as num?)?.toInt() ?? 0,
      entries: (map['entries'] as num?)?.toInt() ?? 0,
    );
  }
}
