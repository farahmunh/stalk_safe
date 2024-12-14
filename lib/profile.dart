import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Profile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7DAF52), // Green color for app bar
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
                  backgroundColor:
                      const Color(0xFF7DAF52), // Green color for CircleAvatar
                  child:
                      const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  'Jane Doe',
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '@user123',
                  style: GoogleFonts.inter(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),

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
                  leading: Icon(Icons.exit_to_app,
                      color: const Color(
                          0xFF7DAF52)), // Green color for sign out icon
                  title: Text(
                    'Sign Out',
                    style: GoogleFonts.inter(),
                  ),
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
      leading: Icon(icon,
          color: const Color(0xFF7DAF52)), // Green color for option icon
      title: Text(
        label,
        style: GoogleFonts.inter(),
      ),
      subtitle:
          subtitle != null ? Text(subtitle, style: GoogleFonts.inter()) : null,
      trailing: const Icon(Icons.arrow_forward_ios),
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
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(), // Google Fonts Inter for dialog text
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 5, vertical: 20),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text(
                    "No",
                    style: GoogleFonts.inter(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    "Yes",
                    style: GoogleFonts.inter(),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed('/signin');
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
