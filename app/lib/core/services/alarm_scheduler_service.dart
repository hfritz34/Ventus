import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:app/features/alarm/models/alarm.dart';
import 'package:app/core/services/notification_service.dart';

class AlarmSchedulerService {
  static final AlarmSchedulerService _instance = AlarmSchedulerService._internal();
  factory AlarmSchedulerService() => _instance;
  AlarmSchedulerService._internal();

  final Logger _logger = Logger();
  final _notificationService = NotificationService();

  int _generateNotificationId(String alarmId) {
    return alarmId.hashCode.abs() % 2147483647;
  }

  String _createPayload(Alarm alarm) {
    return jsonEncode({
      'alarmId': alarm.id,
      'graceMinutes': alarm.graceWindowMinutes,
    });
  }

  DateTime _getNextAlarmTime(Alarm alarm) {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.alarmTime.hour,
      alarm.alarmTime.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    if (alarm.repeatDays.isNotEmpty) {
      while (!alarm.repeatDays.contains(scheduledTime.weekday)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
    }

    return scheduledTime;
  }

  Future<void> scheduleAlarm(Alarm alarm) async {
    if (!alarm.isActive) {
      _logger.i('Skipping inactive alarm: ${alarm.id}');
      return;
    }

    final scheduledTime = _getNextAlarmTime(alarm);
    final notificationId = _generateNotificationId(alarm.id);

    await _notificationService.scheduleAlarm(
      id: notificationId,
      title: 'Wake up!',
      body: 'Time to take your outdoor selfie. You have ${alarm.graceWindowMinutes} minutes.',
      scheduledTime: scheduledTime,
      payload: _createPayload(alarm),
    );

    _logger.i('Scheduled alarm ${alarm.id} for $scheduledTime');
  }

  Future<void> cancelAlarm(Alarm alarm) async {
    final notificationId = _generateNotificationId(alarm.id);
    await _notificationService.cancelAlarm(notificationId);
    _logger.i('Cancelled alarm: ${alarm.id}');
  }

  Future<void> rescheduleAlarm(Alarm alarm) async {
    await cancelAlarm(alarm);
    await scheduleAlarm(alarm);
  }
}
