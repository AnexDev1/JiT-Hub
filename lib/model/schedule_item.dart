import 'dart:ui';

class ScheduleItem {
  final String courseName;
  final String time;
  final String roomNo;

  final Color color;

  ScheduleItem({
    required this.courseName,
    required this.time,
    required this.roomNo,

    required this.color,
  });
}