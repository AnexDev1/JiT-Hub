import 'package:hive/hive.dart';

part 'schedule.g.dart';

@HiveType(typeId: 1)
class Schedule extends HiveObject {
  @HiveField(0)
  late String day;

  @HiveField(1)
  late String time;

  @HiveField(2)
  late String course;

  @HiveField(3)
  late String room;
}