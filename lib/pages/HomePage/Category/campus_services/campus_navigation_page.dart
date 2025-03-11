// dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:geolocator/geolocator.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
class CampusNavigationPage extends StatefulWidget {
  const CampusNavigationPage({super.key});

  @override
  _CampusNavigationPageState createState() => _CampusNavigationPageState();
}

class _CampusNavigationPageState extends State<CampusNavigationPage> {
  final MapController _mapController = MapController();
  final LatLng _jimmaUniversity = const LatLng(7.688539, 36.820743);

  CampusLocation? _selectedLocation;
  String _searchQuery = '';
  LocationCategory? _selectedCategory;
  List<LatLng> _routePoints = [];
  bool _isLoading = false;

  LatLng? _userLocation;
  late StreamSubscription<Position> _positionStream;
  final List<CampusLocation> _locations = [
    CampusLocation(
      id: '1',
      name: 'Registrar Office',
      position: const LatLng(7.6881998, 36.8203286),
      description:
      'The Registrar Office is responsible for maintaining student records, academic policies, and course registration.',
      iconData: Ionicons.library_outline,
      category: LocationCategory.academic,
      openingHours: '8:00 AM - 10:00 PM',
      floorCount: 4,
    ),
    CampusLocation(
      id: '2',
      name: 'Main Library',
      position: const LatLng(7.689014, 36.819858),
      description:
      'The Main Library is the central hub for academic resources, research materials, and study spaces.',
      iconData: Ionicons.library_outline,
      category: LocationCategory.academic,
      openingHours: '8:00 AM - 10:00 PM',
      floorCount: 4,
    ),
    CampusLocation(
      id: '3',
      name: 'Rama Student classroom Building',
      position: const LatLng(7.690697, 36.818444),
      description:
      'Rama Student classroom Building is the central hub for attending classes, study spaces and other study related activities.',
      iconData: Ionicons.library_outline,
      category: LocationCategory.academic,
      openingHours: '8:00 AM - 10:00 PM',
      floorCount: 4,
    ),
    CampusLocation(
      id: '4',
      name: 'Varnero Student classroom Building',
      position: const LatLng(7.691610, 36.817794),
      description:
      'Varnero Student classroom Building is the central hub for attending classes, study spaces and other study related activities.',
      iconData: Ionicons.library_outline,
      category: LocationCategory.academic,
      openingHours: '8:00 AM - 10:00 PM',
      floorCount: 4,
    ),
    CampusLocation(
      id: '5',
      name: 'Student mini cafe',
      position: const LatLng(7.692267, 36.817691),
      description: 'Student mini cafe is a mini cafe to get coffee tea or food',
      iconData: Ionicons.restaurant_outline,
      category: LocationCategory.food,
      openingHours: '8:00 AM - 10:00 PM',
      floorCount: 4,
    ),
    CampusLocation(
      id: '6',
      name: 'Jit Clinic',
      position: const LatLng(7.6949891, 36.8157016),
      description:
      'Jit Clinic is a medical clinic that provides medical services to students and staffs',
      iconData: Ionicons.medkit_outline,
      category: LocationCategory.services,
      openingHours: '8:00 AM - 10:00 PM',
      floorCount: 4,
    ),
    CampusLocation(
      id: '7',
      name: 'Student dormitory',
      position: const LatLng(7.69374, 36.8159848),
      description: 'Student dormitory is a place where students live and sleep',
      iconData: Ionicons.home_outline,
      category: LocationCategory.residence,
      openingHours: '8:00 AM - 10:00 PM',
      floorCount: 4,
    ),
    CampusLocation(
      id: '8',
      name: 'University stadium',
      position: const LatLng(7.693254, 36.814328),
      description:
      'University stadium is a place where students play sports and other activities',
      iconData: Ionicons.football_outline,
      category: LocationCategory.recreation,
      openingHours: '8:00 AM - 10:00 PM',
      floorCount: 4,
    ),
  ];

  List<Marker> get _markers {
    final filtered = _locations.where((loc) {
      if (_searchQuery.isNotEmpty &&
          !loc.name.toLowerCase().contains(_searchQuery.toLowerCase())) {
        return false;
      }
      if (_selectedCategory != null && loc.category != _selectedCategory) {
        return false;
      }
      return true;
    }).toList();

    final campusMarkers = filtered.map((location) {
      return Marker(
        width: 100,
        height: 20,
        point: location.position,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            setState(() {
              _selectedLocation = location;
            });
          },
          child: Text(
            location.name,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _getMarkerColor(location.category),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }).toList();

    if(_userLocation != null){
      campusMarkers.add(
        Marker(
          width: 100,
          height: 20,
          point: _userLocation!,
          child:  const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.blue,
            child: Text('U', style:TextStyle(color: Colors.white)),
          ),
        ),
      );
    }
    return campusMarkers;
  }

  Color _getMarkerColor(LocationCategory category) {
    switch (category) {
      case LocationCategory.academic:
        return Colors.blue;
      case LocationCategory.administrative:
        return Colors.red;
      case LocationCategory.food:
        return Colors.orange;
      case LocationCategory.residence:
        return Colors.purple;
      case LocationCategory.recreation:
        return Colors.green;
      case LocationCategory.services:
        return Colors.yellow;
    }
  }

