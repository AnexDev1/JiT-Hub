// File: lib/pages/HomePage/category_tab.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nex_planner/pages/AuthPage/register_page.dart';
import 'package:nex_planner/pages/Category/category_detail.dart';

class CategoryTab extends StatefulWidget {
  final List<Item> items;

  const CategoryTab({Key? key, required this.items}) : super(key: key);

  @override
  _CategoryTabState createState() => _CategoryTabState();
}

class _CategoryTabState extends State<CategoryTab> {
  late List<Item> items;
  final List<String> _restrictedTitles = [
    'academic calendar',
    'cafe menu',
    'study ai',
    'class schedule',
    'gallery',
    'religious'
  ];

  @override
  void initState() {
    super.initState();
    items = List.from(widget.items);
  }

  void _pinToTop(int index) {
    setState(() {
      final item = items.removeAt(index);
      items.insert(0, item);
    });
  }

  Future<bool> _isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isGuest') ?? false;
  }
// dart
  void _showVerifyPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Verify ID to Get Full Access',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          content: Text(
            'Please verify your ID to access this feature.',
            style: TextStyle(fontSize: 18, color: Colors.grey[800]),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Back',
                style: TextStyle(fontSize: 16, color: Colors.black),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                backgroundColor: Theme.of(context).colorScheme.secondary,
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
              child: const Text(
                'Verify',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
  void _navigateToFeature(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailScreen(categoryName: title),
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

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return GestureDetector(
          onTap: () => _handleItemClicked(context, item.title),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                if (item is CategoryItem) Icon(item.icon),
                const SizedBox(width: 10),
                Expanded(child: Text(item.title)),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'open') {
                      _handleItemClicked(context, item.title);
                    } else if (value == 'pin') {
                      _pinToTop(index);
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return [
                      const PopupMenuItem(
                        value: 'open',
                        child: Text('Open'),
                      ),
                      const PopupMenuItem(
                        value: 'pin',
                        child: Text('Pin to top'),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.more_vert),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Item {
  final String title;

  Item(this.title);
}

class CategoryItem extends Item {
  final IconData icon;
  final String description;

  CategoryItem({
    required this.icon,
    required String title,
    required this.description,
  }) : super(title);
}