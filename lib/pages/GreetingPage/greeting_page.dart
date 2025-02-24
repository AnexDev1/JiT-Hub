// File: lib/pages/GreetingPage/greeting_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../HomePage/home_page.dart';

class GreetingPage extends StatefulWidget {
  const GreetingPage({super.key});

  @override
  _GreetingPageState createState() => _GreetingPageState();
}

class _GreetingPageState extends State<GreetingPage> {
  String _greetingMessage = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generateGreeting();
  }

  Future<String> _fetchGreetingData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firstName = prefs.getString('firstName') ?? 'User';
    String middleName = prefs.getString('middleName') ?? '';
    String department = prefs.getString('department') ?? 'no department';
    String studentId = prefs.getString('studentID') ?? '';
    String university = prefs.getString('universityName') ?? '';

    return 'Hi $firstName add space then $middleName converted to first letter upercase , welcome to $university. lowercase the unviersity name too '
        'You are a student of $department department with ID $studentId. say some good things about the department and if the $studentId starts with EU it means they are extension student and if it starts with RU and that means they are regular student , based on that motivate them to keep up . try to use emojis and style the texts ' ;
  }

  Future<void> _generateGreeting() async {
    String prompt = await _fetchGreetingData();
    await _sendRequestToAI(prompt);
  }

  Future<void> _sendRequestToAI(String prompt) async {
    setState(() {
      _isLoading = true;
    });

    Gemini.instance.prompt(parts: [
      Part.text(prompt)
    ]).then((value) {
      final output = value?.output ?? '';
      setState(() {
        _greetingMessage += '$output\n\n';
        _isLoading = false;
      });
    });
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A gradient background for a modern look
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
          ),
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 50.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: _isLoading
                ? const CircularProgressIndicator()
                : SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MarkdownBody(
                    data: _greetingMessage,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 18,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Update the go to home button in lib/pages/GreetingPage/greeting_page.dart

                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _goToHome,
                      style: TextButton.styleFrom(
                        backgroundColor: const Color(0xFF6200EA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // less rounded
                        ),
                      ),
                      child: const Text('Go to Home'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}