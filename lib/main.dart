import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nex_planner/model/reminder.dart';
import 'package:nex_planner/model/schedule.dart';
import 'package:nex_planner/pages/HomePage/home_page.dart';
import 'package:nex_planner/provider/reminder_provider.dart';
import 'package:nex_planner/provider/classSchedule_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(ScheduleAdapter());
  await Hive.openBox<Reminder>('remindersBox');
  await Hive.openBox<Schedule>('schedules');
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReminderProvider()..loadReminders()),
        ChangeNotifierProvider(create: (context) => ClassScheduleProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Jost',

      ),
      title: 'Flutter Demo',
      home: const HomePage(),
    );
  }
}