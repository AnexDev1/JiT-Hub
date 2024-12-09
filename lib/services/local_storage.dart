import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _remindersKey = 'reminders';
  static const String _classScheduleKey = 'class_schedule';

  Future<void> saveReminders(List<Map<String, dynamic>> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = jsonEncode(reminders);
    await prefs.setString(_remindersKey, remindersJson);
  }

  Future<List<Map<String, dynamic>>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final remindersJson = prefs.getString(_remindersKey);
    if (remindersJson != null) {
      final List<dynamic> remindersList = jsonDecode(remindersJson);
      return remindersList.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  Future<void> saveClassSchedule(
      List<Map<String, dynamic>> classSchedule) async {
    final prefs = await SharedPreferences.getInstance();
    final classScheduleJson = jsonEncode(classSchedule);
    await prefs.setString(_classScheduleKey, classScheduleJson);
  }

  Future<List<Map<String, dynamic>>> loadClassSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final classScheduleJson = prefs.getString(_classScheduleKey);
    if (classScheduleJson != null) {
      final List<dynamic> classScheduleList = jsonDecode(classScheduleJson);
      return classScheduleList.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }
}
