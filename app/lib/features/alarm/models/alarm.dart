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

  Alarm({
    String? id,
    required this.alarmTime,
    this.graceWindowMinutes = 15,
    this.isActive = true,
    this.repeatDays = const [],
    this.accountabilityContactName,
    this.accountabilityContactPhone,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Alarm copyWith({
    String? id,
    DateTime? alarmTime,
    int? graceWindowMinutes,
    bool? isActive,
    List<int>? repeatDays,
    String? accountabilityContactName,
    String? accountabilityContactPhone,
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
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
