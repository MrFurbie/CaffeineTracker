import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/home_provider.dart';
import '../models/consumption_record.dart';
import 'drink_selection_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<HomeProvider>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
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
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DrinkSelectionView()),
                );
              },
            ),
          ),
        ],
      ),
      body: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildProgressRing(provider),
                const SizedBox(height: 24),
                _buildQuickStats(provider),
                const SizedBox(height: 24),
                if (provider.todayRecords.isNotEmpty)
                  _buildTodayTimeline(provider)
                else
                  _buildEmptyState(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DateFormat.yMMMMd().format(DateTime.now()),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: const Color(0xFF636E72),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
          ).createShader(bounds),
          child: Text(
            'Caffeine Tracker',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressRing(HomeProvider provider) {
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
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Background ring
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6C63FF).withOpacity(0.1),
                          const Color(0xFF4CAF50).withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  // Progress ring
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: CircularProgressIndicator(
                      value: provider.progressPercentage,
                      strokeWidth: 16,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        provider.isOverLimit ? const Color(0xFFFF6B6B) : const Color(0xFF6C63FF),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: provider.isOverLimit
                              ? [const Color(0xFFFF6B6B), const Color(0xFFEE5A5A)]
                              : [const Color(0xFF6C63FF), const Color(0xFF4CAF50)],
                        ).createShader(bounds),
                        child: Text(
                          '${provider.todayTotal}',
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text(
                        'mg',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF636E72),
                        ),
                      ),
                      Text(
                        'of ${provider.dailyLimit} mg',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF636E72),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoRow(
                  icon: Icons.bolt,
                  label: '${provider.remainingCaffeine} mg remaining',
                  color: const Color(0xFF6C63FF),
                ),
                _buildInfoRow(
                  icon: Icons.coffee,
                  label: '${provider.drinkCount} drinks',
                  color: const Color(0xFF4CAF50),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Color(0xFF636E72),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(HomeProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            title: "Today's Total",
            value: '${provider.todayTotal} mg',
            icon: Icons.bolt,
            gradient: const LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF5A52D5)],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickStatCard(
            title: 'Drink Count',
            value: '${provider.drinkCount}',
            icon: Icons.coffee,
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _QuickStatCard(
            title: 'Status',
            value: provider.isOverLimit ? 'Over Limit' : 'On Track',
            icon: provider.isOverLimit ? Icons.warning : Icons.check_circle,
            gradient: LinearGradient(
              colors: provider.isOverLimit
                  ? [const Color(0xFFFF6B6B), const Color(0xFFEE5A5A)]
                  : [const Color(0xFF4CAF50), const Color(0xFF45A049)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTodayTimeline(HomeProvider provider) {
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
              child: Text(
                "Today's Timeline",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...provider.todayRecords.map((record) => _TimelineCard(
              record: record,
              provider: provider,
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
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
        padding: const EdgeInsets.all(40),
        child: Column(
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
                Icons.local_cafe,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No drinks logged today',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to add your first drink',
              style: TextStyle(
                color: Color(0xFF636E72),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const DrinkSelectionView()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  minimumSize: const Size(double.infinity, 56),
                ),
                child: const Text(
                  'Add Drink',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _QuickStatCard({
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

class _TimelineCard extends StatelessWidget {
  final ConsumptionRecord record;
  final HomeProvider provider;

  const _TimelineCard({
    required this.record,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.05),
            const Color(0xFF4CAF50).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.1),
        ),
      ),
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
              Icons.local_cafe,
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
                  provider.getDrinkName(record),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                ),
                if (provider.getServingSizeName(record).isNotEmpty)
                  Text(
                    provider.getServingSizeName(record),
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
                '${record.caffeineAmount} mg',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF6C63FF),
                ),
              ),
              Text(
                record.timeString,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF636E72),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFFF6B6B)),
              onPressed: () {
                _showDeleteDialog(context, record.id);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteRecord(id);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}