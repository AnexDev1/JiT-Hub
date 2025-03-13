import 'dart:ui';

class ScheduleItem {
  final String subject;
  final String time;
  final String location;
  final String instructor;
  final Color color;

  ScheduleItem({
    required this.subject,
    required this.time,
    required this.location,
    required this.instructor,
    required this.color,
  });
}