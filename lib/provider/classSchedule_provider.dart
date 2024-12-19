import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../model/schedule.dart';

class ClassScheduleProvider with ChangeNotifier {
  late Box<Schedule> _scheduleBox;

  ClassScheduleProvider() {
    _init();
  }

  Future<void> _init() async {
    _scheduleBox = await Hive.openBox<Schedule>('schedules');
    notifyListeners();
  }

  List<Schedule> getSchedules(String day) {
    return _scheduleBox.values.where((schedule) => schedule.day == day).toList();
  }

  Future<void> addSchedule(Schedule schedule) async {
    await _scheduleBox.add(schedule);
    notifyListeners();
  }

  Future<void> deleteSchedule(Schedule schedule) async {
    await schedule.delete();
    notifyListeners();
  }
}