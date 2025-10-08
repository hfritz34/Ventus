import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'alarm.g.dart';

@HiveType(typeId: 0)
class Alarm {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime alarmTime;

  @HiveField(2)
  final int graceWindowMinutes;

  @HiveField(3)
  final bool isActive;

  @HiveField(4)
  final List<int> repeatDays; // 1=Monday, 7=Sunday

  @HiveField(5)
  final String? accountabilityContactName;

  @HiveField(6)
  final String? accountabilityContactPhone;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final String? customAccountabilityMessage;

  Alarm({
    String? id,
    required this.alarmTime,
    this.graceWindowMinutes = 15,
    this.isActive = true,
    this.repeatDays = const [],
    this.accountabilityContactName,
    this.accountabilityContactPhone,
    this.customAccountabilityMessage,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  /// Check if alarm can be edited (must be >1 hour until next alarm time)
  bool canEdit() {
    final now = DateTime.now();

    // If alarm has repeat days, check next occurrence
    if (repeatDays.isNotEmpty) {
      final nextAlarm = _getNextAlarmTime();
      return nextAlarm.difference(now).inHours >= 1;
    }

    // For one-time alarms
    return alarmTime.difference(now).inHours >= 1;
  }

  /// Get next alarm time considering repeat days
  DateTime _getNextAlarmTime() {
    final now = DateTime.now();
    final todayAlarm = DateTime(
      now.year,
      now.month,
      now.day,
      alarmTime.hour,
      alarmTime.minute,
    );

    if (repeatDays.isEmpty) {
      return todayAlarm.isAfter(now) ? todayAlarm : todayAlarm.add(const Duration(days: 1));
    }

    // Find next occurrence from repeat days
    for (int i = 0; i < 7; i++) {
      final checkDate = now.add(Duration(days: i));
      final weekday = checkDate.weekday; // 1=Monday, 7=Sunday

      if (repeatDays.contains(weekday)) {
        final alarmDateTime = DateTime(
          checkDate.year,
          checkDate.month,
          checkDate.day,
          alarmTime.hour,
          alarmTime.minute,
        );

        if (alarmDateTime.isAfter(now)) {
          return alarmDateTime;
        }
      }
    }

    return todayAlarm;
  }

  Alarm copyWith({
    String? id,
    DateTime? alarmTime,
    int? graceWindowMinutes,
    bool? isActive,
    List<int>? repeatDays,
    String? accountabilityContactName,
    String? accountabilityContactPhone,
    String? customAccountabilityMessage,
    DateTime? createdAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      alarmTime: alarmTime ?? this.alarmTime,
      graceWindowMinutes: graceWindowMinutes ?? this.graceWindowMinutes,
      isActive: isActive ?? this.isActive,
      repeatDays: repeatDays ?? this.repeatDays,
      accountabilityContactName: accountabilityContactName ?? this.accountabilityContactName,
      accountabilityContactPhone: accountabilityContactPhone ?? this.accountabilityContactPhone,
      customAccountabilityMessage: customAccountabilityMessage ?? this.customAccountabilityMessage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'alarmTime': alarmTime.toIso8601String(),
      'graceWindowMinutes': graceWindowMinutes,
      'isActive': isActive,
      'repeatDays': repeatDays,
      'accountabilityContactName': accountabilityContactName,
      'accountabilityContactPhone': accountabilityContactPhone,
      'customAccountabilityMessage': customAccountabilityMessage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Alarm.fromJson(Map<String, dynamic> json) {
    return Alarm(
      id: json['id'] as String,
      alarmTime: DateTime.parse(json['alarmTime'] as String),
      graceWindowMinutes: json['graceWindowMinutes'] as int,
      isActive: json['isActive'] as bool,
      repeatDays: (json['repeatDays'] as List<dynamic>).cast<int>(),
      accountabilityContactName: json['accountabilityContactName'] as String?,
      accountabilityContactPhone: json['accountabilityContactPhone'] as String?,
      customAccountabilityMessage: json['customAccountabilityMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Get the accountability message with username substitution
  String getAccountabilityMessage(String username) {
    if (customAccountabilityMessage != null && customAccountabilityMessage!.isNotEmpty) {
      return customAccountabilityMessage!.replaceAll('{username}', username);
    }
    return '$username missed their Ventus alarm this morning! Time to check in on them 😴';
  }
}
