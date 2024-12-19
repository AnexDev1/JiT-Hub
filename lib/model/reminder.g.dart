// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderAdapter extends TypeAdapter<Reminder> {
  @override
  final int typeId = 0;

  @override
  Reminder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Reminder(
      title: fields[0] as String,
      date: fields[1] as DateTime,
      category: fields[3] as String,
      remindMe: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Reminder obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.remindMe);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
