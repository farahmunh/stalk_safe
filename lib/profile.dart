import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green,
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(height: 10),
                Text(
                  'Jane Doe',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Text(
                  '@user123',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Divider(),

          // Profile Options
          Expanded(
            child: ListView(
              children: [
                _buildProfileOption(
                  icon: Icons.notifications,
                  label: 'Notifications',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.description,
                  label: 'Terms of service',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.language,
                  label: 'Language',
                  subtitle: 'English',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.lock,
                  label: 'Privacy & security',
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, color: Colors.green),
                  title: Text('Sign Out'),
                  onTap: () => _showSignOutDialog(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            "Are you sure you want to sign out?",
            textAlign: TextAlign.center,),
          contentPadding: EdgeInsets.symmetric(horizontal: 5, vertical: 20),
          actionsPadding: EdgeInsets.symmetric(horizontal: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text("No"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text("Yes"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/signin');
                  }
                )
              ],
            )
          ],
        );
      }
    );
  }
}