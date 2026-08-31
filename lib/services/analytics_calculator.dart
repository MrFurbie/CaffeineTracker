import '../models/consumption_record.dart';
import '../models/analytics.dart';

class AnalyticsCalculator {
  static AnalyticsData calculateAnalytics(List<ConsumptionRecord> records) {
    final allTimeHighest = calculateAllTimeHighest(records);
    final highestWeek = calculateHighestWeek(records);
    final averageDaily = calculateAverageDaily(records);
    final currentStreak = calculateCurrentStreak(records);
    final weeklyTrends = calculateWeeklyTrends(records);
    final peakConsumptionTime = calculatePeakConsumptionTime(records);
    final totalDrinksConsumed = records.length;

    return AnalyticsData(
      allTimeHighest: allTimeHighest,
      highestWeek: highestWeek,
      averageDaily: averageDaily,
      currentStreak: currentStreak,
      weeklyTrends: weeklyTrends,
      peakConsumptionTime: peakConsumptionTime,
      totalDrinksConsumed: totalDrinksConsumed,
    );
  }

  static int calculateAllTimeHighest(List<ConsumptionRecord> records) {
    final dailyTotals = <DateTime, int>{};
    
    for (final record in records) {
      final day = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + record.caffeineAmount;
    }
    
    if (dailyTotals.isEmpty) return 0;
    return dailyTotals.values.reduce((a, b) => a > b ? a : b);
  }

  static int calculateHighestWeek(List<ConsumptionRecord> records) {
    final weeklySummaries = calculateWeeklyTrends(records);
    if (weeklySummaries.isEmpty) return 0;
    return weeklySummaries.map((week) => week.totalCaffeine).reduce((a, b) => a > b ? a : b);
  }

  static int calculateAverageDaily(List<ConsumptionRecord> records) {
    if (records.isEmpty) return 0;
    
    final dailyTotals = <DateTime, int>{};
    
    for (final record in records) {
      final day = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + record.caffeineAmount;
    }
    
    if (dailyTotals.isEmpty) return 0;
    
    final totalCaffeine = dailyTotals.values.reduce((a, b) => a + b);
    final numberOfDays = dailyTotals.length;
    
    return totalCaffeine ~/ numberOfDays;
  }

  static int calculateCurrentStreak(List<ConsumptionRecord> records) {
    if (records.isEmpty) return 0;
    
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    var currentDate = todayStart;
    var streak = 0;
    
    // Sort records by date
    final sortedRecords = List<ConsumptionRecord>.from(records);
    sortedRecords.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    
    final dailyTotals = <DateTime, int>{};
    for (final record in sortedRecords) {
      final day = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
      dailyTotals[day] = (dailyTotals[day] ?? 0) + record.caffeineAmount;
    }
    
    // Check if today has any consumption
    if (dailyTotals[todayStart] == null || dailyTotals[todayStart] == 0) {
      // If no consumption today, check yesterday
      currentDate = todayStart.subtract(const Duration(days: 1));
    }
    
    // Count consecutive days with consumption
    while (dailyTotals[currentDate] != null && dailyTotals[currentDate]! > 0) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    }
    
    return streak;
  }

  static List<WeeklySummary> calculateWeeklyTrends(List<ConsumptionRecord> records) {
    final weeklyData = <DateTime, List<ConsumptionRecord>>{};
    
    for (final record in records) {
      final weekStart = getWeekStart(record.timestamp);
      weeklyData[weekStart] = (weeklyData[weekStart] ?? [])..add(record);
    }
    
    final weeklySummaries = weeklyData.entries.map((entry) {
      final dailySummaries = groupRecordsByDay(entry.value);
      return WeeklySummary.fromWeek(entry.key, dailySummaries);
    }).toList();
    
    weeklySummaries.sort((a, b) => a.weekStart.compareTo(b.weekStart));
    return weeklySummaries;
  }

  static DateTime getWeekStart(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  static List<DailySummary> groupRecordsByDay(List<ConsumptionRecord> records) {
    final dailyData = <DateTime, List<ConsumptionRecord>>{};
    
    for (final record in records) {
      final day = DateTime(record.timestamp.year, record.timestamp.month, record.timestamp.day);
      dailyData[day] = (dailyData[day] ?? [])..add(record);
    }
    
    final summaries = dailyData.entries.map((entry) {
      return DailySummary.fromRecords(entry.key, entry.value);
    }).toList();
    
    summaries.sort((a, b) => a.date.compareTo(b.date));
    return summaries;
  }

  static String calculatePeakConsumptionTime(List<ConsumptionRecord> records) {
    if (records.isEmpty) return 'No data';
    
    final hourlyTotals = <int, int>{};
    
    for (final record in records) {
      final hour = record.timestamp.hour;
      hourlyTotals[hour] = (hourlyTotals[hour] ?? 0) + record.caffeineAmount;
    }
    
    if (hourlyTotals.isEmpty) return 'No data';
    
    final peakEntry = hourlyTotals.entries.reduce((a, b) => a.value > b.value ? a : b);
    final peakHour = peakEntry.key;
    
    if (peakHour == 0) return '12 AM';
    if (peakHour < 12) return '$peakHour AM';
    if (peakHour == 12) return '12 PM';
    return '${peakHour - 12} PM';
  }

  static DailySummary calculateDailySummary(DateTime date, List<ConsumptionRecord> records) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final dayRecords = records.where((record) =>
        record.timestamp.isAfter(startOfDay) && record.timestamp.isBefore(endOfDay)
    ).toList();
    
    return DailySummary.fromRecords(date, dayRecords);
  }

  static List<DailySummary> getDateRangeSummaries(
    DateTime startDate,
    DateTime endDate,
    List<ConsumptionRecord> records,
  ) {
    final summaries = <DailySummary>[];
    var currentDate = startDate;
    
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      summaries.add(calculateDailySummary(currentDate, records));
      currentDate = currentDate.add(const Duration(days: 1));
    }
    
    return summaries;
  }
}