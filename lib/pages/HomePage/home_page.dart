// File: lib/pages/HomePage/home_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:nex_planner/pages/HomePage/Category/Tools/ClassSchedule/class_schedule.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/schedule_item.dart';
import 'AppDrawer/app_drawer.dart';
import 'Category/category_list_tile.dart';
import 'gradient_container.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _bottomNavController;
  late String _userName;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  List<CategoryItem> _searchResults = [];
  DateTime? _lastPressed;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _bottomNavController = TabController(length: 4, vsync: this);
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isGuest = prefs.getBool('isGuest') ?? false;
    if (isGuest) {
      setState(() {
        _userName = "Guest";
      });
    } else {
      String? userName = prefs.getString('studentName') ?? "User";
      String firstName = userName.split(' ').first;
      setState(() {
        _userName = firstName;
      });
    }
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      _searchResults.clear();
    });
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    final allItems = [
      ..._getCategoryItems(0),
      ..._getCategoryItems(1),
      ..._getCategoryItems(2),
      ..._getCategoryItems(3),
    ];

    setState(() {
      _searchResults = allItems
          .where((item) => item.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  List<CategoryItem> _getCategoryItems(int index) {
    switch (index) {
      case 0:
        return [
          CategoryItem(
            icon: Ionicons.school_outline,
            title: 'About JIT',
            description: 'Brief description about Jimma Institute of Technology University.',
          ),
          CategoryItem(
            icon: Ionicons.calendar_outline,
            title: 'Academic Calendar',
            description: 'Academic calendar of five consecutive years.',
          ),
          CategoryItem(
            icon: Ionicons.business_outline,
            title: 'Departments',
            description: 'Departments currently available in the university.',
          ),
        ];
      case 1:
        return [
          CategoryItem(
            icon: Ionicons.restaurant_outline,
            title: 'Cafe Menu',
            description: 'Read menu for students cafe.',
          ),
          CategoryItem(
              icon: Ionicons.map_outline,
              title: 'Campus Navigation',
            description: 'Navigate through the campus live'
          )
        ];
      case 2:
        return [
          CategoryItem(
            icon: Ionicons.bulb_outline,
            title: 'Study AI',
            description: 'AI tool that could be used for study purpose.',
          ),
          CategoryItem(
            icon: Ionicons.calculator_outline,
            title: 'Grade Calculator',
            description: 'Academic year result grade calculator.',
          ),
          CategoryItem(
            icon: Ionicons.time_outline,
            title: 'Class Schedule',
            description: 'Academic year result grade calculator.',
          ),
          CategoryItem(
            icon: Ionicons.notifications_outline,
            title: 'Daily Reminder',
            description: 'Academic year result grade calculator.',
          ),
        ];
      case 3:
        return [
          CategoryItem(
            icon: Ionicons.images_outline,
            title: 'Gallery',
            description: 'University gallery.',
          ),
          CategoryItem(
            icon: Ionicons.star_outline,
            title: 'Religious',
            description: 'Religious clubs in the campus',
          ),
        ];
      default:
        return [];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _bottomNavController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();
    if (_lastPressed == null || now.difference(_lastPressed!) > const Duration(seconds: 2)) {
      _lastPressed = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Press back again to exit',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF4338CA),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
        ),
      );
      return Future.value(false);
    }
    exit(0);
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFFF8F9FB),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: Icon(Ionicons.menu_outline, size: 24, color: Colors.grey[800]),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
            title: _isSearching
                ? TextField(
              controller: _searchController,
              autofocus: true,
              style: GoogleFonts.poppins(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
              onChanged: _performSearch,
            )
                : Text(
              'JIT Hub',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  _isSearching ? Ionicons.close_outline : Ionicons.search_outline,
                  size: 24,
                  color: Colors.grey[800],
                ),
                onPressed: _isSearching ? _stopSearch : _startSearch,
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        drawer: const AppDrawer(),
        body: _isSearching
            ? _buildSearchResults()
            : SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildUserHeaderSection(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: GradientContainer(),
              ),
              _buildTodaySchedule(context),
              // Fixed header portion for category section
              // Padding(
              //   padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //     children: [
              //       Text(
              //         'Categories',
              //         style: GoogleFonts.poppins(
              //           fontSize: 18,
              //           fontWeight: FontWeight.w600,
              //           color: Colors.grey[800],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // Scrollable Category Tabs section
              Expanded(
                child: _buildCategorySection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserHeaderSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Hello, ${_userName.toLowerCase()}',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                'How is your study going?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () {
              // Profile action
            },
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300, width: 2),
              ),
              child: const CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('lib/assets/image1.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TabBar(
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          labelColor: const Color(0xFF6366F1),
          unselectedLabelColor: Colors.grey[600],
          labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorColor: const Color(0xFF6366F1),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          tabs: const [
            Tab(text: 'Academics'),
            Tab(text: 'Services'),
            Tab(text: 'Tools'),
            Tab(text: 'Campus Life'),
          ],
          controller: _tabController,
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            physics: const BouncingScrollPhysics(),
            children: [
              CategoryListTile(items: _getCategoryItems(0)),
              CategoryListTile(items: _getCategoryItems(1)),
              CategoryListTile(items: _getCategoryItems(2)),
              CategoryListTile(items: _getCategoryItems(3)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Ionicons.search_outline,
              size: 60,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      physics: const BouncingScrollPhysics(),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        final categoryColor = _getCategoryColor(item.title);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(item.icon, color: categoryColor),
            ),
            title: Text(
              item.title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            subtitle: Text(
              item.description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            trailing: Icon(
              Ionicons.chevron_forward,
              color: categoryColor,
              size: 18,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onTap: () {
              // Navigate to corresponding details
            },
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String title) {
    final map = {
      'Departments': Colors.blue,
      'About JIT': Colors.purple,
      'Academic Calendar': Colors.orange,
      'Grade Calculator': Colors.green,
      'Class Schedule': Colors.indigo,
      'Daily Reminder': Colors.red,
      'Study AI': Colors.teal,
      'Cafe Menu': Colors.amber,
      'Campus Navigation': Colors.pink,
      'Gallery': Colors.pink,
      'Religious': Colors.deepPurple,
    };
    return map[title] ?? Colors.blueGrey;
  }
}

// In your _HomePageState class, add this method
Widget _buildTodaySchedule(BuildContext context) {
  final todaySchedule = _getTodaySchedule();

  if (todaySchedule.isEmpty) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Classes',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full class schedule
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context)=> const ClassSchedule()
                 )
                );
              },
              child: Text(
                'View All',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6366F1),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 135,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: todaySchedule.length,
            itemBuilder: (context, index) {
              final schedule = todaySchedule[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 16, bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: schedule.color,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: schedule.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Ionicons.time_outline,
                                  color: schedule.color,
                                  size: 16,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                schedule.time,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            schedule.subject,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Ionicons.location_outline,
                                color: Colors.grey[600],
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                schedule.location,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

// Add this method to get today's schedule
List<ScheduleItem> _getTodaySchedule() {
  // In a real app, you'd fetch this data from a provider or database
  final weekday = DateTime.now().weekday;

  // Return empty list for weekend (6=Saturday, 7=Sunday)
  if (weekday > 5) {
    return [];
  }

  // Sample data for weekdays - replace with actual data source
  return [

    ScheduleItem(
      subject: 'Advanced Programming',
      time: '9:00 AM - 10:30 AM',
      location: 'Room 205, Block B',
      instructor: 'Dr. Johnson',
      color: Colors.indigo,
    ),
    ScheduleItem(
      subject: 'Database Systems',
      time: '11:00 AM - 12:30 PM',
      location: 'Computer Lab 3',
      instructor: 'Prof. Williams',
      color: Colors.teal,
    ),
    ScheduleItem(
      subject: 'Computer Networks',
      time: '2:00 PM - 3:30 PM',
      location: 'Room 103, Block A',
      instructor: 'Dr. Smith',
      color: Colors.amber[700]!,
    ),
  ];
}