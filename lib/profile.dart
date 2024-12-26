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
  bool _isEditingUsername = false;

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
  Future<void> _updateUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      String newUsername = _usernameController.text.trim();
      // Ensure new username is unique
      bool isUnique = await _isUsernameUnique(newUsername);
      if (!isUnique) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Username is already taken.')),
        );
        return;
      }

      // Update the username in Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update({'username': newUsername});

      setState(() {
        _username = newUsername;
        _isEditingUsername = false;
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
                  child: Text("No", style: GoogleFonts.inter()),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: Text("Yes", style: GoogleFonts.inter()),
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
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF7DAF52),
                  child: Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _isEditingUsername
                          ? TextField(
                              controller: _usernameController,
                              decoration: const InputDecoration(
                                hintText: "Enter new username",
                              ),
                            )
                          : Text(
                              _username,
                              style: GoogleFonts.inter(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    IconButton(
                      icon: Icon(
                        _isEditingUsername ? Icons.check : Icons.edit,
                        color: const Color(0xFF7DAF52),
                      ),
                      onPressed: () {
                        if (_isEditingUsername) {
                          _updateUsername();
                        } else {
                          setState(() {
                            _isEditingUsername = true;
                          });
                        }
                      },
                    ),
                    if (_isEditingUsername)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _isEditingUsername = false;
                            _usernameController.text = _username;
                          });
                        },
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
                  icon: Icons.description,
                  label: 'Privacy Center',
                  onTap: () {},
                ),
                _buildProfileOption(
                  icon: Icons.language,
                  label: 'Language',
                  subtitle: 'English',
                  onTap: () {},
                ),
                ListTile(
                  leading:
                      Icon(Icons.exit_to_app, color: const Color(0xFF7DAF52)),
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
