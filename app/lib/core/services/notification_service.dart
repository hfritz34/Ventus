import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:app/core/services/alarm_trigger_service.dart';
import 'package:app/core/services/notification_settings_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _logger.i('Notification service initialized');
  }

  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('Notification tapped: ${response.id}');
    if (response.payload != null) {
      AlarmTriggerService().handleAlarmTrigger(response.payload!);
    }
  }

  Future<void> scheduleAlarm({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Load user notification settings
    final settings = await NotificationSettingsService().getSettings();

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_channel',
          'Alarms',
          channelDescription: 'Channel for alarm notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: settings.soundEnabled,
          enableVibration: settings.vibrationEnabled,
          fullScreenIntent: true,
          // Note: Custom sound types would require additional sound files
          // For now, we just respect the sound on/off setting
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: settings.soundEnabled,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    _logger.i('Alarm scheduled for $scheduledTime with id $id (sound: ${settings.soundEnabled}, vibration: ${settings.vibrationEnabled})');
  }

  Future<void> cancelAlarm(int id) async {
    await _notifications.cancel(id);
    _logger.i('Alarm cancelled: $id');
  }

  Future<void> cancelAllAlarms() async {
    await _notifications.cancelAll();
    _logger.i('All alarms cancelled');
  }
}
