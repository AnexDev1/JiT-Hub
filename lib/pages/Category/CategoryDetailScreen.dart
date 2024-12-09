import 'package:flutter/material.dart';
import 'Tools/GradeCalculator.dart';
import 'Tools/ClassSchedule/ClassSchedule.dart';
import 'Tools/DailyReminder/DailyReminder.dart';
import 'Tools/NoteSaver.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  const CategoryDetailScreen({Key? key, required this.categoryName})
      : super(key: key);

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
