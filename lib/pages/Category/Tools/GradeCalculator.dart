import 'package:flutter/material.dart';

class GradeCalculator extends StatefulWidget {
  const GradeCalculator({Key? key}) : super(key: key);

  @override
  _GradeCalculatorState createState() => _GradeCalculatorState();
}

class _GradeCalculatorState extends State<GradeCalculator> {
  final List<Map<String, dynamic>> _courses = [
    {'course': TextEditingController(), 'creditHour': null, 'grade': null},
    {'course': TextEditingController(), 'creditHour': null, 'grade': null},
    {'course': TextEditingController(), 'creditHour': null, 'grade': null},
  ];

  int _totalCreditHours = 0;
  double _gpa = 0.0;

  void _addCourse() {
    setState(() {
      _courses.add({
        'course': TextEditingController(),
        'creditHour': null,
        'grade': null
      });
    });
  }

  void _calculateGPA() {
    int totalCreditHours = 0;
    double totalPoints = 0.0;

    for (var course in _courses) {
      if (course['creditHour'] != null && course['grade'] != null) {
        totalCreditHours += course['creditHour'] as int;
        totalPoints += course['creditHour'] * _gradeToPoint(course['grade']);
      }
    }

    setState(() {
      _totalCreditHours = totalCreditHours;
      _gpa = totalCreditHours > 0 ? totalPoints / totalCreditHours : 0.0;
    });
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

  void _resetFields() {
    setState(() {
      _courses.clear();
      _courses.addAll([
        {'course': TextEditingController(), 'creditHour': null, 'grade': null},
        {'course': TextEditingController(), 'creditHour': null, 'grade': null},
        {'course': TextEditingController(), 'creditHour': null, 'grade': null},
      ]);
      _totalCreditHours = 0;
      _gpa = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              Table(
                border: TableBorder.all(),
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    children: [
                      TableCell(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Course'),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Credit Hour'),
                        ),
                      ),
                      TableCell(
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text('Grade'),
                        ),
                      ),
                    ],
                  ),
                  ..._courses.map((course) {
                    return TableRow(
                      children: [
                        TableCell(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: TextField(
                              controller: course['course'],
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter course',
                              ),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<int>(
                              isExpanded: true,
                              value: course['creditHour'],
                              items: List.generate(6, (index) {
                                return DropdownMenuItem(
                                  value: index + 1,
                                  child: Text('${index + 1}'),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  course['creditHour'] = value;
                                });
                              },
                              hint: const Text('Select'),
                            ),
                          ),
                        ),
                        TableCell(
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: course['grade'],
                              items: [
                                'A+',
                                'A',
                                'A-',
                                'B+',
                                'B',
                                'B-',
                                'C+',
                                'C',
                                'D',
                                'F'
                              ].map((grade) {
                                return DropdownMenuItem(
                                  value: grade,
                                  child: Text(grade),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  course['grade'] = value;
                                });
                              },
                              hint: const Text('Select'),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _addCourse,
                    child: const Text('Add'),
                  ),
                  ElevatedButton(
                    onPressed: _calculateGPA,
                    child: const Text('Calculate'),
                  ),
                  ElevatedButton(
                    onPressed: _resetFields,
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Credit Hours:'),
                  Text('$_totalCreditHours'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GPA:'),
                  Text(_gpa.toStringAsFixed(2)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
