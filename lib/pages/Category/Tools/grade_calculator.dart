import 'package:flutter/material.dart';
import 'package:nex_planner/services/grade_calculator.dart';

class GradeCalculator extends StatefulWidget {
  const GradeCalculator({Key? key}) : super(key: key);

  @override
  _GradeCalculatorState createState() => _GradeCalculatorState();
}

class _GradeCalculatorState extends State<GradeCalculator> {
  final GradeCalculatorLogic _logic = GradeCalculatorLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
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
                      ..._logic.courses.map((course) {
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
                                  items: List.generate(10, (index) {
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
                                  items: ['A', 'B', 'C', 'D', 'F'].map((grade) {
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
                        onPressed: () {
                          setState(() {
                            _logic.addCourse();
                          });
                        },
                        child: const Text('Add'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _logic.calculateGPA();
                          });
                        },
                        child: const Text('Calculate'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _logic.resetFields();
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Credit Hours:'),
                      Text('${_logic.totalCreditHours}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('GPA:'),
                      Text(_logic.gpa.toStringAsFixed(2)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
