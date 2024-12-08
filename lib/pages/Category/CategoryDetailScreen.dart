import 'package:flutter/material.dart';
import 'Tools/GradeCalculator.dart';
import 'Tools/ClassSchedule.dart';
import 'Tools/DailyReminder.dart';
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
    switch (categoryName) {
      case 'Grade Calculator':
        return const GradeCalculator();
      case 'Class Schedule':
        return const ClassSchedule();
      case 'Daily Reminder':
        return const DailyReminder();
      case 'Note Saver':
        return const NoteSaver();
      default:
        return Center(child: Text('Content for $categoryName'));
    }
  }
}
