// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_schedule_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClassScheduleModelAdapter extends TypeAdapter<ClassScheduleModel> {
  @override
  final int typeId = 1;

  @override
  ClassScheduleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClassScheduleModel(
      day: fields[0] as String,
      time: fields[1] as String,
      course: fields[2] as String,
      room: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ClassScheduleModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.day)
      ..writeByte(1)
      ..write(obj.time)
      ..writeByte(2)
      ..write(obj.course)
      ..writeByte(3)
      ..write(obj.room);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClassScheduleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
