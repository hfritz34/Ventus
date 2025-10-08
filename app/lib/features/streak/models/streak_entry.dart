import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'streak_entry.g.dart';

@HiveType(typeId: 1)
class StreakEntry {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final bool success; // true if woke up on time with outdoor photo

  @HiveField(4)
  final String? photoUrl; // S3 URL or local path to photo

  @HiveField(5)
  final String alarmId;

  @HiveField(6)
  final DateTime createdAt;

  StreakEntry({
    String? id,
    required this.userId,
    required this.date,
    required this.success,
    this.photoUrl,
    required this.alarmId,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  StreakEntry copyWith({
    String? id,
    String? userId,
    DateTime? date,
    bool? success,
    String? photoUrl,
    String? alarmId,
    DateTime? createdAt,
  }) {
    return StreakEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      success: success ?? this.success,
      photoUrl: photoUrl ?? this.photoUrl,
      alarmId: alarmId ?? this.alarmId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'date': date.toIso8601String(),
      'success': success,
      'photoUrl': photoUrl,
      'alarmId': alarmId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory StreakEntry.fromJson(Map<String, dynamic> json) {
    return StreakEntry(
      id: json['id'] as String,
      userId: json['userId'] as String,
      date: DateTime.parse(json['date'] as String),
      success: json['success'] as bool,
      photoUrl: json['photoUrl'] as String?,
      alarmId: json['alarmId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
