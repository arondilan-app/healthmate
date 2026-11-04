/// Application wide constants (limits, default goals, DB names).
class AppConstants {
  AppConstants._();

  static const String appName = 'HealthMate';

  // Database
  static const String dbName = 'healthmate.db';
  static const int dbVersion = 1;
  static const String tableHealthRecords = 'health_records';

  // Validation limits
  static const int maxSteps = 100000;
  static const int maxCalories = 20000;
  static const int maxWaterMl = 10000;

  // Default daily goals
  static const int defaultStepsGoal = 10000;
  static const int defaultCaloriesGoal = 500;
  static const int defaultWaterGoal = 2500;

  // Number of past days shown in the dashboard chart
  static const int chartDays = 7;
}
