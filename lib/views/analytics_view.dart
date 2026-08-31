import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/analytics_provider.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({Key? key}) : super(key: key);

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AnalyticsProvider>().loadAnalyticsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                context.read<AnalyticsProvider>().refreshData();
              },
            ),
          ),
        ],
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildKeyMetrics(provider),
                const SizedBox(height: 24),
                _buildWeeklyComparison(provider),
                const SizedBox(height: 24),
                _buildTimeAnalysis(provider),
                const SizedBox(height: 24),
                _buildStatistics(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildKeyMetrics(AnalyticsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FE),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
              ).createShader(bounds),
              child: const Text(
                'Key Metrics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _MetricCard(
                  title: 'All-Time High',
                  value: '${provider.allTimeHighest} mg',
                  icon: Icons.emoji_events,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFB300), Color(0xFFFF8F00)],
                  ),
                ),
                _MetricCard(
                  title: 'Highest Week',
                  value: '${provider.highestWeek} mg',
                  icon: Icons.calendar_month,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
                  ),
                ),
                _MetricCard(
                  title: 'Daily Average',
                  value: '${provider.averageDaily} mg',
                  icon: Icons.trending_up,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
                  ),
                ),
                _MetricCard(
                  title: 'Current Streak',
                  value: '${provider.currentStreak} days',
                  icon: Icons.local_fire_department,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF6B6B), Color(0xFFEE5A5A)],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyComparison(AnalyticsProvider provider) {
    final change = provider.weekOverWeekChange;
    final changePercentage = (change * 100).toInt();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FE),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
              ).createShader(bounds),
              child: const Text(
                'Weekly Comparison',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'This Week',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${provider.currentWeekTotal} mg',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Last Week',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${provider.lastWeekTotal} mg',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (provider.lastWeekTotal > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: change >= 0
                      ? const Color(0xFFFF6B6B).withOpacity(0.1)
                      : const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      change >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                      color: change >= 0 ? const Color(0xFFFF6B6B) : const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${changePercentage.abs()}% ${change >= 0 ? 'increase' : 'decrease'}',
                      style: TextStyle(
                        color: change >= 0 ? const Color(0xFFFF6B6B) : const Color(0xFF4CAF50),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimeAnalysis(AnalyticsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FE),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
              ).createShader(bounds),
              child: const Text(
                'Time Analysis',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _StatRow(
              icon: Icons.access_time,
              title: 'Peak Consumption Time',
              value: provider.peakConsumptionTime,
              iconColor: const Color(0xFF6C63FF),
            ),
            const SizedBox(height: 16),
            _StatRow(
              icon: Icons.coffee,
              title: 'Total Drinks Consumed',
              value: '${provider.totalDrinksConsumed}',
              iconColor: const Color(0xFF4CAF50),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(AnalyticsProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FE),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
              ).createShader(bounds),
              child: const Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _StatRow(
              icon: Icons.local_drink,
              title: 'Total Drinks Consumed',
              value: '${provider.totalDrinksConsumed}',
              iconColor: const Color(0xFF6C63FF),
            ),
            if (provider.currentStreak > 0) ...[
              const SizedBox(height: 16),
              _StatRow(
                icon: Icons.today,
                title: 'Average Drinks Per Day',
                value: (provider.totalDrinksConsumed / provider.currentStreak).toStringAsFixed(1),
                iconColor: const Color(0xFF4CAF50),
              ),
            ],
            const SizedBox(height: 16),
            _StatRow(
              icon: Icons.calendar_today,
              title: 'Current Streak',
              value: '${provider.currentStreak} days',
              iconColor: const Color(0xFFFF6B6B),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
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
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Colors.white,
                fontSize: 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color? iconColor;

  const _StatRow({
    required this.icon,
    required this.title,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor?.withOpacity(0.1) ?? const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor ?? const Color(0xFF6C63FF), size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF636E72),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: iconColor ?? const Color(0xFF6C63FF),
          ),
        ),
      ],
    );
  }
}