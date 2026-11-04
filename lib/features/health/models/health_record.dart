/// Model class that maps one row of the `health_records` table.
class HealthRecord {
  final int? id;
  final String date; // yyyy-MM-dd
  final int steps;
  final int calories;
  final int water; // millilitres

  const HealthRecord({
    this.id,
    required this.date,
    required this.steps,
    required this.calories,
    required this.water,
  });

  HealthRecord copyWith({
    int? id,
    String? date,
    int? steps,
    int? calories,
    int? water,
  }) {
    return HealthRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      steps: steps ?? this.steps,
      calories: calories ?? this.calories,
      water: water ?? this.water,
    );
  }

  /// Converts the object to a map that sqflite can insert.
  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date,
      'steps': steps,
      'calories': calories,
      'water': water,
    };
  }

  /// Creates an object from a database row.
  factory HealthRecord.fromMap(Map<String, Object?> map) {
    return HealthRecord(
      id: map['id'] as int?,
      date: map['date'] as String,
      steps: (map['steps'] as num).toInt(),
      calories: (map['calories'] as num).toInt(),
      water: (map['water'] as num).toInt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HealthRecord &&
          other.id == id &&
          other.date == date &&
          other.steps == steps &&
          other.calories == calories &&
          other.water == water;

  @override
  int get hashCode => Object.hash(id, date, steps, calories, water);

  @override
  String toString() =>
      'HealthRecord(id: $id, date: $date, steps: $steps, calories: $calories, water: $water)';
}
