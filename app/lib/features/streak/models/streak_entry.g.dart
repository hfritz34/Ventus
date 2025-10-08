// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_entry.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StreakEntryAdapter extends TypeAdapter<StreakEntry> {
  @override
  final int typeId = 1;

  @override
  StreakEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StreakEntry(
      id: fields[0] as String?,
      userId: fields[1] as String,
      date: fields[2] as DateTime,
      success: fields[3] as bool,
      photoUrl: fields[4] as String?,
      alarmId: fields[5] as String,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, StreakEntry obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.success)
      ..writeByte(4)
      ..write(obj.photoUrl)
      ..writeByte(5)
      ..write(obj.alarmId)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakEntryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
