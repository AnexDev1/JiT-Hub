import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountSettingsPage extends StatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  late String _userName;
  late String _department;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'John Doe';
      _department = prefs.getString('department') ?? 'Unknown';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Account Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Name'),
              subtitle: Text(_userName),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Implement name edit functionality
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Department'),
              subtitle: Text(_department),
              trailing: const Icon(Icons.edit),
              onTap: () {
                // Implement department edit functionality
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Change Password'),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                // Implement change password functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}