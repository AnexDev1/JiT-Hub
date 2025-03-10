// File: lib/pages/study_ai_api_setup.dart
import 'package:flutter/material.dart';
import 'package:nex_planner/pages/HomePage/Category/Tools/studyAI/study_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
class ApiSetupPage extends StatefulWidget {
  const ApiSetupPage({super.key});
  @override
  _ApiSetupPageState createState() => _ApiSetupPageState();
}

class _ApiSetupPageState extends State<ApiSetupPage> {
  final TextEditingController _apiController = TextEditingController();
  String _savedApi = '';

  Future<void> _getApi() async {
    final prefs = await SharedPreferences.getInstance();
    final storedApi = prefs.getString('study_api_key') ?? '';
    if (storedApi.isNotEmpty) {
      _apiController.text = storedApi;
    } else {
      await launchUrl(Uri.parse("https://aistudio.google.com/app/apikey"));
    }
  }

  void _clearApi() {
    _apiController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('API cleared')),
    );
  }

  void _saveApi() async {
    if (_apiController.text.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('study_api_key', _apiController.text);

      setState(() {
        _savedApi = _apiController.text;
      });
      // Navigate to StudyAI page.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const StudyAI()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an API value')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Study AI API Setup')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _apiController,
              decoration: const InputDecoration(
                labelText: 'Enter API Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _getApi,
                  child: const Text('Get API'),
                ),
                ElevatedButton(
                  onPressed: _saveApi,
                  child: const Text('Save API'),
                ),
                ElevatedButton(
                  onPressed: _clearApi,
                  child: const Text('Clear API'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}