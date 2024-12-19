import 'package:hive/hive.dart';

part 'class_schedule_model.g.dart';

@HiveType(typeId: 1)
class ClassScheduleModel {
  @HiveField(0)
  final String day;

  @HiveField(1)
  final String time;

  @HiveField(2)
  final String course;

  @HiveField(3)
  final String room;

  ClassScheduleModel({
    required this.day,
    required this.time,
    required this.course,
    required this.room,
  });
}