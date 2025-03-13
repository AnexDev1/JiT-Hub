import 'package:flutter/material.dart';
import 'package:nex_planner/pages/HomePage/Category/campus_services/cafe_menu.dart';
import 'package:nex_planner/pages/HomePage/Category/campus_services/campus_navigation_page.dart';

import 'Academics/about_jit.dart';
import 'Academics/calendar/academic_calendar.dart';
import 'Academics/departments.dart';
import 'Campus_life/religious_page.dart';
import 'Campus_life/gallery.dart';
import 'Tools/gradeCalculator/grade_calculator.dart';
import 'Tools/ClassSchedule/class_schedule.dart';
import 'Tools/DailyReminder/daily_reminder.dart';
import 'Tools/studyAI/study_ai.dart';

class CategoryList extends StatelessWidget {
  final String categoryName;
  const CategoryList({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      'Cafe Menu': const CafeMenu(),
      'Religious': const ReligiousPage(),
      'Campus Navigation': const CampusNavigationPage(),
      'Gallery': const GalleryPage(),
    };

    return categoryWidgets[categoryName] ??
        Center(child: Text('Content for $categoryName'));
  }
}
