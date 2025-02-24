// File: lib/pages/AuthPage/register_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:nex_planner/pages/GreetingPage/greeting_page.dart';
import '../HomePage/home_page.dart';
import 'extracted_info_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  Future<void> _captureAndProcessImage(BuildContext context) async {
    final ImagePicker _picker = ImagePicker();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return;

      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

      String rawText = recognizedText.text;
      print(rawText);
      List<String> lines = rawText.split('\n');

      String universityName = '';
      String studentName = '';
      String department = '';
      String studentID = '';

      // Define regex to detect a line with full uppercase letters and spaces
      RegExp fullNameRegex = RegExp(r'^[A-Z\s]+$');

      // Loop through each line and check patterns
      for (String line in lines) {
        String trimmed = line.trim();
        if (trimmed.isEmpty) continue;

        // Check for 'Jimma University'
        if (universityName.isEmpty &&
            trimmed.toLowerCase().contains('jimma university')) {
          universityName = trimmed;
          continue;
        }

        // Check for student ID from lines starting with 'RU' or 'EU'
        if (studentID.isEmpty &&
            (trimmed.startsWith('RU') || trimmed.startsWith('EU'))) {
          studentID = trimmed;
          continue;
        }

        // Check for department indicators
        if (department.isEmpty &&
            (trimmed.contains('B.Sc') ||
                trimmed.contains('B.A') ||
                trimmed.contains('M.Sc') ||
                trimmed.contains('M.A'))) {
          department = trimmed;
          continue;
        }

        // Check if the line is entirely uppercase using the regex for student name
        if (studentName.isEmpty && fullNameRegex.hasMatch(trimmed)) {
          studentName = trimmed;
          continue;
        }
      }

      textRecognizer.close();

      // Split the full name into first and middle names
      List<String> nameParts = studentName.split(RegExp(r'\s+'));
      String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      String middleName = nameParts.length > 1 ? nameParts[1] : '';

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('universityName', universityName);
      await prefs.setString('studentName', studentName);
      await prefs.setString('department', department);
      await prefs.setString('studentID', studentID);
      await prefs.setString('firstName', firstName);
      await prefs.setString('middleName', middleName);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('isGuest', false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const GreetingPage()),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loginAsGuest(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> restrictedItems = [
      {
        'icon': Icons.calendar_today,
        'title': 'Academic Calendar',
        'subtitle': ' Details about academic schedules',
      },
      {
        'icon': Icons.local_cafe,
        'title': 'Cafe Menu',
        'subtitle': 'Exclusive cafe offers',
      },
      {
        'icon': Icons.computer,
        'title': 'Study AI',
        'subtitle': 'Access to AI study tools',
      },
      {
        'icon': Icons.schedule,
        'title': 'Class Schedule',
        'subtitle': 'Personalized class timings',
      },
      {
        'icon': Icons.photo_album,
        'title': 'Gallery',
        'subtitle': 'Access to exclusive gallery content',
      },
      {
        'icon': Icons.account_balance,
        'title': 'Religious',
        'subtitle': 'Details about religious events',
      },
    ];

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'lib/assets/verification.jpeg',
                height: 300,
              ),
              const SizedBox(height: 20),
              const Text(
                'Verify ID for Full Access',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Complete the process in just a few steps to verify your profile',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: restrictedItems.length,
                  itemBuilder: (context, index) {
                    final item = restrictedItems[index];
                    return ListTile(
                      leading: Icon(item['icon']),
                      title: Text(item['title']),
                      subtitle: Text(item['subtitle']),
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _captureAndProcessImage(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                          Theme.of(context).colorScheme.secondary,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Jost',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Scan ID',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _loginAsGuest(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Jost',
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: const Text(
                          'Login as Guest',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}