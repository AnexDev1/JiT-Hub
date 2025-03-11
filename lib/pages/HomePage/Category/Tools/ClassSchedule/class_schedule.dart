import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../../model/schedule.dart';
import '../../../../../provider/classSchedule_provider.dart';
import 'add_schedule.dart';

class ClassSchedule extends StatefulWidget {
  const ClassSchedule({super.key});

  @override
  _ClassScheduleState createState() => _ClassScheduleState();
}

class _ClassScheduleState extends State<ClassSchedule> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final Map<String, Color> _courseColors = {};
  final List<Color> _colorOptions = [
    Color(0xFF1E88E5), Color(0xFF43A047), Color(0xFFE53935),
    Color(0xFF5E35B1), Color(0xFFFFB300), Color(0xFF00ACC1),
    Color(0xFF8E24AA), Color(0xFF3949AB), Color(0xFF039BE5),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);

    // Get current day and set appropriate tab
    final now = DateTime.now();
    int weekday = now.weekday; // Monday is 1, Sunday is 7
    if (weekday < 7) {
      // Set to current day if it's Monday-Saturday
      _tabController.animateTo(weekday - 1);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Color _getCourseColor(String courseName) {
    if (!_courseColors.containsKey(courseName)) {
      final colorIndex = _courseColors.length % _colorOptions.length;
      _courseColors[courseName] = _colorOptions[colorIndex];
    }
    return _courseColors[courseName]!;
  }

  String _getAcronym(String text) {
    if (text.isEmpty) return '';
    final words = text.split(' ');
    if (words.length == 1) return words[0].substring(0, min(2, words[0].length)).toUpperCase();

    return words.take(2).map((word) => word.isNotEmpty ? word[0] : '').join('').toUpperCase();
  }

  int min(int a, int b) => a < b ? a : b;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text(
                'Class Schedule',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: false,
              floating: true,
              pinned: true,
              forceElevated: innerBoxIsScrolled,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(kToolbarHeight),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    tabAlignment: TabAlignment.start,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      color: Theme.of(context).primaryColor,
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[700],
                    labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    tabs: _weekdays.map((day) => Tab(text: day)).toList(),
                  ),
                ),
              ),
            ),
          ];
        },
        body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: TabBarView(
            controller: _tabController,
            children: _weekdays.map((day) {
              return Consumer<ClassScheduleProvider>(
                builder: (context, provider, child) {
                  final schedules = provider.getSchedules(day);
                  schedules.sort((a, b) => _compareTime(a.time, b.time));

                  if (schedules.isEmpty) {
                    return _buildEmptyState(day);
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    itemCount: schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = schedules[index];
                      final isFirst = index == 0;
                      final isLast = index == schedules.length - 1;

                      return _buildScheduleItem(
                        schedule,
                        isFirst: isFirst,
                        isLast: isLast,
                        showConnector: !isLast,
                      );
                    },
                  );
                },
              );
            }).toList(),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final currentDay = _weekdays[_tabController.index];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSchedulePage(
                onAddSchedule: (time, course, room) {
                  final schedule = Schedule()
                    ..day = currentDay
                    ..time = time
                    ..course = course
                    ..room = room;
                  Provider.of<ClassScheduleProvider>(context, listen: false).addSchedule(schedule);
                },
              ),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text('Add Class', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildEmptyState(String day) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_busy,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Classes for $day',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your classes',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(Schedule schedule, {
    required bool isFirst,
    required bool isLast,
    required bool showConnector,
  }) {
    final courseColor = _getCourseColor(schedule.course);
    final acronym = _getAcronym(schedule.course);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timeline column
            SizedBox(
              width: 80,
              child: Column(
                children: [
                  Text(
                    schedule.time,
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.black87,
                    ),
                  ),
                  // Timeline connector
                  if (showConnector)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        color: Colors.grey[300],
                      ),
                    ),
                ],
              ),
            ),

            // Schedule card
            Expanded(
              child: Card(
                margin: EdgeInsets.zero,
                elevation: 2,
                shadowColor: courseColor.withValues(alpha:0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: courseColor.withValues(alpha:0.3)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        // Color accent bar
                        Container(
                          width: 6,
                          decoration: BoxDecoration(
                            color: courseColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                          ),
                        ),

                        // Course avatar
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor: courseColor.withValues(alpha:0.2),
                            child: Text(
                              acronym,
                              style: GoogleFonts.inter(
                                color: courseColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Course details
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schedule.course,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 16,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Room ${schedule.room}',
                                      style: GoogleFonts.inter(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Delete button
                        IconButton(
                          icon: Icon(
                            Icons.delete_outline,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Delete Class',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                                ),
                                content: Text(
                                  'Are you sure you want to delete ${schedule.course}?',
                                  style: GoogleFonts.inter(),
                                ),
                                actions: [
                                  TextButton(
                                    child: Text(
                                      'Cancel',
                                      style: GoogleFonts.inter(),
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                  TextButton(
                                    child: Text(
                                      'Delete',
                                      style: GoogleFonts.inter(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      Provider.of<ClassScheduleProvider>(context, listen: false)
                                          .deleteSchedule(schedule);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _compareTime(String time1, String time2) {
    // Parse time strings like "10:00 AM" to compare them
    try {
      final format = DateFormat('h:mm a');
      final dateTime1 = format.parse(time1);
      final dateTime2 = format.parse(time2);
      return dateTime1.compareTo(dateTime2);
    } catch (e) {
      // Fallback to string comparison if parsing fails
      return time1.compareTo(time2);
    }
  }
}