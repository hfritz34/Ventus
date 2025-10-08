import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:app/features/alarm/providers/alarm_provider.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/core/services/alarm_scheduler_service.dart';

class AlarmListScreen extends ConsumerStatefulWidget {
  const AlarmListScreen({super.key});

  @override
  ConsumerState<AlarmListScreen> createState() => _AlarmListScreenState();
}

class _AlarmListScreenState extends ConsumerState<AlarmListScreen> {
  @override
  void initState() {
    super.initState();
    Future(() {
      final alarms = StorageService().getAllAlarms();
      ref.read(alarmProvider.notifier).loadAlarms(alarms);
    });
  }

  String _formatTime(DateTime time) {
    return DateFormat.jm().format(time);
  }

  String _formatDays(List<int> days) {
    if (days.isEmpty) return 'Once';
    if (days.length == 7) return 'Every day';

    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days.map((d) => dayNames[d - 1]).join(', ');
  }

  Future<void> _deleteAlarm(String alarmId) async {
    final alarm = ref.read(alarmProvider).firstWhere((a) => a.id == alarmId);
    await AlarmSchedulerService().cancelAlarm(alarm);
    ref.read(alarmProvider.notifier).deleteAlarm(alarmId);
    await StorageService().deleteAlarm(alarmId);
  }

  Future<void> _toggleAlarm(String alarmId) async {
    ref.read(alarmProvider.notifier).toggleAlarm(alarmId);
    final alarm = ref.read(alarmProvider).firstWhere((a) => a.id == alarmId);
    await StorageService().saveAlarm(alarm);
    await AlarmSchedulerService().rescheduleAlarm(alarm);
  }

  @override
  Widget build(BuildContext context) {
    final alarms = ref.watch(alarmProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/ventus_transparent.png',
              height: 32,
            ),
            const SizedBox(width: 4),
            const Text('Ventus'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.push('/profile'),
          ),
        ],
      ),
      body: alarms.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No alarms yet'),
                  Text('Tap + to add your first alarm'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: alarms.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final alarm = alarms[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    onTap: () => context.push('/edit-alarm', extra: alarm),
                    title: Text(
                      _formatTime(alarm.alarmTime),
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_formatDays(alarm.repeatDays)),
                        Text('${alarm.graceWindowMinutes} min grace window'),
                        if (alarm.accountabilityContactName != null)
                          Text('Contact: ${alarm.accountabilityContactName}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: alarm.isActive,
                          onChanged: (_) => _toggleAlarm(alarm.id),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteAlarm(alarm.id),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-alarm'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
