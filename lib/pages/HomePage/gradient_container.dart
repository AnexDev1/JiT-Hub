import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';  // Make sure to add this import

import '../../provider/reminder_provider.dart';
import 'Category/Tools/DailyReminder/daily_reminder.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final reminderProvider = Provider.of<ReminderProvider>(context);
    final assignmentCount = reminderProvider.reminders.where((r) => r.category == 'Assignment').length;
    final examCount = reminderProvider.reminders.where((r) => r.category == 'Exam').length;
    final studyCount = reminderProvider.reminders.where((r) => r.category == 'Study').length;
    final totalCount = assignmentCount + examCount + studyCount;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.0),
        child: Stack(
          children: [
            // Abstract design elements (keep these)
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha:0.08),
                ),
              ),
            ),
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha:0.05),
                ),
              ),
            ),

            // Main content with reduced spacing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), // Reduced vertical padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  // Header row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6), // Reduced padding
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha:0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Ionicons.calendar_outline,
                          color: Colors.white,
                          size: 16, // Smaller icon
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Reminder',
                              style: GoogleFonts.poppins(
                                fontSize: 15, // Smaller text
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Keep track of your activities',
                              style: GoogleFonts.poppins(
                                fontSize: 10, // Smaller text
                                fontWeight: FontWeight.w400,
                                color: Colors.white.withValues(alpha:0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (totalCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // Reduced padding
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha:0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$totalCount tasks',
                            style: GoogleFonts.poppins(
                              fontSize: 10, // Smaller text
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 10), // Reduced spacing

                  // Reminder categories row
                  Row(
                    children: [
                      Expanded(
                        child: _buildCompactReminderCategory(
                            Ionicons.document_text_outline,
                            'Assignment',
                            assignmentCount.toString(),
                            Colors.amber,
                            context
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCompactReminderCategory(
                            Ionicons.school_outline,
                            'Exam',
                            examCount.toString(),
                            Colors.redAccent,
                            context
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildCompactReminderCategory(
                            Ionicons.book_outline,
                            'Study',
                            studyCount.toString(),
                            Colors.greenAccent,
                            context
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10), // Reduced spacing

                  // Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF4338CA),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 8), // Reduced padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const DailyReminder(),
                        ));
                      },
                      icon: const Icon(Ionicons.add_circle, size: 14), // Smaller icon
                      label: Text(
                        'Add New Task',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 12, // Smaller text
                        ),
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

  // Update the reminder category method too
  Widget _buildCompactReminderCategory(
      IconData icon,
      String label,
      String count,
      Color iconColor,
      BuildContext context,
      ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const DailyReminder(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6), // Reduced padding
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(5), // Reduced padding
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 14, // Smaller icon
                color: iconColor,
              ),
            ),
            const SizedBox(height: 3), // Reduced spacing
            Text(
              count,
              style: GoogleFonts.poppins(
                fontSize: 14, // Smaller text
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 9, // Smaller text
                fontWeight: FontWeight.w400,
                color: Colors.white.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}