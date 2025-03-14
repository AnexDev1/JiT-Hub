import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:nex_planner/model/reminder.dart';
import 'package:nex_planner/services/reminder_service.dart';

class ReminderProvider with ChangeNotifier {
  List<Reminder> _reminders = [];

  List<Reminder> get reminders => _reminders;

  Future<void> loadReminders() async {
    final reminderBox = Hive.box<Reminder>('remindersBox');
    _reminders = reminderBox.values.toList();
    notifyListeners();
  }

  Future<void> addReminder(Reminder reminder) async {
    final reminderBox = Hive.box<Reminder>('remindersBox');
    reminderBox.add(reminder);
    ReminderService().refreshNotifications();
    loadReminders();
  }

  Future<void> deleteReminder(int index) async {
    final reminderBox = Hive.box<Reminder>('remindersBox');
    reminderBox.deleteAt(index);
    ReminderService().refreshNotifications();
    loadReminders();
  }

  Future<void> updateReminder(int index, Reminder reminder) async {
    final reminderBox = Hive.box<Reminder>('remindersBox');
    reminderBox.putAt(index, reminder);
    ReminderService().refreshNotifications();
    loadReminders();
  }
}