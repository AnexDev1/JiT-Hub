import 'package:flutter/material.dart';
import 'package:nex_planner/services/local_storage.dart';
import 'reminder_modal.dart';

class DailyReminder extends StatefulWidget {
  @override
  _DailyReminderState createState() => _DailyReminderState();
}

class _DailyReminderState extends State<DailyReminder> {
  final List<Map<String, dynamic>> _reminders = [];
  final LocalStorageService _localStorageService = LocalStorageService();

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final reminders = await _localStorageService.loadReminders();
    setState(() {
      _reminders.addAll(reminders);
    });
  }

  void _addReminder(Map<String, dynamic> reminder) {
    setState(() {
      _reminders.add(reminder);
    });
    _localStorageService.saveReminders(_reminders);
  }

  void _deleteReminder(int index) {
    setState(() {
      _reminders.removeAt(index);
    });
    _localStorageService.saveReminders(_reminders);
  }

  void _refreshReminders() {
    _loadReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daily Reminders'),
      ),
      body: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return Card(
            color: Colors.lightBlue[50],
            margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: Icon(Icons.alarm),
              title: Text(
                reminder['note'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                '${reminder['date']} at ${reminder['time']}\nCategory: ${reminder['category']}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (reminder['remindMe'])
                    Icon(Icons.notifications_active, color: Colors.red),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      _deleteReminder(index);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return ReminderModal(
                onAddReminder: _addReminder,
                onAddReminderCallback: _refreshReminders,
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
