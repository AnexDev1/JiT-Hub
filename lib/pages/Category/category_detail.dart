

import 'package:flutter/material.dart';
import 'package:nex_planner/pages/Category/Academics/about_jit.dart';
import 'package:nex_planner/pages/Category/Academics/departments.dart';
import 'package:nex_planner/pages/Category/Tools/study_ai.dart';
import 'Academics/calendar/academic_calendar.dart';
import 'Tools/grade_calculator.dart';
import 'Tools/ClassSchedule/class_schedule.dart';
import 'Tools/DailyReminder/daily_reminder.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryName;
  const CategoryDetailScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(categoryName),
      // ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    final Map<String, Widget> categoryWidgets = {
      'Departments': Departments(),
      'About JIT': const AboutJit(),
      'Academic Calendar': const AcademicCalendar(),
      'Grade Calculator': const GradeCalculator(),
      'Class Schedule': const ClassSchedule(),
      'Daily Reminder': const DailyReminder(),
      'Study AI': const StudyAI(),
      // 'Google': const WebViewPage(url: 'https://google.com'),
    };

    return categoryWidgets[categoryName] ??
        Center(child: Text('Content for $categoryName'));
  }
}
