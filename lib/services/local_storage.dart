import 'package:hive/hive.dart';
import 'package:nex_planner/model/reminder.dart';

class LocalStorageService {
  static const String _remindersBox = 'remindersBox';
  static const String _classScheduleBox = 'classScheduleBox';

  Future<void> saveReminders(List<Reminder> reminders) async {
    final box = await Hive.openBox<Reminder>(_remindersBox);
    await box.clear();
    for (var reminder in reminders) {
      await box.add(reminder);
    }
  }

  Future<List<Reminder>> loadReminders() async {
    final box = await Hive.openBox<Reminder>(_remindersBox);
    return box.values.toList();
  }

  Future<void> saveClassSchedule(List<Map<String, dynamic>> classSchedule) async {
    final box = await Hive.openBox<Map<String, dynamic>>(_classScheduleBox);
    await box.clear();
    for (var schedule in classSchedule) {
      await box.add(schedule);
    }
  }

  Future<List<Map<String, dynamic>>> loadClassSchedule() async {
    final box = await Hive.openBox<Map<String, dynamic>>(_classScheduleBox);
    return box.values.toList();
  }
}