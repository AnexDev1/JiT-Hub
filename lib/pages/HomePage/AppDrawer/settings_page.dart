import 'package:flutter/material.dart';
import '../../AccountSettings/account_settings_page.dart';
import '../../AboutPage/about_page.dart'; // Import the new about page

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text('Account'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AccountSettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications'),
            onTap: () {
              // Navigate to notification settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Privacy'),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support'),
            onTap: () {
              // Navigate to help & support
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('About'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}