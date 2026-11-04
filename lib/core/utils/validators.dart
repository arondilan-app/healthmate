import '../constants/app_constants.dart';

/// Pure validation functions used by the forms (easy to unit test).
class Validators {
  Validators._();

  static String? date(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a date';
    }
    final pattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!pattern.hasMatch(value.trim())) {
      return 'Invalid date format';
    }
    return null;
  }

  static String? steps(String? value) =>
      _wholeNumber(value, label: 'Steps', max: AppConstants.maxSteps);

  static String? calories(String? value) =>
      _wholeNumber(value, label: 'Calories', max: AppConstants.maxCalories);

  static String? water(String? value) =>
      _wholeNumber(value, label: 'Water', max: AppConstants.maxWaterMl);

  /// Goal fields must be strictly positive.
  static String? goal(String? value, {required String label, required int max}) {
    final base = _wholeNumber(value, label: label, max: max);
    if (base != null) return base;
    if (int.parse(value!.trim()) == 0) {
      return '$label goal must be greater than 0';
    }
    return null;
  }

  static String? _wholeNumber(
    String? value, {
    required String label,
    required int max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    final number = int.tryParse(value.trim());
    if (number == null) {
      return '$label must be a whole number';
    }
    if (number < 0) {
      return '$label cannot be negative';
    }
    if (number > max) {
      return '$label cannot be more than $max';
    }
    return null;
  }
}
