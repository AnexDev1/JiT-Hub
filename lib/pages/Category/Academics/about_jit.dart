import 'package:flutter/material.dart';

class AboutJit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize:
            const Size.fromHeight(180.0), // Set the height of the app bar
        child: AppBar(
          automaticallyImplyLeading: false, // Remove the back icon
          flexibleSpace: Image.asset(
            'lib/assets/jit.jpg', // Path to your image
            fit: BoxFit.cover, // Make the image cover the entire app bar
          ),
          backgroundColor:
              Colors.transparent, // Make the app bar background transparent
        ),
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Jimma Institute of Technology',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'The Jimma Institute of Technology was initially established as the faculty of technology (FoT) back in 1997 when the government decided to expand the then Jimma Institute of Healthy Science (founded in 1983) beyond health fields and upgrade it into a full-fledged university with the opening of faculty of technology and faculty of business and economics. Upon its establishment, the faculty comprised three departments: the Civil Engineering Department, the Electrical Engineering Department, and the Mechanical Engineering Department. The first batch of students from the Faculty of Technology’s regular program graduated in 2002. Since then, the faculty has turned out competent graduates and contributed to the country’s development. To diversify its study programs, two more engineering programs, namely Water Resource and Environmental Engineering and Biomedical Engineering departments, were launched in the faculty. With this, the number of engineering departments has increased to five. Initially, the study period of undergraduate engineering departments was five years. However, due to the reform introduced into the country’s educational system, it was reduced to four years in 2003.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                '______________________________________________________',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Technology for Community Development!',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AboutJit(),
  ));
}
