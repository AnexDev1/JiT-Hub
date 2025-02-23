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
      final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

      String text = recognizedText.text;
      List<String> lines = text.split('\n');
      String universityName = lines.isNotEmpty ? lines[0].trim() : '';
      String studentName = lines.length > 2 ? lines[2].trim() : '';
      String department = lines.length > 3 ? lines[3].trim() : '';
      String program = lines.length > 4 ? lines[4].trim() : '';
      String studentID = lines.length > 5 ? lines[5].trim() : '';
      String firstName = studentName.split(' ').first;

      textRecognizer.close();

      // Save data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('universityName', universityName);
      await prefs.setString('studentName', studentName);
      await prefs.setString('department', department);
      await prefs.setString('program', program);
      await prefs.setString('studentID', studentID);
      await prefs.setString('firstName', firstName);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('isGuest', false);

      // Navigate to GreetingPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const GreetingPage(),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> _loginAsGuest(BuildContext context) async {
    // Set guest flag and navigate to GreetingPage
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // List of restricted modules for guest users
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
              // Displaying the list of restricted items
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
                          backgroundColor: Theme.of(context).colorScheme.secondary,
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