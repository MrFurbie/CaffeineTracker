import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/history_provider.dart';
import '../models/analytics.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({Key? key}) : super(key: key);

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HistoryProvider>().loadHistoryData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Consumer<HistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              _buildDateRangeSelector(provider),
              _buildSummaryStats(provider),
              Expanded(
                child: provider.dailySummaries.isEmpty
                    ? _buildEmptyState()
                    : _buildDailySummariesList(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateRangeSelector(HistoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFFF8F9FE),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: SegmentedButton<DateRange>(
          segments: const [
            ButtonSegment(
              value: DateRange.week,
              label: Text('Week'),
            ),
            ButtonSegment(
              value: DateRange.month,
              label: Text('Month'),
            ),
            ButtonSegment(
              value: DateRange.threeMonths,
              label: Text('3 Months'),
            ),
            ButtonSegment(
              value: DateRange.year,
              label: Text('Year'),
            ),
            ButtonSegment(
              value: DateRange.allTime,
              label: Text('All Time'),
            ),
          ],
          selected: {provider.dateRange},
          onSelectionChanged: (Set<DateRange> newSelection) {
            provider.setDateRange(newSelection.first);
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(0xFF6C63FF);
              }
              return Colors.transparent;
            }),
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return Colors.white;
              }
              return const Color(0xFF636E72);
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryStats(HistoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Total',
              value: '${provider.totalCaffeineInRange} mg',
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'Average',
              value: '${provider.averageDailyInRange} mg',
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _StatCard(
              title: 'Highest',
              value: '${provider.highestDayInRange} mg',
              gradient: const LinearGradient(
                colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailySummariesList(HistoryProvider provider) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: provider.dailySummaries.length,
      itemBuilder: (context, index) {
        final summary = provider.dailySummaries[index];
        return _DailySummaryCard(summary: summary);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No history yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3436),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking your caffeine intake to see your history here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF636E72),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Gradient gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  final DailySummary summary;

  const _DailySummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final percentage = (summary.totalCaffeine / 400 * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FE),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    summary.dateString,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  Text(
                    '${summary.drinkCount} drinks',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF636E72),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${summary.totalCaffeine} mg',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6C63FF),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: percentage > 100
                        ? const Color(0xFFFF6B6B).withOpacity(0.1)
                        : const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$percentage% of daily limit',
                    style: TextStyle(
                      fontSize: 11,
                      color: percentage > 100
                          ? const Color(0xFFFF6B6B)
                          : const Color(0xFF4CAF50),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}