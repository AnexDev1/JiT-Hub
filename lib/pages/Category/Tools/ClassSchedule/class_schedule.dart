import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../model/schedule.dart';
import '../../../../provider/classSchedule_provider.dart';
import 'add_schedule.dart';

class ClassSchedule extends StatefulWidget {
  const ClassSchedule({super.key});

  @override
  _ClassScheduleState createState() => _ClassScheduleState();
}

class _ClassScheduleState extends State<ClassSchedule> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Schedule'),
      ),
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
              children: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'].map((day) {
                return Consumer<ClassScheduleProvider>(
                  builder: (context, provider, child) {
                    final schedules = provider.getSchedules(day);
                    return schedules.isEmpty
                        ? const Center(child: Text('No Schedule'))
                        : ListView.builder(
                      itemCount: schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = schedules[index];
                        return ListTile(
                          title: Text('${schedule.course} (${schedule.time})'),
                          subtitle: Text('Room: ${schedule.room}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              provider.deleteSchedule(schedule);
                            },
                          ),
                        );
                      },
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
          final currentDay = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'][_tabController.index];
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
        child: const Icon(Icons.add),
      ),
    );
  }
}