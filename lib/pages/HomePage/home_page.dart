import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../Category/category_detail.dart';
import 'AppDrawer/app_drawer.dart';
import 'category_tab.dart';
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

// dart
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
            icon: Icons.school,
            title: 'About JIT',
            description: 'Brief description about Jimma Institute of Technology University.',
          ),
          CategoryItem(
            icon: Icons.calendar_month,
            title: 'Academic Calendar',
            description: 'Academic calendar of five consecutive years.',
          ),
          CategoryItem(
            icon: Icons.home,
            title: 'Departments',
            description: 'Departments currently available in the university.',
          ),
        ];
      case 1:
        return [
          CategoryItem(
            icon: Icons.menu_book,
            title: 'Cafe Menu',
            description: 'Read menu for students cafe.',
          ),
        ];
      case 2:
        return [
          CategoryItem(
            icon: Icons.calculate,
            title: 'Study AI',
            description: 'AI tool that could be used for study purpose.',
          ),
          CategoryItem(
            icon: Icons.calculate,
            title: 'Grade Calculator',
            description: 'Academic year result grade calculator.',
          ),
          CategoryItem(
            icon: Icons.calendar_month,
            title: 'Class Schedule',
            description: 'Academic year result grade calculator.',
          ),
          CategoryItem(
            icon: Icons.lock_clock,
            title: 'Daily Reminder',
            description: 'Academic year result grade calculator.',
          ),
        ];
      case 3:
        return [
          CategoryItem(
            icon: Icons.browse_gallery,
            title: 'Gallery',
            description: 'University gallery.',
          ),
          CategoryItem(
            icon: Icons.heat_pump_sharp,
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
        const SnackBar(content: Text('Press back again to exit')),
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16),
            child: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.menu, size: 35),
                onPressed: () {
                  scaffoldKey.currentState?.openDrawer();
                },
              ),
              title: _isSearching
                  ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                onChanged: _performSearch,
              )
                  : const Text(''),
              actions: <Widget>[
                IconButton(
                  icon: _isSearching ? const Icon(Icons.close) : const Icon(Icons.search, size: 35),
                  onPressed: _isSearching ? _stopSearch : _startSearch,
                ),
              ],
            ),
          ),
        ),
        drawer: const AppDrawer(),
        body: _isSearching
            ? _buildSearchResults()
            : Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Hello ${_userName.toLowerCase()}',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        'how is your study',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('lib/assets/image1.png'),
                    ),
                    onPressed: () {
                      // Implement profile action here
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const GradientContainer(),
              const SizedBox(height: 20),
              const Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
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
                  children: [
                    CategoryTab(
                      items: _getCategoryItems(0),
                    ),
                    CategoryTab(
                      items: _getCategoryItems(1),
                    ),
                    CategoryTab(
                      items: _getCategoryItems(2),
                    ),
                    CategoryTab(
                      items: _getCategoryItems(3),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return ListTile(
          title: Text(item.title),
          subtitle: Text(item.description),
          leading: Icon(item.icon),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CategoryDetailScreen(categoryName: item.title),
              ),
            );
          },
        );
      },
    );
  }
}