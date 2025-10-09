import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:app/features/auth/providers/auth_provider.dart';
import 'package:app/features/streak/providers/streak_provider.dart';
import 'package:app/features/streak/widgets/streak_calendar.dart';
import 'package:app/features/streak/widgets/photo_timeline.dart';
import 'package:app/features/streak/services/streak_service.dart';
import 'package:app/core/constants/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    // Load streaks from storage on init
    Future(() {
      final allStreaks = StreakService().getAllStreakEntries();
      ref.read(streakProvider.notifier).loadStreaks(allStreaks);
    });
  }

  void _onDayTapped(DateTime day) {
    context.push('/day-detail', extra: day);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final currentStreak = ref.watch(streakProvider.notifier).getCurrentStreak();
    final longestStreak = ref.watch(streakProvider.notifier).getLongestStreak();
    final successRate = ref.watch(streakProvider.notifier).getSuccessRate();
    final totalSuccessful = ref.watch(streakProvider.notifier).getTotalSuccessful();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        children: [
          // User info header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    authState.username?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        authState.username ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        authState.email ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Stats cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    icon: Icons.local_fire_department,
                    label: 'Streak',
                    value: '$currentStreak',
                    color: AppTheme.primaryOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.emoji_events,
                    label: 'Longest',
                    value: '$longestStreak',
                    color: AppTheme.lightOrange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.check_circle,
                    label: 'Success',
                    value: '${successRate.toStringAsFixed(0)}%',
                    color: AppTheme.darkBlue,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatCard(
                    icon: Icons.calendar_today,
                    label: 'Total',
                    value: '$totalSuccessful',
                    color: AppTheme.paleOrange,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Calendar section
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StreakCalendar(
                    onDayTapped: _onDayTapped,
                  ),
                  const SizedBox(height: 32),
                  // Photos section header
                  Text(
                    'Wake-Up Photos',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  const PhotoTimeline(),
                ],
              ),
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
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

