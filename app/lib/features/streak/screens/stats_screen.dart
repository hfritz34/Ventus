import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:app/features/streak/providers/streak_provider.dart';
import 'package:app/features/streak/widgets/streak_calendar.dart';
import 'package:app/features/streak/widgets/photo_timeline.dart';
import 'package:app/features/streak/services/streak_service.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _focusedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Load streaks from storage on init
    Future(() {
      final allStreaks = StreakService().getAllStreakEntries();
      ref.read(streakProvider.notifier).loadStreaks(allStreaks);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  void _onDayTapped(DateTime day) {
    context.push('/day-detail', extra: day);
  }

  @override
  Widget build(BuildContext context) {
    final currentStreak = ref.watch(streakProvider.notifier).getCurrentStreak();
    final longestStreak = ref.watch(streakProvider.notifier).getLongestStreak();
    final successRate = ref.watch(streakProvider.notifier).getSuccessRate();
    final totalSuccessful = ref.watch(streakProvider.notifier).getTotalSuccessful();

    final monthLabel = DateFormat('MMMM yyyy').format(_focusedMonth);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Stats'),
      ),
      body: Column(
        children: [
          // Stats cards
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Current Streak',
                    value: '$currentStreak',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events,
                    label: 'Longest Streak',
                    value: '$longestStreak',
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Success Rate',
                    value: '${successRate.toStringAsFixed(0)}%',
                    color: Colors.green,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_today,
                    label: 'Total Successful',
                    value: '$totalSuccessful',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Tabs
          TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: Theme.of(context).primaryColor,
            tabs: const [
              Tab(text: 'Calendar'),
              Tab(text: 'Photos'),
            ],
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Calendar tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Month navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left),
                            onPressed: _previousMonth,
                          ),
                          Text(
                            monthLabel,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right),
                            onPressed: _nextMonth,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Calendar
                      StreakCalendar(
                        focusedMonth: _focusedMonth,
                        onDayTapped: _onDayTapped,
                      ),
                      const SizedBox(height: 24),
                      // Legend
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _LegendItem(
                            color: Theme.of(context).primaryColor,
                            label: 'Success',
                          ),
                          _LegendItem(
                            color: Colors.grey[400]!,
                            label: 'Failed',
                          ),
                          _LegendItem(
                            color: Colors.white,
                            borderColor: Colors.grey[300],
                            label: 'No alarm',
                          ),
                          _LegendItem(
                            color: Colors.grey[100]!,
                            label: 'Future',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Photos tab
                const SingleChildScrollView(
                  child: PhotoTimeline(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final String label;

  const _LegendItem({
    required this.color,
    this.borderColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: borderColor != null ? Border.all(color: borderColor!) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
