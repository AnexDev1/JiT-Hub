import 'package:flutter/material.dart';
import 'package:nex_planner/pages/Category/Tools/DailyReminder/reminder_modal.dart';

class DailyReminder extends StatefulWidget {
  const DailyReminder({super.key});

  @override
  _DailyReminderState createState() => _DailyReminderState();
}

class _DailyReminderState extends State<DailyReminder> {
  final List<Map<String, dynamic>> _reminders = [];

  void _addReminder(Map<String, dynamic> reminder) {
    setState(() {
      _reminders.add(reminder);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _reminders.isEmpty
          ? const Center(child: Text('You haven\'t added any tasks yet.'))
          : ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return ListTile(
                  title: Text(reminder['note']),
                  subtitle: Text(
                      '${reminder['date']} at ${reminder['time']} - ${reminder['category']}'),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => AddReminderModal(onAddReminder: _addReminder),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
