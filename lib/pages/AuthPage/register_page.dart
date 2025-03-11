import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
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
      String apiKey = prefs.getString('study_api_key') ?? '';

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
      return;
    }

    if (!_isAIInitialized) {
      _showErrorSnackBar('AI service not initialized. Check your API key.');
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
        _showErrorSnackBar(idInfo['reasoning']);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 5),
      ),
    );
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
        'icon': Ionicons.calendar_outline,
        'title': 'Academic Calendar',
        'subtitle': 'Details about academic schedules',
        'color': const Color(0xFF6366F1),
      },
      {
        'icon': Ionicons.cafe_outline,
        'title': 'Cafe Menu',
        'subtitle': 'Exclusive cafe offers',
        'color': Colors.amber.shade700,
      },
      {
        'icon': Ionicons.laptop_outline,
        'title': 'Study AI',
        'subtitle': 'Access to AI study tools',
        'color': Colors.teal,
      },
      {
        'icon': Ionicons.time_outline,
        'title': 'Class Schedule',
        'subtitle': 'Personalized class timings',
        'color': Colors.purple,
      },
      {
        'icon': Ionicons.images_outline,
        'title': 'Gallery',
        'subtitle': 'Access to exclusive gallery content',
        'color': Colors.blue.shade600,
      },
      {
        'icon': Ionicons.book_outline,
        'title': 'Religious',
        'subtitle': 'Details about religious events',
        'color': Colors.green.shade600,
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: _isProcessing
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 50,
              width: 50,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color(0xFF6366F1),
                ),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Processing...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      )
          : SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                       Center(
                        child: SizedBox(
                          height: 220,
                          width: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer animated circle
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(seconds: 2),
                                curve: Curves.easeInOut,
                                builder: (context, value, child) {
                                  return Container(
                                    height: 220 * value,
                                    width: 220 * value,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFF6366F1).withValues(alpha:0.7),
                                          const Color(0xFF6366F1).withValues(alpha:0.0),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // Middle circle with background
                              Container(
                                height: 180,
                                width: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF6366F1),
                                      Color(0xFF8B5CF6),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1).withValues(alpha:0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: const Duration(seconds: 1),
                                    curve: Curves.elasticOut,
                                    builder: (context, value, child) {
                                      return Transform.scale(
                                        scale: value,
                                        child: Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(
                                              Ionicons.shield_outline,
                                              size: 90,
                                              color: Colors.white.withValues(alpha:0.3),
                                            ),
                                            const Icon(
                                              Ionicons.school_outline,
                                              size: 45,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Rotating outer circle decoration
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(seconds: 20),
                                curve: Curves.linear,
                                builder: (context, value, child) {
                                  return Transform.rotate(
                                    angle: value * 2 * 3.14159,
                                    child: Container(
                                      width: 210,
                                      height: 210,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha:0.2),
                                          width: 1.5,
                                          strokeAlign: BorderSide.strokeAlignOutside,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Title and subtitle
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Verify ID for Full Access',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Complete the verification process for exclusive features',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[600],
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Restricted items section
                      Text(
                        'Premium Features',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Grid of restricted items
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: restrictedItems.length,
                        itemBuilder: (context, index) {
                          final item = restrictedItems[index];
                          return _buildFeatureCard(
                            icon: item['icon'],
                            title: item['title'],
                            subtitle: item['subtitle'],
                            color: item['color'],
                          );
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => _captureAndProcessImage(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Ionicons.scan_outline, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Scan Student ID',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () => _loginAsGuest(context),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: const Size(double.infinity, 0),
                    ),
                    child: Text(
                      'Continue as Guest',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}