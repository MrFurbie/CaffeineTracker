import 'package:flutter/foundation.dart';
import '../models/analytics.dart';
import '../models/consumption_record.dart';
import 'data_manager.dart';
import 'analytics_calculator.dart';

class HistoryProvider extends ChangeNotifier {
  List<DailySummary> _dailySummaries = [];
  DateTime _selectedDate = DateTime.now();
  DailySummary? _selectedSummary;
  bool _isLoading = false;
  DateRange _dateRange = DateRange.week;

  List<DailySummary> get dailySummaries => _dailySummaries;
  DateTime get selectedDate => _selectedDate;
  DailySummary? get selectedSummary => _selectedSummary;
  bool get isLoading => _isLoading;
  DateRange get dateRange => _dateRange;

  int get totalCaffeineInRange {
    return _dailySummaries.fold(0, (sum, summary) => sum + summary.totalCaffeine);
  }

  int get averageDailyInRange {
    if (_dailySummaries.isEmpty) return 0;
    return totalCaffeineInRange ~/ _dailySummaries.length;
  }

  int get highestDayInRange {
    if (_dailySummaries.isEmpty) return 0;
    return _dailySummaries.map((s) => s.totalCaffeine).reduce((a, b) => a > b ? a : b);
  }

  Future<void> loadHistoryData() async {
    _isLoading = true;
    notifyListeners();

    final allRecords = DataManager.fetchConsumptionRecords();
    final startDate = _getStartDateForRange();
    final endDate = DateTime.now();

    _dailySummaries = AnalyticsCalculator.getDateRangeSummaries(
      startDate,
      endDate,
      allRecords,
    );

    _isLoading = false;
    notifyListeners();
  }

  DateTime _getStartDateForRange() {
    final now = DateTime.now();
    switch (_dateRange) {
      case DateRange.week:
        return now.subtract(const Duration(days: 7));
      case DateRange.month:
        return now.subtract(const Duration(days: 30));
      case DateRange.threeMonths:
        return now.subtract(const Duration(days: 90));
      case DateRange.year:
        return now.subtract(const Duration(days: 365));
      case DateRange.allTime:
        final records = DataManager.fetchConsumptionRecords();
        if (records.isEmpty) return now;
        final timestamps = records.map((r) => r.timestamp).toList();
        return timestamps.reduce((a, b) => a.isBefore(b) ? a : b);
    }
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    final allRecords = DataManager.fetchConsumptionRecords();
    _selectedSummary = AnalyticsCalculator.calculateDailySummary(date, allRecords);
    notifyListeners();
  }

  void setDateRange(DateRange range) {
    _dateRange = range;
    loadHistoryData();
  }

  List<ConsumptionRecord> getRecordsForDate(DateTime date) {
    return DataManager.fetchRecordsForDate(date);
  }
}

enum DateRange {
  week,
  month,
  threeMonths,
  year,
  allTime,
}