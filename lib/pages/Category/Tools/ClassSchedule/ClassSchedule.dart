import 'package:flutter/material.dart';
import 'AddSchedulePage.dart';

class ClassSchedule extends StatefulWidget {
  const ClassSchedule({Key? key}) : super(key: key);

  @override
  _ClassScheduleState createState() => _ClassScheduleState();
}

class _ClassScheduleState extends State<ClassSchedule>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, List<Map<String, String>>> _schedules = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _addSchedule(String day, String time, String course, String room) {
    setState(() {
      _schedules[day]!.add({'time': time, 'course': course, 'room': room});
    });
  }

  void _deleteSchedule(String day, int index) {
    setState(() {
      _schedules[day]!.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            isScrollable: true,
            dividerColor: Colors.transparent,
            tabAlignment: TabAlignment.start,
            tabs: const [
              Tab(text: 'Monday'),
              Tab(text: 'Tuesday'),
              Tab(text: 'Wednesday'),
              Tab(text: 'Thursday'),
              Tab(text: 'Friday'),
              Tab(text: 'Saturday'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _schedules.keys.map((day) {
                final schedules = _schedules[day]!;
                return schedules.isEmpty
                    ? const Center(child: Text('No Schedule'))
                    : ListView.builder(
                        itemCount: schedules.length,
                        itemBuilder: (context, index) {
                          final schedule = schedules[index];
                          return ListTile(
                            title: Text(
                                '${schedule['course']} (${schedule['time']})'),
                            subtitle: Text('Room: ${schedule['room']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteSchedule(day, index);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final currentDay = _schedules.keys.elementAt(_tabController.index);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddSchedulePage(
                onAddSchedule: (time, course, room) {
                  _addSchedule(currentDay, time, course, room);
                },
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
