import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import 'package:app/features/alarm/models/alarm.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final Logger _logger = Logger();
  static const String _alarmBoxName = 'alarms';

  Future<void> initialize() async {
    await Hive.initFlutter();
    Hive.registerAdapter(AlarmAdapter());
    await Hive.openBox<Alarm>(_alarmBoxName);
    _logger.i('Storage service initialized');
  }

  Box<Alarm> get alarmBox => Hive.box<Alarm>(_alarmBoxName);

  Future<void> saveAlarm(Alarm alarm) async {
    await alarmBox.put(alarm.id, alarm);
    _logger.i('Alarm saved: ${alarm.id}');
  }

  Future<void> deleteAlarm(String alarmId) async {
    await alarmBox.delete(alarmId);
    _logger.i('Alarm deleted: $alarmId');
  }

  List<Alarm> getAllAlarms() {
    return alarmBox.values.toList();
  }

  Alarm? getAlarm(String alarmId) {
    return alarmBox.get(alarmId);
  }

  Future<void> clearAllAlarms() async {
    await alarmBox.clear();
    _logger.i('All alarms cleared');
  }
}
