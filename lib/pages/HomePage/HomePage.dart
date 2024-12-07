import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return DefaultTabController(
      length: 4,
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
              actions: <Widget>[
                IconButton(
                  icon: const CircleAvatar(
                    backgroundImage: AssetImage('lib/assets/image1.png'), // Replace with your profile image asset
                  ),
                  onPressed: () {
                    // Implement profile action here
                  },
                ),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Color(0xFF6431F4),
                ),
                child: Text(
                  'Drawer Header',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Messages'),
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('Profile'),
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 25.0, right: 25.0, top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Hello Anwar',
                        style: TextStyle(fontSize: 24),
                      ),
                      Text(
                        'how is your study',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, size: 35),
                    onPressed: () {
                      // Implement search action here
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0,),
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
              ),
              const SizedBox(height: 20),
              const Text(
                'Categories',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                tabs: [
                  Tab(text: 'Academics'),
                  Tab(text: 'Services'),
                  Tab(text: 'Tools'),
                  Tab(text: 'Campus Life'),
                ],
              ),
              const Expanded(
                child: TabBarView(
                  children: [
                    CategoryTab(),
                    CategoryTab(),
                    CategoryTab(),
                    CategoryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CategoryTab extends StatelessWidget {
  const CategoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Row(
            children: <Widget>[
              const Icon(Icons.category, size: 40),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Title',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Description'),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Implement expandable menu action here
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}