  String _getCategoryName(LocationCategory category) {
    switch (category) {
      case LocationCategory.academic:
        return 'Academic';
      case LocationCategory.administrative:
        return 'Administrative';
      case LocationCategory.food:
        return 'Food & Dining';
      case LocationCategory.residence:
        return 'Residence';
      case LocationCategory.recreation:
        return 'Recreation';
      case LocationCategory.services:
        return 'Services';
    }
  }



  Future<void> _navigateTo(CampusLocation location) async {
    //location request


    setState(() {
      _isLoading = true;
    });
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) return;
    }
    final position = await Geolocator.getCurrentPosition();
    final userLatLng = LatLng(position.latitude, position.longitude);



    await Future.delayed(const Duration(seconds: 1)); // artificial delay

    final routePoints = await _getRoute(userLatLng, location.position);
    setState(() {
      _routePoints = routePoints;
      _isLoading = false;
    });
    _mapController.move(location.position, 18);
  }
  Future<List<LatLng>> _getRoute(LatLng origin, LatLng destination) async {
    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?geometries=polyline&access_token=pk.eyJ1IjoiYW5leGRldiIsImEiOiJjbHp6YzZ1ZzQxOHh0Mm1zYW5oNmdhZHRkIn0.EXzK4hcp09SCCv2e0bwXsg';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'] != null && data['routes'].isNotEmpty) {
        final polylineString = data['routes'][0]['geometry'];
        return _decodePoly(polylineString);
      }
    }
    // If request fails, fallback to a straight line
    return [origin, destination];
  }

// Helper to decode an encoded polyline string to a List<LatLng>
  List<LatLng> _decodePoly(String poly) {
    var list = <LatLng>[];
    int index = 0, len = poly.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int shift = 0;
      int result = 0;
      int b;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = poly.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      list.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return list;
  }

  @override
    void initState(){
    super.initState();
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
            distanceFilter: 10,
      ),
    ).listen((Position position){
      setState((){
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    });
  }
  @override
  void dispose(){
    _positionStream.cancel();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _jimmaUniversity,
              initialZoom: 17.5,
              onTap: (_, __) {
                setState(() {
                  _selectedLocation = null;
                  _routePoints = [];
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://api.mapbox.com/styles/v1/anexdev/cledzt2qt004h01pcnk0tb5g9/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYW5leGRldiIsImEiOiJjbHp6YzZ1ZzQxOHh0Mm1zYW5oNmdhZHRkIn0.EXzK4hcp09SCCv2e0bwXsg',

              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 4,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(top: 50, left: 16, right: 16, child: _buildSearchBar()),
          Positioned(top: 116, left: 16, right: 16, child: _buildCategoryFilters()),
          if (_selectedLocation != null) _buildLocationDetails(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search campus locations',
                hintStyle: GoogleFonts.poppins(fontSize: 14),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => _mapController.move(_jimmaUniversity, 16.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters() {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip(null, 'All'),
          _buildFilterChip(LocationCategory.academic, 'Academic'),
          _buildFilterChip(LocationCategory.administrative, 'Admin'),
          _buildFilterChip(LocationCategory.food, 'Food'),
          _buildFilterChip(LocationCategory.residence, 'Residence'),
          _buildFilterChip(LocationCategory.recreation, 'Recreation'),
          _buildFilterChip(LocationCategory.services, 'Services'),
        ],
      ),
    );
  }

  Widget _buildFilterChip(LocationCategory? category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        selectedColor: Theme.of(context).primaryColor,
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedCategory = selected ? category : null;
          });
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildLocationDetails() {
    final location = _selectedLocation!;
    String distanceText = "";
    if(_userLocation != null){
      double distanceInMeters = Geolocator.distanceBetween(
        _userLocation!.latitude,
        _userLocation!.longitude,
        location.position.latitude,
        location.position.longitude
      );
      if(distanceInMeters < 1000){
        distanceText = "${distanceInMeters.toStringAsFixed(0)} m";
      } else {
        double distanceInKm = distanceInMeters / 1000;
        distanceText = "${distanceInKm.toStringAsFixed(2)} km";
      }
    }
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    location.iconData,
                    color: Colors.blue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getCategoryName(location.category),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (distanceText.isNotEmpty)
                        Text(
                          "Distance: $distanceText",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),

                        )
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Ionicons.close_outline),
                  onPressed: () {
                    setState(() {
                      _selectedLocation = null;
                      _routePoints = [];
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              location.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Ionicons.time_outline, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    location.openingHours,
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Ionicons.layers_outline, size: 16, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    '${location.floorCount} ${location.floorCount > 1 ? "Floors" : "Floor"}',
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: _isLoading
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Ionicons.navigate_outline, size: 18),
                    label: _isLoading
                        ? Text(
                      'Loading',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                        : Text(
                      'Navigate',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _isLoading ? null : () => _navigateTo(location),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Ionicons.information_circle_outline),
                  onPressed: () => _showLocationDetailsDialog(location),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationDetailsDialog(CampusLocation location) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          location.name,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Category: ${_getCategoryName(location.category)}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Hours: ${location.openingHours}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              'Floors: ${location.floorCount}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              location.description,
              style: GoogleFonts.poppins(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Close', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

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