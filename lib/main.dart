import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nex_planner/model/reminder.dart';
import 'package:nex_planner/pages/HomePage/home_page.dart';
import 'package:nex_planner/provider/reminder_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderAdapter());
  await Hive.openBox<Reminder>('remindersBox');
  runApp(
    ChangeNotifierProvider(
      create: (context) => ReminderProvider()..loadReminders(),
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
        fontFamily: 'Poppins',
      ),
      title: 'Flutter Demo',
      home: const HomePage(),
    );
  }
}
