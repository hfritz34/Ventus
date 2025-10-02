import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app/features/alarm/models/alarm.dart';

class AlarmNotifier extends StateNotifier<List<Alarm>> {
  AlarmNotifier() : super([]);

  void addAlarm(Alarm alarm) {
    state = [...state, alarm];
  }

  void updateAlarm(Alarm updatedAlarm) {
    state = [
      for (final alarm in state)
        if (alarm.id == updatedAlarm.id) updatedAlarm else alarm,
    ];
  }

  void deleteAlarm(String alarmId) {
    state = state.where((alarm) => alarm.id != alarmId).toList();
  }

  void toggleAlarm(String alarmId) {
    state = [
      for (final alarm in state)
        if (alarm.id == alarmId)
          alarm.copyWith(isActive: !alarm.isActive)
        else
          alarm,
    ];
  }

  void loadAlarms(List<Alarm> alarms) {
    state = alarms;
  }
}

final alarmProvider = StateNotifierProvider<AlarmNotifier, List<Alarm>>((ref) {
  return AlarmNotifier();
});
