import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../provider/reminder_provider.dart';
import 'Category/Tools/DailyReminder/daily_reminder.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final assignmentCount = reminderProvider.reminders.where((r) => r.category == 'Assignment').length;
    final examCount = reminderProvider.reminders.where((r) => r.category == 'Exam').length;
    final studyCount = reminderProvider.reminders.where((r) => r.category == 'Study').length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6767B3), Color(0xFF6431F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: <Widget>[
          SvgPicture.asset('lib/assets/image1.svg', width: 130, height: 130),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Daily Reminder', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('$assignmentCount assignment', style: const TextStyle(color: Colors.white)),
                Text('$examCount test', style: const TextStyle(color: Colors.white)),
                Text('$studyCount other', style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 3),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size(0, 30),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const DailyReminder(),
                    ));
                  },
                  child: const Text('Add Task', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}