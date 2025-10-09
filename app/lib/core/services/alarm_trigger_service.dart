import 'dart:convert';
import 'package:logger/logger.dart';

class AlarmTriggerService {
  static final AlarmTriggerService _instance = AlarmTriggerService._internal();
  factory AlarmTriggerService() => _instance;
  AlarmTriggerService._internal();

  final Logger _logger = Logger();
  String? _activeAlarmId;
  DateTime? _graceDeadline;
  Function(String)? _navigationCallback;

  void setNavigationCallback(Function(String) callback) {
    _navigationCallback = callback;
  }

  void handleAlarmTrigger(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final alarmId = data['alarmId'] as String;
      final graceMinutes = data['graceMinutes'] as int;

      _activeAlarmId = alarmId;
      _graceDeadline = DateTime.now().add(Duration(minutes: graceMinutes));

      _logger.i('Alarm triggered: $alarmId, grace until: $_graceDeadline');

      _navigationCallback?.call('/camera');
    } catch (e) {
      _logger.e('Error handling alarm trigger: $e');
    }
  }

  String? get activeAlarmId => _activeAlarmId;
  DateTime? get graceDeadline => _graceDeadline;

  void clearActiveAlarm() {
    _activeAlarmId = null;
    _graceDeadline = null;
  }

  bool get hasActiveAlarm => _activeAlarmId != null;
}
