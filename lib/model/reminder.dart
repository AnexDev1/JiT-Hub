import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

part 'reminder.g.dart';

@HiveType(typeId: 0)
class Reminder extends HiveObject {
  @HiveField(0)
  String uuid;

  @HiveField(1)
  String title;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String category;

  @HiveField(4)
  bool remindMe;

  @HiveField(5)
  String description;

  @HiveField(6)
  bool isDone;

  Reminder({
    required this.title,
    required this.date,
    required this.category,
    required this.remindMe,
    this.uuid = '',
    this.description = '',
    this.isDone = false,
  }) {
    // Generate UUID if not provided
    if (uuid.isEmpty) {
      uuid = UniqueKey().toString();
    }
  }
}