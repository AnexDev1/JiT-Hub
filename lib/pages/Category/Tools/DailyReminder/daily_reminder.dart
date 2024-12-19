import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/reminder_provider.dart';
import 'reminder_modal.dart';

class DailyReminder extends StatelessWidget {
  const DailyReminder({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reminders'),
      ),
      body: reminderProvider.reminders.isEmpty
          ? const Center(child: Text('No reminders yet!'))
          : ListView.builder(
        itemCount: reminderProvider.reminders.length,
        itemBuilder: (context, index) {
          final reminder = reminderProvider.reminders[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: const Icon(Icons.alarm),
              title: Text(reminder.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${reminder.date.toLocal().toString().split(' ')[0]} at ${reminder.date.toLocal().toString().split(' ')[1]}\nCategory: ${reminder.category}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (reminder.remindMe) const Icon(Icons.notifications_active, color: Colors.red),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      reminderProvider.deleteReminder(index);
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
                onAddReminder: reminderProvider.loadReminders,
                onAddReminderCallback: reminderProvider.loadReminders,
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}