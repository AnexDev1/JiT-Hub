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

  Future<void> _generateGreeting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String firstName = prefs.getString('firstName') ?? 'User';
    String middleName = prefs.getString('middleName') ?? '';
    String department = prefs.getString('department') ?? 'your department';
    String studentId = prefs.getString('studentID') ?? '';

    String prompt = 'Greet the user firstname  $firstName and lastname $middleName, convert to lowercase and welcome him to the app. '
        'Talk about the department he enrolls in, which is $department, and mention some good things about it. '
        'For the $studentId, if it starts with EU it means he is an extension student, if it starts with RU it means the student is a regular class attending student.try to use some emojis to explain the feeling ';

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

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MarkdownBody(
              data: _greetingMessage,
              styleSheet: MarkdownStyleSheet(
                p: const TextStyle(fontSize: 18, height: 1.5),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: _goToHome,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Color(0xFF6200EA), // Purplish color
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Go to Home'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}