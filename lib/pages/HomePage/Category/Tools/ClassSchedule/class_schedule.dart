import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
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
    const Color(0xFF4361EE),
    const Color(0xFF3A86FF),
    const Color(0xFF4CC9F0),
    const Color(0xFFF72585),
    const Color(0xFF7209B7),
    const Color(0xFF4895EF),
    const Color(0xFF560BAD),
    const Color(0xFF480CA8),
    const Color(0xFF3F37C9),
  ];

  DateTime _now = DateTime.now();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _weekdays.length, vsync: this);

    // Set tab to current day
    int weekday = _now.weekday;
    if (weekday >= 1 && weekday <= 6) {
      _tabController.animateTo(weekday - 1);
    }

    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
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

  String _getFormattedDate(int dayIndex) {
    final now = DateTime.now();
    final int currentWeekday = now.weekday;
    final int difference = dayIndex + 1 - currentWeekday;

    final targetDate = now.add(Duration(days: difference));
    return DateFormat('MMM d').format(targetDate);
  }

  bool _isCurrentDay(int index) {
    return _now.weekday == index + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification) {
            setState(() {
              _isScrolled = notification.metrics.pixels > 0;
            });
          }
          return false;
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                title: null,
                background: Container(
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 0),
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class Schedule',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your weekly classes',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Day selector
                  Container(
                    height: 100,
                    margin: const EdgeInsets.only(top: 8),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _weekdays.length,
                      itemBuilder: (context, index) {
                        final isSelected = _tabController.index == index;
                        final isToday = _isCurrentDay(index);

                        return GestureDetector(
                          onTap: () {
                            _tabController.animateTo(index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            width: 70,
                            decoration: BoxDecoration(
                              gradient: isSelected ? LinearGradient(
                                colors: [
                                  const Color(0xFF4361EE),
                                  const Color(0xFF3A86FF),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ) : null,
                              color: isSelected ? null :
                              isToday ? const Color(0xFFE8F1FD) : Colors.grey[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _weekdays[index].substring(0, 3),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? Colors.white :
                                    isToday ? const Color(0xFF4361EE) : Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getFormattedDate(index),
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isSelected ? Colors.white70 :
                                    isToday ? const Color(0xFF4361EE) : Colors.black45,
                                  ),
                                ),
                                if (isToday && !isSelected)
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF4361EE),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Schedule content
                  Container(
                    height: MediaQuery.of(context).size.height - 280,
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

                            return AnimationLimiter(
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                physics: const BouncingScrollPhysics(),
                                itemCount: schedules.length,
                                itemBuilder: (context, index) {
                                  return AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(milliseconds: 375),
                                    child: SlideAnimation(
                                      verticalOffset: 50.0,
                                      child: FadeInAnimation(
                                        child: _buildScheduleItem(
                                          schedules[index],
                                          isFirst: index == 0,
                                          isLast: index == schedules.length - 1,
                                          showConnector: index < schedules.length - 1,
                                          context: context,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
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
                    ..courseName = course
                    ..roomNo = room;
                  Provider.of<ClassScheduleProvider>(context, listen: false).addSchedule(schedule);
                },
              ),
            ),
          );
        },
        elevation: 4,
        backgroundColor: const Color(0xFF4361EE),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState(String day) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 60,
              color: const Color(0xFF4361EE),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Classes for $day',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your classes',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
      Schedule schedule, {
        required bool isFirst,
        required bool isLast,
        required bool showConnector,
        required BuildContext context,
      }) {
    final courseColor = _getCourseColor(schedule.courseName);
    final acronym = _getAcronym(schedule.courseName);

    // Parse time for duration calculation
    String startTime = schedule.time.split(" - ")[0];
    final format = DateFormat('h:mm a');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time column
          SizedBox(
            width: 70,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  startTime,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),

              ],
            ),
          ),

          // Course card
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: courseColor.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    splashColor: courseColor.withOpacity(0.1),
                    onTap: () {
                      // Show class details or edit options
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Course avatar
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  courseColor,
                                  courseColor.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                acronym,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // Course details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  schedule.courseName,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.location_on_outlined,
                                              size: 14,
                                              color: Colors.black54,
                                            ),
                                            const SizedBox(width: 4),
                                            Flexible(
                                              child: Text(
                                                'Room ${schedule.roomNo}',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),

                          // Menu button
                          PopupMenuButton(
                            icon: Icon(
                              Icons.more_vert,
                              color: Colors.grey.shade600,
                            ),
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete_outline, size: 18, color: Colors.red),
                                    const SizedBox(width: 8),
                                    Text('Delete', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                            onSelected: (value) {
                              if (value == 'delete') {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    title: Text(
                                      'Delete Class',
                                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                                    ),
                                    content: Text(
                                      'Are you sure you want to delete ${schedule.courseName}?',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text(
                                          'Cancel',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: Text(
                                          'Delete',
                                          style: GoogleFonts.poppins(color: Colors.white),
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
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _compareTime(String time1, String time2) {
    try {
      final format = DateFormat('h:mm a');
      final dateTime1 = format.parse(time1.split(" - ")[0]);
      final dateTime2 = format.parse(time2.split(" - ")[0]);
      return dateTime1.compareTo(dateTime2);
    } catch (e) {
      return time1.compareTo(time2);
    }
  }
}