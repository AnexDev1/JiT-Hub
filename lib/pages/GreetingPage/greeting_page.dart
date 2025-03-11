import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../HomePage/home_page.dart';

class GreetingPage extends StatefulWidget {
  const GreetingPage({super.key});

  @override
  State<GreetingPage> createState() => _GreetingPageState();
}

class _GreetingPageState extends State<GreetingPage> with SingleTickerProviderStateMixin {
  String _greetingMessage = '';
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, String> _userData = {};
  bool _isJimmaStudent = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    _initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      _userData = await _fetchUserData();
      final university = _userData['university'] ?? '';
      _isJimmaStudent = university.toLowerCase().contains('jimma');

      if (_isJimmaStudent) {
        await _generateGreeting();
      } else {
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<Map<String, String>> _fetchUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString('firstName') ?? 'User',
      'lastName': prefs.getString('lastName') ?? '',
      'department': prefs.getString('department') ?? 'Computer Science',
      'studentId': prefs.getString('studentID') ?? 'RU1234',
      'university': prefs.getString('universityName') ?? 'Jimma University',
      'yearOfStudy': prefs.getString('yearOfStudy') ?? '1st',
    };
  }
String? _computedYear;
  Future<void> _generateGreeting() async {
    try {
      final firstName = _userData['firstName']!;
      final department = _userData['department']!;
      final studentId = _userData['studentId']!;
      _computedYear = _userData['yearOfStudy']!;

      final regExp = RegExp(r'\/(\d+)$');
      final match = regExp.firstMatch(studentId);
      if (match != null) {
        final ethiopianYear = int.tryParse(match.group(1)!);
        if (ethiopianYear != null) {
          final currentYear = DateTime.now().year;
          // Deduct 8 years from current year to adjust for the Ethiopian calendar difference.
          final adjustedCurrentYear = currentYear - 8;
          final studyYear = adjustedCurrentYear - ethiopianYear + 1;
          _computedYear = '$studyYear';
        }
      }

      final String studentType = studentId.startsWith('EU')
          ? 'extension student'
          : studentId.startsWith('RU')
          ? 'regular student'
          : 'student';

      final prompt = '''
Create a brief, personalized welcome message for a Jimma University student with the following details:

STUDENT INFO:
- First Name: $firstName
- Department: $department
- Student Type: $studentType
- Year of Study: $_computedYear

REQUIREMENTS:
1. Begin with "## Welcome to Jimma University, $firstName!"
2. One short paragraph (2-3 sentences) about their specific department at Jimma University.
3. One brief sentence of encouragement specific to their field.
4. End with a short call to action to explore the app features.
5. Include exactly ONE emoji that relates to education/academics.
6. Keep the entire message under 100 words.
7. Professional yet friendly tone.
8. Format using markdown.
9. Use emojis where appropriate.
10. No spelling or grammatical errors.
11. The number after the last "/" in the student ID is the registration year in the Ethiopian calendar.
''';

      await _sendRequestToAI(prompt);
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  Future<void> _sendRequestToAI(String prompt) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final response = await Gemini.instance.prompt(parts: [Part.text(prompt)]);
      final output = response?.output ?? '';

      setState(() {
        _greetingMessage = output;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      _animationController.forward();
    }
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Gradient background element
          Positioned(
            top: -120,
            right: -100,
            child: Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6366F1).withValues(alpha:0.2),
                    const Color(0xFF6366F1).withValues(alpha:0.0),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              height: 180,
              width: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF8B5CF6).withValues(alpha:0.15),
                    const Color(0xFF8B5CF6).withValues(alpha:0.0),
                  ],
                ),
              ),
            ),
          ),

          // Main content
          _isLoading
              ? _buildLoadingState()
              : _hasError
              ? _buildErrorState()
              : _buildContent(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:0.05),
                    blurRadius: 15,
                    spreadRadius: 1,
                  )
                ]
            ),
            child: const SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            _isJimmaStudent
                ? "Preparing your welcome message..."
                : "Getting things ready...",
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: const Icon(
                    Icons.wifi_off_rounded,
                    color: Color(0xFFDC2626),
                    size: 36,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Connection Issue',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Could not connect to our servers. Please check your connection.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),
                _buildPrimaryButton('Try Again', _initialize),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _goToHome,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Skip',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final firstName = _userData['firstName'] ?? 'User';

    return SingleChildScrollView(
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App logo bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha:0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: Color(0xFF6366F1),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "JIT Hub",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Greeting banner with profile
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6366F1).withValues(alpha:0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.2),
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Text(
                          _getInitials(),
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6366F1),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, $firstName',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Welcome to JIT Hub',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha:0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Main content section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _isJimmaStudent
                    ? _buildJimmaWelcomeCard()
                    : _buildFeaturesList(),
              ),

              const SizedBox(height: 32),

              // Continue button
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: _buildPrimaryButton('Continue to Dashboard', _goToHome),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    String initials = '';
    if (_userData['firstName']?.isNotEmpty == true) {
      initials += _userData['firstName']![0].toUpperCase();
    }
    if (_userData['lastName']?.isNotEmpty == true) {
      initials += _userData['lastName']![0].toUpperCase();
    }
    return initials.isEmpty ? 'U' : initials;
  }

  Widget _buildJimmaWelcomeCard() {
    final department = _userData['department'] ?? 'your department';
    final yearOfStudy = _computedYear ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // User academic info
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Wrap(
            spacing: 8, // horizontal spacing
            runSpacing: 8, // vertical spacing between wrapped lines
            children: [
              _buildInfoChip(
                label: department,
                icon: Icons.school_rounded,
              ),
              _buildInfoChip(
                label: '$yearOfStudy Year Student',
                icon: Icons.calendar_today_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // AI welcome message
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.04),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8EAFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      size: 18,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Personalized Welcome',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MarkdownBody(
                data: _greetingMessage,
                styleSheet: MarkdownStyleSheet.fromTheme(
                  ThemeData(
                    textTheme: TextTheme(
                      headlineSmall: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                      bodyMedium: GoogleFonts.poppins(
                        fontSize: 15,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ),
                ).copyWith(
                  h2: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF6366F1),
                    height: 1.4,
                  ),
                  p: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                  blockquoteDecoration: BoxDecoration(
                    color: const Color(0xFFE8EAFF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withValues(alpha:0.2),
                      width: 1,
                    ),
                  ),
                ),
                selectable: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoChip({required String label, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EAFF),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Keep this to ensure the chip is as small as possible
        children: [
          Icon(
            icon,
            size: 16,
            color: const Color(0xFF6366F1),
          ),
          const SizedBox(width: 6),
          Flexible( // Added Flexible to allow text wrapping
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6366F1),
              ),
              overflow: TextOverflow.ellipsis, // Shows ellipsis for very long text
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesList() {
    final features = [
      {
        'icon': Icons.calendar_today_rounded,
        'title': 'Academic Calendar',
        'description': 'Track important dates and events',
      },
      {
        'icon': Icons.book_outlined,
        'title': 'Course Materials',
        'description': 'Access your study resources',
      },
      {
        'icon': Icons.notifications_outlined,
        'title': 'Smart Reminders',
        'description': 'Never miss important deadlines',
      },
      {
        'icon': Icons.timer_outlined,
        'title': 'Study Planner',
        'description': 'Organize your academic schedule',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4),
          child: Text(
            'Discover Key Features',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(
          features.length,
              (index) => Padding(
            padding: EdgeInsets.only(bottom: index < features.length - 1 ? 16 : 0),
            child: _buildFeatureItem(
              icon: features[index]['icon'] as IconData,
              title: features[index]['title'] as String,
              description: features[index]['description'] as String,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8EAFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 22,
              color: const Color(0xFF6366F1),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}