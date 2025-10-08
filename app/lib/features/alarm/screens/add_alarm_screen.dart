import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:app/features/alarm/models/alarm.dart';
import 'package:app/features/alarm/providers/alarm_provider.dart';
import 'package:app/core/services/storage_service.dart';
import 'package:app/core/services/alarm_scheduler_service.dart';

class AddAlarmScreen extends ConsumerStatefulWidget {
  const AddAlarmScreen({super.key});

  @override
  ConsumerState<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends ConsumerState<AddAlarmScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _graceWindowMinutes = 15;
  final Set<int> _selectedDays = {};
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _customMessageController = TextEditingController();

  @override
  void dispose() {
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _customMessageController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _saveAlarm() async {
    final now = DateTime.now();
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final alarm = Alarm(
      alarmTime: alarmTime,
      graceWindowMinutes: _graceWindowMinutes,
      repeatDays: _selectedDays.toList()..sort(),
      accountabilityContactName: _contactNameController.text.isNotEmpty
          ? _contactNameController.text
          : null,
      accountabilityContactPhone: _contactPhoneController.text.isNotEmpty
          ? _contactPhoneController.text
          : null,
      customAccountabilityMessage: _customMessageController.text.isNotEmpty
          ? _customMessageController.text
          : null,
    );

    ref.read(alarmProvider.notifier).addAlarm(alarm);
    await StorageService().saveAlarm(alarm);
    await AlarmSchedulerService().scheduleAlarm(alarm);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Alarm'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('Alarm Time'),
              subtitle: Text(_selectedTime.format(context)),
              trailing: const Icon(Icons.access_time),
              onTap: _selectTime,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Grace Window: $_graceWindowMinutes minutes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Slider(
                    value: _graceWindowMinutes.toDouble(),
                    min: 5,
                    max: 30,
                    divisions: 5,
                    label: '$_graceWindowMinutes min',
                    onChanged: (value) {
                      setState(() => _graceWindowMinutes = value.toInt());
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Repeat',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (var day in [
                        (1, 'Mon'),
                        (2, 'Tue'),
                        (3, 'Wed'),
                        (4, 'Thu'),
                        (5, 'Fri'),
                        (6, 'Sat'),
                        (7, 'Sun')
                      ])
                        FilterChip(
                          label: Text(day.$2),
                          selected: _selectedDays.contains(day.$1),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedDays.add(day.$1);
                              } else {
                                _selectedDays.remove(day.$1);
                              }
                            });
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Accountability Contact',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contactNameController,
                    decoration: const InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _contactPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _customMessageController,
                    decoration: const InputDecoration(
                      labelText: 'Custom Message (Optional)',
                      hintText: 'Use {username} as placeholder',
                      border: OutlineInputBorder(),
                      helperText: 'Leave empty for default message',
                    ),
                    maxLines: 3,
                    maxLength: 160,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Preview: ${_customMessageController.text.isEmpty ? "{username} missed their Ventus alarm this morning! Time to check in on them 😴" : _customMessageController.text.replaceAll("{username}", "YourName")}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _saveAlarm,
            child: const Text('Save Alarm'),
          ),
        ],
      ),
    );
  }
}
