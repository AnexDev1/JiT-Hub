// lib/services/reminder_service.dart
import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/reminder.dart';
import '../provider/reminder_provider.dart';
import 'notification_service.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;

  final Set<String> _notifiedReminderIds = {};
  Timer? _checkTimer;
  final NotificationService _notificationService = NotificationService();
  ReminderProvider? _reminderProvider;
  bool _isInitialized = false;

  ReminderService._internal();

  Future<void> initialize(ReminderProvider reminderProvider) async {
    if (_isInitialized) return;

    _reminderProvider = reminderProvider;
    await _notificationService.initialize();

    // Load notified reminders from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final notifiedIds = prefs.getStringList('notified_reminder_ids') ?? [];
    _notifiedReminderIds.addAll(notifiedIds);

    // Schedule initial notifications
    _scheduleAllNotifications();

    // Start periodic checks
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkPassedDeadlines();
    });

    // Call this to listen for app lifecycle changes
    listenToAppState();

    _isInitialized = true;

    // Force immediate check for any pending notifications
    _checkPassedDeadlines();
  }

  void _scheduleAllNotifications() {
    if (_reminderProvider == null) return;
    print("Scheduling all notifications. Reminders count: ${_reminderProvider!.reminders.length}");

    final now = DateTime.now();
    for (final reminder in _reminderProvider!.reminders) {
      final String reminderId = "${reminder.title}_${reminder.date.millisecondsSinceEpoch}";

      // Handle passed deadlines
      if (reminder.remindMe && reminder.date.isBefore(now) &&
          !_notifiedReminderIds.contains(reminderId)) {
        _scheduleNotification(
          reminder: reminder,
          title: "Deadline Passed: ${reminder.title}",
          body: "A reminder scheduled for ${DateFormat('h:mm a').format(reminder.date)} has passed",
        );
        _markAsNotified(reminderId);
      }

      // Handle upcoming notifications
      if (reminder.remindMe && reminder.date.isAfter(now)) {
        // Schedule the actual reminder notification
        _scheduleNotification(
          reminder: reminder,
          title: reminder.title,
          body: "It's time for your scheduled reminder!",
          scheduledDate: reminder.date,
        );

        // Schedule advance notifications
        _scheduleAdvanceNotification(reminder, const Duration(days: 1));
        _scheduleAdvanceNotification(reminder, const Duration(hours: 5));
        _scheduleAdvanceNotification(reminder, const Duration(hours: 1));
      }
    }
  }

  void _scheduleAdvanceNotification(Reminder reminder, Duration timeFrame) {
    final notificationTime = reminder.date.subtract(timeFrame);
    final now = DateTime.now();

    if (notificationTime.isAfter(now)) {
      String timeMessage = "";
      if (timeFrame.inDays >= 1) {
        timeMessage = "tomorrow";
      } else if (timeFrame.inHours >= 5) {
        timeMessage = "in 5 hours";
      } else {
        timeMessage = "in 1 hour";
      }

      _scheduleNotification(
        reminder: reminder,
        title: "Upcoming: ${reminder.title}",
        body: "You have a reminder due $timeMessage at ${DateFormat('h:mm a').format(reminder.date)}",
        scheduledDate: notificationTime,
      );
    }
  }

  Future<void> _scheduleNotification({
    required Reminder reminder,
    required String title,
    required String body,
    DateTime? scheduledDate,
  }) async {
    final DateTime notificationTime = scheduledDate ?? DateTime.now().add(const Duration(seconds: 1));

    final int notificationId = (reminder.date.millisecondsSinceEpoch % 1000000 +
        DateTime.now().millisecondsSinceEpoch % 1000) %
        2147483647;

    await _notificationService.scheduleNotification(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: notificationTime,
    );
  }

  void _checkPassedDeadlines() {
    if (_reminderProvider == null) return;

    final now = DateTime.now();
    for (final reminder in _reminderProvider!.reminders) {
      final String reminderId = "${reminder.title}_${reminder.date.millisecondsSinceEpoch}";

      if (reminder.remindMe && reminder.date.isBefore(now) &&
          !_notifiedReminderIds.contains(reminderId)) {
        _scheduleNotification(
          reminder: reminder,
          title: "Deadline Passed: ${reminder.title}",
          body: "A reminder scheduled for ${DateFormat('h:mm a').format(reminder.date)} has passed",
        );
        _markAsNotified(reminderId);
      }
    }
  }

  Future<void> _markAsNotified(String reminderId) async {
    _notifiedReminderIds.add(reminderId);

    // Save to persistent storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('notified_reminder_ids', _notifiedReminderIds.toList());
  }

  // Call this when reminders are updated
  void refreshNotifications() {
    _scheduleAllNotifications();
  }
  // Add to lib/services/reminder_service.dart

// Inside the ReminderService class
  void listenToAppState() {
    WidgetsBinding.instance.addObserver(
      AppLifecycleListener(
        onResume: () {
          // App came to foreground
          _scheduleAllNotifications();
        },
      ),
    );
  }
}