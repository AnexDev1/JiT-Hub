import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'reminder.g.dart';

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime date;


  @HiveField(3)
  String category;

  @HiveField(4)
  bool remindMe;

  Reminder({
    required this.title,
    required this.date,
    required this.category,
    required this.remindMe,
  });
}