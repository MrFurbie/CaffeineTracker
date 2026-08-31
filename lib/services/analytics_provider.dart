import 'package:flutter/foundation.dart';
import '../models/analytics.dart';
import 'data_manager.dart';
import 'analytics_calculator.dart';

class AnalyticsProvider extends ChangeNotifier {
  AnalyticsData? _analyticsData;
  bool _isLoading = false;
  List<WeeklySummary> _weeklySummaries = [];

  AnalyticsData? get analyticsData => _analyticsData;
  bool get isLoading => _isLoading;
  List<WeeklySummary> get weeklySummaries => _weeklySummaries;

  // Computed properties for easy access
  int get allTimeHighest => _analyticsData?.allTimeHighest ?? 0;
  int get highestWeek => _analyticsData?.highestWeek ?? 0;
  int get averageDaily => _analyticsData?.averageDaily ?? 0;
  int get currentStreak => _analyticsData?.currentStreak ?? 0;
  String get peakConsumptionTime => _analyticsData?.peakConsumptionTime ?? 'No data';
  int get totalDrinksConsumed => _analyticsData?.totalDrinksConsumed ?? 0;

  // Weekly analysis
  int get currentWeekTotal {
    final now = DateTime.now();
    final weekStart = AnalyticsCalculator.getWeekStart(now);
    final thisWeekRecords = DataManager.fetchConsumptionRecords().where((record) {
      return record.timestamp.isAfter(weekStart);
    }).toList();
    return thisWeekRecords.fold(0, (sum, record) => sum + record.caffeineAmount);
  }

  int get lastWeekTotal {
    final now = DateTime.now();
    final thisWeekStart = AnalyticsCalculator.getWeekStart(now);
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    final lastWeekEnd = thisWeekStart;

    final lastWeekRecords = DataManager.fetchConsumptionRecords().where((record) {
      return record.timestamp.isAfter(lastWeekStart) && record.timestamp.isBefore(lastWeekEnd);
    }).toList();
    return lastWeekRecords.fold(0, (sum, record) => sum + record.caffeineAmount);
  }

  double get weekOverWeekChange {
    if (lastWeekTotal == 0) return 0;
    return (currentWeekTotal - lastWeekTotal) / lastWeekTotal;
  }

  Future<void> loadAnalyticsData() async {
    _isLoading = true;
    notifyListeners();

    final allRecords = DataManager.fetchConsumptionRecords();
    _analyticsData = AnalyticsCalculator.calculateAnalytics(allRecords);
    _weeklySummaries = AnalyticsCalculator.calculateWeeklyTrends(allRecords);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshData() async {
    await loadAnalyticsData();
  }
}