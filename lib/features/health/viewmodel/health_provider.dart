import 'package:flutter/foundation.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_utils.dart';
import '../models/day_summary.dart';
import '../models/health_record.dart';
import '../repository/health_repository.dart';

/// ViewModel (state holder) for everything related to health records.
/// Screens listen to this [ChangeNotifier] through the Provider package.
class HealthProvider extends ChangeNotifier {
  HealthProvider(this._repository);

  final HealthRepository _repository;

  List<HealthRecord> _records = [];
  DaySummary _today = DaySummary.empty(AppDateUtils.todayKey());
  List<DaySummary> _lastDays = [];
  String? _filterDate;
  bool _isLoading = false;
  String? _errorMessage;
  HealthRecord? _lastDeleted;

  // ----------------------------------------------------------------- getters
  List<HealthRecord> get records => List.unmodifiable(_records);
  DaySummary get today => _today;
  List<DaySummary> get lastDays => List.unmodifiable(_lastDays);
  String? get filterDate => _filterDate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFiltered => _filterDate != null;
  bool get canUndoDelete => _lastDeleted != null;

  // ------------------------------------------------------------------- READ
  /// Loads everything the UI needs (list + dashboard totals + chart data).
  Future<void> loadAll() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _refresh();
    } catch (e) {
      _errorMessage = 'Could not load records. Please try again.';
      debugPrint('loadAll error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _refresh() async {
    _records = await _repository.getRecords(date: _filterDate);
    _today = await _repository.getSummaryForDate(AppDateUtils.todayKey());
    _lastDays = await _repository.getLastDays(AppConstants.chartDays);
  }

  // ----------------------------------------------------------------- FILTER
  Future<void> setFilterDate(String date) async {
    _filterDate = date;
    await loadAll();
  }

  Future<void> clearFilter() async {
    _filterDate = null;
    await loadAll();
  }

  // ----------------------------------------------------------------- CREATE
  Future<bool> addRecord(HealthRecord record) {
    return _run(() => _repository.add(record));
  }

  // ----------------------------------------------------------------- UPDATE
  Future<bool> updateRecord(HealthRecord record) {
    return _run(() => _repository.update(record));
  }

  // ----------------------------------------------------------------- DELETE
  /// Deletes a record. The item is removed from the in-memory list first
  /// (optimistic update) so a swiped [Dismissible] disappears immediately.
  Future<bool> deleteRecord(HealthRecord record) {
    if (record.id == null) return Future.value(false);
    _lastDeleted = record;
    _records = _records.where((r) => r.id != record.id).toList();
    notifyListeners();
    return _run(() => _repository.delete(record.id!));
  }

  /// Restores the most recently deleted record (Undo button of the snackbar).
  Future<bool> undoDelete() async {
    final record = _lastDeleted;
    if (record == null) return false;
    _lastDeleted = null;
    return _run(() => _repository.restore(record));
  }

  // ---------------------------------------------------------------- HELPERS
  /// Runs a write operation, then reloads the data. Returns true on success.
  Future<bool> _run(Future<void> Function() action) async {
    try {
      await action();
      _errorMessage = null;
      await _refresh();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Something went wrong while saving. Please try again.';
      debugPrint('write error: $e');
      notifyListeners();
      return false;
    }
  }
}
