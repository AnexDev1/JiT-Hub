import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:url_launcher/url_launcher.dart';

class ReligiousPage extends StatefulWidget {
  const ReligiousPage({Key? key}) : super(key: key);

  @override
  _ReligiousPageState createState() => _ReligiousPageState();
}

class _ReligiousPageState extends State<ReligiousPage> {
  final List<ReligiousClub> _clubs = [
    ReligiousClub(
      name: 'Muslim Student Association',
      description: 'A community for Muslim students to connect, pray together, and participate in Islamic events.',
      meetingTime: 'Fridays at 1:30 PM',
      meetingLocation: 'Student Center Room 305',
      contacts: [
        ClubContact(type: ContactType.instagram, username: '@campus_msa'),
        ClubContact(type: ContactType.whatsapp, username: 'Join via link in bio'),
        ClubContact(type: ContactType.email, username: 'msa@university.edu'),
      ],
      color: const Color(0xFF43A047),
    ),
    ReligiousClub(
      name: 'Christian Fellowship',
      description: 'An inclusive Christian community focused on worship, Bible study, and service projects.',
      meetingTime: 'Sundays at 11:00 AM',
      meetingLocation: 'Chapel Hall',
      contacts: [
        ClubContact(type: ContactType.instagram, username: '@campus_cf'),
        ClubContact(type: ContactType.facebook, username: 'Campus Christian Fellowship'),
        ClubContact(type: ContactType.email, username: 'cf@university.edu'),
      ],
      color: const Color(0xFF1E88E5),
    ),
    ReligiousClub(
      name: 'Hillel Jewish Student Organization',
      description: 'A vibrant community celebrating Jewish culture, traditions, and educational programs.',
      meetingTime: 'Saturdays at 6:30 PM',
      meetingLocation: 'Community Center',
      contacts: [
        ClubContact(type: ContactType.instagram, username: '@campus_hillel'),
        ClubContact(type: ContactType.discord, username: 'Hillel Campus'),
        ClubContact(type: ContactType.email, username: 'hillel@university.edu'),
      ],
      color: const Color(0xFF7B1FA2),
    ),
    ReligiousClub(
      name: 'Hindu Student Council',
      description: 'A group dedicated to Hindu philosophy, cultural events, and mindfulness practices.',
      meetingTime: 'Wednesdays at 5:00 PM',
      meetingLocation: 'Cultural Center Room 102',
      contacts: [
        ClubContact(type: ContactType.instagram, username: '@hindu_council'),
        ClubContact(type: ContactType.whatsapp, username: 'Join via QR code'),
        ClubContact(type: ContactType.email, username: 'hinducouncil@university.edu'),
      ],
      color: const Color(0xFFFF7043),
    ),
    ReligiousClub(
      name: 'Buddhist Meditation Circle',
      description: 'A peaceful community practicing meditation, mindfulness, and studying Buddhist teachings.',
      meetingTime: 'Tuesdays at 7:00 PM',
      meetingLocation: 'Wellness Center',
      contacts: [
        ClubContact(type: ContactType.instagram, username: '@zen_campus'),
        ClubContact(type: ContactType.email, username: 'meditation@university.edu'),
      ],
      color: const Color(0xFF8D6E63),
    ),
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<ReligiousClub> filteredClubs = _clubs.where((club) {
      return club.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Religious Groups',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: filteredClubs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredClubs.length,
              itemBuilder: (context, index) {
                return _buildClubCard(filteredClubs[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.white,
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search religious groups...',
          hintStyle: GoogleFonts.poppins(fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Ionicons.search_outline,
            size: 70,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No religious groups found',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClubCard(ReligiousClub club) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: club.color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: club.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Ionicons.people_outline,
                    color: club.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        club.name,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Ionicons.time_outline,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            club.meetingTime,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  club.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Ionicons.location_outline,
                      size: 16,
                      color: Colors.grey[800],
                    ),
                    const SizedBox(width: 6),
                    Text(
                      club.meetingLocation,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Connect & Join:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: club.contacts.map((contact) {
                    return _buildContactChip(contact);
                  }).toList(),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: club.color,
                    side: BorderSide(color: club.color),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    minimumSize: const Size(double.infinity, 0),
                  ),
                  onPressed: () {
                    // Show dialog with more details or direct contact
                    _showClubDetailsDialog(club);
                  },
                  icon: const Icon(Ionicons.information_circle_outline, size: 18),
                  label: Text(
                    'More Information',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactChip(ClubContact contact) {
    IconData iconData;

    switch (contact.type) {
      case ContactType.instagram:
        iconData = Ionicons.logo_instagram;
        break;
      case ContactType.facebook:
        iconData = Ionicons.logo_facebook;
        break;
      case ContactType.twitter:
        iconData = Ionicons.logo_twitter;
        break;
      case ContactType.whatsapp:
        iconData = Ionicons.logo_whatsapp;
        break;
      case ContactType.discord:
        iconData = Ionicons.logo_discord;
        break;
      case ContactType.email:
        iconData = Ionicons.mail_outline;
        break;
    }

    return InkWell(
      onTap: () {
        // Handle opening social media or contact
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 16,
              color: Colors.grey[800],
            ),
            const SizedBox(width: 6),
            Text(
              contact.username,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClubDetailsDialog(ReligiousClub club) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            club.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Would you like to contact the group leaders?',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Additional information about upcoming events and membership will be provided.',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: club.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                // Handle contact action
              },
              child: Text(
                'Contact',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}

class ReligiousClub {
  final String name;
  final String description;
  final String meetingTime;
  final String meetingLocation;
  final List<ClubContact> contacts;
  final Color color;

  ReligiousClub({
    required this.name,
    required this.description,
    required this.meetingTime,
    required this.meetingLocation,
    required this.contacts,
    required this.color,
  });
}

enum ContactType { instagram, facebook, twitter, whatsapp, discord, email }

class ClubContact {
  final ContactType type;
  final String username;

  ClubContact({required this.type, required this.username});
}