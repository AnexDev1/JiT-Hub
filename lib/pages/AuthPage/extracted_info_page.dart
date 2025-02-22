import 'package:flutter/material.dart';

class ExtractedInfoPage extends StatelessWidget {
  final String universityName;
  final String studentName;
  final String department;
  final String program;
  final String studentID;
  final String recognizedText;

  const ExtractedInfoPage({
    super.key,
    required this.universityName,
    required this.studentName,
    required this.department,
    required this.program,
    required this.studentID,
    required this.recognizedText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Extracted Information')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('University Name: $universityName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Student Name: $studentName', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Department: $department', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Program: $program', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Student ID: $studentID', style: const TextStyle(fontSize: 18)),

          ],
        ),
      ),
    );
  }
}