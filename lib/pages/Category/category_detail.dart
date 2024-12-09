// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'Tools/grade_calculator.dart';
import 'Tools/ClassSchedule/class_schedule.dart';
import 'Tools/DailyReminder/daily_reminder.dart';
import 'Tools/note_saver.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final Map<String, Widget> categoryWidgets = {
      'Grade Calculator': const GradeCalculator(),
      'Class Schedule': const ClassSchedule(),
      'Daily Reminder': const DailyReminder(),
      'Note Saver': const NoteSaver(),
    };

    return categoryWidgets[categoryName] ??
        Center(child: Text('Content for $categoryName'));
  }
}
