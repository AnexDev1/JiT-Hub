import 'package:flutter/material.dart';

class GradeCalculatorLogic {
  final List<Map<String, dynamic>> _courses = [
    {'course': TextEditingController(), 'creditHour': null, 'grade': null},
    {'course': TextEditingController(), 'creditHour': null, 'grade': null},
    {'course': TextEditingController(), 'creditHour': null, 'grade': null},
  ];

  int _totalCreditHours = 0;
  double _gpa = 0.0;

  List<Map<String, dynamic>> get courses => _courses;
  int get totalCreditHours => _totalCreditHours;
  double get gpa => _gpa;

  void addCourse() {
    _courses.add(
        {'course': TextEditingController(), 'creditHour': null, 'grade': null});
  }

  void calculateGPA() {
    int totalCreditHours = 0;
    double totalPoints = 0.0;

    for (var course in _courses) {
      if (course['creditHour'] != null && course['grade'] != null) {
        totalCreditHours += course['creditHour'] as int;
        totalPoints += course['creditHour'] * _gradeToPoint(course['grade']);
      }
    }

    _totalCreditHours = totalCreditHours;
    _gpa = totalCreditHours > 0 ? totalPoints / totalCreditHours : 0.0;
  }

  void resetFields() {
    _courses.clear();
    for (int i = 0; i < 3; i++) {
      _courses.add(
          {'course': TextEditingController(), 'creditHour': null, 'grade': null});
    }
    _totalCreditHours = 0;
    _gpa = 0.0;
  }

  double _gradeToPoint(String grade) {
    switch (grade) {
      case 'A+':
        return 4.0;
      case 'A':
        return 4.0;
      case 'A-':
        return 3.75;
      case 'B+':
        return 3.50;
      case 'B':
        return 3.0;
      case 'B-':
        return 2.75;
      case 'C+':
        return 2.50;
      case 'C':
        return 2.0;
      case 'D':
        return 1.0;
      case 'F':
        return 0.0;
      default:
        return 0.0;
    }
  }
}