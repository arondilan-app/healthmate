import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';

/// Stores user preferences: dark mode and the daily goals.
/// Values are persisted with shared_preferences.
class SettingsProvider extends ChangeNotifier {
  static const _kDarkMode = 'dark_mode';
  static const _kStepsGoal = 'goal_steps';
  static const _kCaloriesGoal = 'goal_calories';
  static const _kWaterGoal = 'goal_water';

  bool _darkMode = false;
  int _stepsGoal = AppConstants.defaultStepsGoal;
  int _caloriesGoal = AppConstants.defaultCaloriesGoal;
  int _waterGoal = AppConstants.defaultWaterGoal;

  bool get darkMode => _darkMode;
  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;
  int get stepsGoal => _stepsGoal;
  int get caloriesGoal => _caloriesGoal;
  int get waterGoal => _waterGoal;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _darkMode = prefs.getBool(_kDarkMode) ?? false;
      _stepsGoal = prefs.getInt(_kStepsGoal) ?? AppConstants.defaultStepsGoal;
      _caloriesGoal =
          prefs.getInt(_kCaloriesGoal) ?? AppConstants.defaultCaloriesGoal;
      _waterGoal = prefs.getInt(_kWaterGoal) ?? AppConstants.defaultWaterGoal;
    } catch (e) {
      debugPrint('Could not load settings, using defaults: $e');
    }
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kDarkMode, value);
    } catch (e) {
      debugPrint('Could not save dark mode: $e');
    }
  }

  Future<void> setGoals({
    required int steps,
    required int calories,
    required int water,
  }) async {
    _stepsGoal = steps;
    _caloriesGoal = calories;
    _waterGoal = water;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kStepsGoal, steps);
      await prefs.setInt(_kCaloriesGoal, calories);
      await prefs.setInt(_kWaterGoal, water);
    } catch (e) {
      debugPrint('Could not save goals: $e');
    }
  }
}
