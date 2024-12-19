import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nex_planner/model/reminder.dart';

class ReminderProvider with ChangeNotifier {
  List<Reminder> _reminders = [];

  List<Reminder> get reminders => _reminders;

  void loadReminders() {
    final reminderBox = Hive.box<Reminder>('remindersBox');
    _reminders = reminderBox.values.toList();
    notifyListeners();
  }

  void addReminder(Reminder reminder) {
    final reminderBox = Hive.box<Reminder>('remindersBox');
    reminderBox.add(reminder);
    loadReminders();
  }

  void deleteReminder(int index) {
    final reminderBox = Hive.box<Reminder>('remindersBox');
    reminderBox.deleteAt(index);
    loadReminders();
  }
}