import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nex_planner/pages/AuthPage/register_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart'; // Add this package for Ionicons

import 'category_list.dart';

class CategoryListTile extends StatefulWidget {
  final List<Item> items;

  const CategoryListTile({Key? key, required this.items}) : super(key: key);

  @override
  _CategoryTabState createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryListTile> with SingleTickerProviderStateMixin {
  late List<Item> items;
  final List<String> _restrictedTitles = [
    'academic calendar',
    'cafe menu',
    'study ai',
    'class schedule',
    'gallery',
    'religious'
  ];
  bool _userIsGuest = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    items = List.from(widget.items);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Check guest status when widget initializes
    _checkGuestStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _pinToTop(int index) {
    setState(() {
      // Unpin all items
      for (int i = 0; i < items.length; i++) {
        items[i] = items[i].copyWith(isPinned: false);
      }
      // Remove the tapped item, mark it as pinned then insert it at the top.
      final item = items.removeAt(index);
      items.insert(0, item.copyWith(isPinned: true));
    });
  }

  Future<bool> _isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isGuest') ?? false;
  }

  void _showVerifyPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 8,
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.lock_closed,
                    size: 36,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Verify ID to Access',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'This feature requires student verification. Please verify your campus ID to proceed.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey[800],
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        foregroundColor: Colors.grey[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: Text(
                        'Back',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      child: Text(
                        'Verify Now',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _navigateToFeature(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryList(categoryName: title),
      ),
    );
  }

  Future<void> _handleItemClicked(BuildContext context, String title) async {
    final isGuest = await _isGuest();
    if (isGuest && _restrictedTitles.contains(title.toLowerCase().trim())) {
      _showVerifyPopup(context);
    } else {
      _navigateToFeature(context, title);
    }
  }

  IconData _getCategoryIcon(String title) {
    final map = {
      'Departments': Ionicons.business,
      'About JIT': Ionicons.information_circle,
      'Academic Calendar': Ionicons.calendar,
      'Grade Calculator': Ionicons.calculator,
      'Class Schedule': Ionicons.time,
      'Daily Reminder': Ionicons.notifications,
      'Study AI': Ionicons.bulb,
      'Cafe Menu': Ionicons.restaurant,
      'Gallery': Ionicons.images,
      'Religious': Ionicons.star,
    };

    return map[title] ?? Ionicons.apps;
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
      'Cafe Menu': Colors.amber[700]!,
      'Gallery': Colors.pink,
      'Religious': Colors.deepPurple,
    };

    return map[title] ?? Colors.blueGrey;
  }

  String _getCategoryDescription(String title) {
    final map = {
      'Departments': 'Departments and courses',
      'About JIT': 'University mission and history',
      'Academic Calendar': 'Important academic dates and schedules',
      'Grade Calculator': 'Calculate your GPA ',
      'Class Schedule': 'Manage your weekly class timetable',
      'Daily Reminder': 'Reminders for tasks & assignments',
      'Study AI': 'AI-powered study assistance',
      'Cafe Menu': 'University cafeteria menu',
      'Gallery': 'Campus photos and university events',
      'Religious': 'Religious services and information',
    };

    return map[title] ?? 'Explore university features and services';
  }

  bool _isRestricted(String title) {
    return _restrictedTitles.contains(title.toLowerCase().trim());
  }
  //check and store guest status
  Future<void> _checkGuestStatus() async {
    final isGuest = await _isGuest();
    if (mounted) {
      setState(() {
        _userIsGuest = isGuest;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isRestricted = _isRestricted(item.title);
        final categoryColor = _getCategoryColor(item.title);

        return Hero(
          tag: 'category_${item.title}',
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: categoryColor.withValues(alpha:0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _handleItemClicked(context, item.title),
                splashColor: categoryColor.withValues(alpha:0.1),
                highlightColor: categoryColor.withValues(alpha:0.05),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  child: Row(
                    children: [
                      // Category icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(item.title),
                          color: categoryColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),

                      // Category info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),

                                // Show pinned indicator
                                if (item is CategoryItem && item.isPinned)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Ionicons.pin,
                                      size: 16,
                                      color: categoryColor,
                                    ),
                                  ),

                                // Show lock icon for restricted items && for guest

                                if (isRestricted && _userIsGuest)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Icon(
                                      Ionicons.lock_closed,
                                      size: 16,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getCategoryDescription(item.title),
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action buttons
                      PopupMenuButton<String>(
                        offset: const Offset(0, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        icon: Icon(
                          Ionicons.ellipsis_vertical,
                          color: Colors.grey[700],
                        ),
                        onSelected: (value) {
                          if (value == 'open') {
                            _handleItemClicked(context, item.title);
                          } else if (value == 'pin') {
                            _pinToTop(index);
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                              value: 'open',
                              child: Row(
                                children: [
                                  Icon(
                                      Ionicons.arrow_forward_circle_outline,
                                      color: categoryColor,
                                      size: 18
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Open',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'pin',
                              child: Row(
                                children: [
                                  Icon(
                                      Ionicons.pin_outline,
                                      color: categoryColor,
                                      size: 18
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Pin to top',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Item {
  final String title;
  final bool isPinned;

  Item(this.title, {this.isPinned = false});

  Item copyWith({bool? isPinned}) {
    return Item(
      title,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

class CategoryItem extends Item {
  final IconData icon;
  final String description;

  CategoryItem({
    required this.icon,
    required String title,
    required this.description,
    bool isPinned = false,
  }) : super(title, isPinned: isPinned);

  @override
  CategoryItem copyWith({bool? isPinned}) {
    return CategoryItem(
      icon: icon,
      title: title,
      description: description,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}