import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum LocationCategory { academic, administrative, food, residence, recreation, services }

class CampusLocation {
  final String id;
  final String name;
  final LatLng position;
  final String description;
  final IconData iconData;
  final LocationCategory category;
  final String openingHours;
  final int floorCount;

  CampusLocation({
    required this.id,
    required this.name,
    required this.position,
    required this.description,
    required this.iconData,
    required this.category,
    required this.openingHours,
    required this.floorCount,
  });
}