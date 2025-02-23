import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:nex_planner/config.dart';
import 'package:nex_planner/model/reminder.dart';
import 'package:nex_planner/model/schedule.dart';
import 'package:nex_planner/pages/AuthPage/register_page.dart';
import 'package:nex_planner/pages/HomePage/home_page.dart';
import 'package:nex_planner/provider/reminder_provider.dart';
import 'package:nex_planner/provider/classSchedule_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ReminderAdapter());
  Hive.registerAdapter(ScheduleAdapter());
  await Hive.openBox<Reminder>('remindersBox');
  await Hive.openBox<Schedule>('schedules');
  await dotenv.load(fileName: ".env");
  Gemini.init(apiKey: Config.apiKey);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReminderProvider()..loadReminders()),
        ChangeNotifierProvider(create: (context) => ClassScheduleProvider()),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Jost',
      ),
      initialRoute: isLoggedIn ? '/home' : '/register',
      routes: {
        '/home': (context) => const HomePage(),
        '/register': (context) => const RegisterPage(),
      },
      home: isLoggedIn ? const HomePage() : const RegisterPage(),
    );
  }
}