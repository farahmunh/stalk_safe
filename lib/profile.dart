import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _username = ''; // Default username
  final TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // Fetch the current user's username from Firestore
  Future<void> _fetchUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      setState(() {
        _username = userDoc['username'] ?? 'Unknown';
        _usernameController.text = _username;
      });
    }
  }

  // Update the username in Firestore
  Future<void> _updateUsername(String newUsername) async {
    User? user = _auth.currentUser;
    if (user != null) {
      // Check if the new username is unique
      if (newUsername != _username) {
        bool isUnique = await _isUsernameUnique(newUsername);
        if (!isUnique) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username is already taken.')),
          );
          return;
        }
      }

      // Update the username in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'username': newUsername});

      setState(() {
        _username = newUsername;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username updated successfully.')),
      );
    }
  }

  // Check if the username is unique in Firestore
  Future<bool> _isUsernameUnique(String username) async {
    final querySnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return querySnapshot.docs.isEmpty;
  }

  // Show the popup for editing username
  void _showEditUsernamePopup() {
    _usernameController.text = _username;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Username', style: GoogleFonts.inter()),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(
              hintText: "Enter new username",
              hintStyle: GoogleFonts.inter(),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                final newUsername = _usernameController.text.trim();
                if (newUsername.isNotEmpty) {
                  _updateUsername(newUsername);
                }
                Navigator.pop(context);
              },
              child: Text(
                'Save',
                style: GoogleFonts.inter(color: const Color(0xFF517E4C)),
              ),
            ),
          ],
        );
      },
    );
  }

  // Delete Account Functionality
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Account', style: GoogleFonts.inter()),
          content: Text(
            'Are you sure you want to delete your account? This action cannot be undone.',
            style: GoogleFonts.inter(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _deleteAccount();
              },
              child: Text(
                'Delete',
                style: GoogleFonts.inter(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete user authentication account
        await user.delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully.')),
        );

        Navigator.of(context).pushReplacementNamed('/signin');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting account: ${e.toString()}')),
      );
    }
  }

  // Sign Out Functionality
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text(
            "Are you sure you want to sign out?",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  child: Text("No",
                      style: GoogleFonts.inter(color: const Color(0xFF517E4C))),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text("Yes",
                      style: GoogleFonts.inter(color: const Color(0xFF517E4C))),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _auth.signOut();
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

  // Show Privacy Center Options
  void _showPrivacyCenter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: Text(
                'Terms and Conditions',
                style: GoogleFonts.inter(),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/terms');
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(
                'Privacy Policy',
                style: GoogleFonts.inter(),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/privacy');
              },
            ),
          ],
        );
      },
    );
  }

  // Show Language Options as a Popup Dialog
  void _showLanguageOptions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Language', style: GoogleFonts.inter()),
          content: Text(
            'Only English is supported currently.',
            style: GoogleFonts.inter(),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'OK',
                style: GoogleFonts.inter(color: const Color(0xFF517E4C)),
              ),
            ),
          ],
        );
      },
    );
  }

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
        backgroundColor: const Color(0xFF7DAF52),
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
                  backgroundColor: const Color(0xFF7DAF52),
                  child: Text(
                    _username.isNotEmpty ? _username[0].toUpperCase() : '?',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _username,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF517E4C)),
                      onPressed: _showEditUsernamePopup,
                    ),
                  ],
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
                  icon: Icons.privacy_tip_outlined,
                  label: 'Privacy Center',
                  onTap: _showPrivacyCenter,
                ),
                _buildProfileOption(
                  icon: Icons.language,
                  label: 'Language',
                  subtitle: 'English',
                  onTap: _showLanguageOptions,
                ),
                _buildProfileOption(
                  icon: Icons.delete,
                  label: 'Delete Account',
                  onTap: _showDeleteAccountDialog,
                ),
                ListTile(
                  leading:
                      Icon(Icons.exit_to_app, color: const Color(0xFF517E4C)),
                  title: Text('Sign Out', style: GoogleFonts.inter()),
                  onTap: _showSignOutDialog,
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
      leading: Icon(icon, color: const Color(0xFF7DAF52)),
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
}
