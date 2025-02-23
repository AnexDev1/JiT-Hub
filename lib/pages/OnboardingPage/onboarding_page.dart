import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: <Widget>[
                _buildPageContent(
                  image: 'lib/assets/onboarding1.png',
                  title: 'Welcome to JIT Labs',
                  description: 'Manage your academic schedules efficiently.',
                ),
                _buildPageContent(
                  image: 'lib/assets/onboarding2.png',
                  title: 'Set Reminders',
                  description: 'Never miss an important task or event.',
                ),
                _buildPageContent(
                  image: 'lib/assets/onboarding3.png',
                  title: 'Track Progress',
                  description: 'Keep track of your academic progress.',
                ),
              ],
            ),
          ),
          _currentPage == 2
              ? Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _completeOnboarding,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6431F4),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          )
              : const SizedBox.shrink(),
          const SizedBox(height: 20),

          _buildPageIndicator(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPageContent({required String image, required String title, required String description}) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0,right: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(image, height: 300),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Text(

              description,
              style: const TextStyle(fontSize: 18,color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(3, (int index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4.0),
          height: 8.0,
          width: _currentPage == index ? 24.0 : 16.0,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.purple : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
        );
      }),
    );
  }

  Future<void> _completeOnboarding() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingComplete', true);
    Navigator.pushReplacementNamed(context, '/register');
  }
}