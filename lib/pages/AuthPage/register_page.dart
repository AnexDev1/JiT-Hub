import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nex_planner/pages/GreetingPage/greeting_page.dart';
import '../../services/generative_ai_service.dart';
import '../HomePage/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _isProcessing = false;
  GenerativeAIService? _aiService;
  bool _isAIInitialized = false;
  String? _apiKey;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String apiKey = prefs.getString('apikey') ?? '';

      setState(() {
        _apiKey = apiKey;
      });

      if (apiKey.isNotEmpty) {
        await _initializeAI(apiKey);
      }
    } catch (e) {
      debugPrint('Error loading API key: $e');
    }
  }

  Future<void> _initializeAI(String apiKey) async {
    try {
      setState(() => _isProcessing = true);

      _aiService = GenerativeAIService(apiKey: apiKey);

      // Wait a moment for initialization
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _isAIInitialized = _aiService?.isInitialized ?? false;
        _isProcessing = false;
      });

    } catch (e) {
      setState(() {
        _isAIInitialized = false;
        _isProcessing = false;
      });
      debugPrint('AI initialization error: $e');
    }
  }

  Future<void> _captureAndProcessImage(BuildContext context) async {
    if (_apiKey == null || _apiKey!.isEmpty) {
      _showApiKeyDialog();
      return;
    }

    if (!_isAIInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI service not initialized. Check your API key.')),
      );
      return;
    }

    setState(() => _isProcessing = true);
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final File imageFile = File(image.path);
      final Map<String, dynamic> idInfo = await _aiService!.processIDCard(imageFile);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('universityName', idInfo['universityName']);
      await prefs.setString('studentName', idInfo['studentName']);
      await prefs.setString('firstName', idInfo['firstName']);
      await prefs.setString('middleName', idInfo['middleName']);
      await prefs.setString('department', idInfo['department']);
      await prefs.setString('studentID', idInfo['studentID']);
      await prefs.setBool('isLoggedIn', true);
      await prefs.setBool('isGuest', false);
      await prefs.setBool('isVerified', idInfo['isLegitimate'] == true);

      setState(() => _isProcessing = false);

      if (idInfo['isLegitimate'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const GreetingPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(idInfo['reasoning']),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _showApiKeyDialog() {
    final TextEditingController apiKeyController = TextEditingController(text: _apiKey);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Google Gemini API Key'),
          content: TextField(
            controller: apiKeyController,
            decoration: const InputDecoration(
              hintText: 'Paste your API key here',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                String apiKey = apiKeyController.text.trim();
                if (apiKey.isNotEmpty) {
                  Navigator.of(context).pop();
                  await _saveApiKey(apiKey);
                  await _initializeAI(apiKey);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apikey', apiKey);
    setState(() {
      _apiKey = apiKey;
    });
  }

  Future<void> _loginAsGuest(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', true);
    await prefs.setBool('isLoggedIn', true);
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
        'subtitle': 'Details about academic schedules',
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
      appBar: AppBar(
        title: const Text('Student Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showApiKeyDialog,
          ),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : Center(
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