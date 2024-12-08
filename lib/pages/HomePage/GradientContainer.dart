import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6767B3), Color(0xFF6431F4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: <Widget>[
          SvgPicture.asset(
            'lib/assets/image1.svg',
            width: 130,
            height: 130,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Daily Reminder',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('0 assignment'),
                const Text('0 test'),
                const Text('0 other'),
                const SizedBox(height: 3),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, // Background color
                    minimumSize: const Size(0, 30), // Size of the button
                  ),
                  onPressed: () {
                    // Implement add task action here
                  },
                  child: const Text(
                    'Add Task',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
