import 'consumption_record.dart';

class DailySummary {
  final String id;
  final DateTime date;
  final int totalCaffeine;
  final int drinkCount;
  final List<ConsumptionRecord> records;

  DailySummary({
    required this.id,
    required this.date,
    required this.totalCaffeine,
    required this.drinkCount,
    required this.records,
  });

  factory DailySummary.fromRecords(DateTime date, List<ConsumptionRecord> records) {
    final totalCaffeine = records.fold(0, (sum, record) => sum + record.caffeineAmount);
    return DailySummary(
      id: date.millisecondsSinceEpoch.toString(),
      date: date,
      totalCaffeine: totalCaffeine,
      drinkCount: records.length,
      records: records,
    );
  }

  double get percentageOfDailyLimit {
    const dailyLimit = 400; // Default recommended limit
    return totalCaffeine / dailyLimit;
  }

  String get dateString {
    return '${date.month}/${date.day}/${date.year}';
  }
}

class WeeklySummary {
  final String id;
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalCaffeine;
  final int averageDaily;
  final int highestDay;
  final List<DailySummary> daySummaries;

  WeeklySummary({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.totalCaffeine,
    required this.averageDaily,
    required this.highestDay,
    required this.daySummaries,
  });

  factory WeeklySummary.fromWeek(DateTime weekStart, List<DailySummary> daySummaries) {
    final weekEnd = weekStart.add(const Duration(days: 6));
    final totalCaffeine = daySummaries.fold(0, (sum, day) => sum + day.totalCaffeine);
    final averageDaily = daySummaries.isEmpty ? 0 : totalCaffeine ~/ daySummaries.length;
    
    int highestDay = 0;
    if (daySummaries.isNotEmpty) {
      highestDay = daySummaries.map((day) => day.totalCaffeine).reduce((a, b) => a > b ? a : b);
    }

    return WeeklySummary(
      id: weekStart.millisecondsSinceEpoch.toString(),
      weekStart: weekStart,
      weekEnd: weekEnd,
      totalCaffeine: totalCaffeine,
      averageDaily: averageDaily,
      highestDay: highestDay,
      daySummaries: daySummaries,
    );
  }
}

class AnalyticsData {
  final int allTimeHighest;
  final int highestWeek;
  final int averageDaily;
  final int currentStreak;
  final List<WeeklySummary> weeklyTrends;
  final String peakConsumptionTime;
  final int totalDrinksConsumed;

  AnalyticsData({
    required this.allTimeHighest,
    required this.highestWeek,
    required this.averageDaily,
    required this.currentStreak,
    required this.weeklyTrends,
    required this.peakConsumptionTime,
    required this.totalDrinksConsumed,
  });
}