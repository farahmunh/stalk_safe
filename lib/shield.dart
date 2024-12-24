import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'home.dart';
import 'package:stalk_safe/angela.dart';
import 'package:google_fonts/google_fonts.dart';

class Shield extends StatefulWidget {
  @override
  _ShieldState createState() => _ShieldState();
}

class _ShieldState extends State<Shield> {
  List<Map<String, String>> contacts = [];
  List<Map<String, String>> searchResults = [];

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();

  final CollectionReference _contactsCollection = FirebaseFirestore.instance.collection('contacts');
    final CollectionReference _usersCollection = FirebaseFirestore.instance.collection('users');


  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _currentUserId;
  String? _currentUsername;

  @override
  void initState() {
    super.initState();
    _getCurrentUserDetails();
  }

  Future<void> _getCurrentUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });

      final userDoc = await _usersCollection.doc(_currentUserId).get();
      setState(() {
        _currentUsername = userDoc['username'];
      });

      _fetchContacts();
    }
  }

  // Fetch contacts for the current user from Firestore
  Future<void> _fetchContacts() async {
    if (_currentUserId == null) return;

    try {
      final querySnapshot = await _contactsCollection
          .where('userId', isEqualTo: _currentUserId)
          .get();

      setState(() {
        contacts = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'username': data['username'] as String,
            'nickname': data['nickname'] as String,
            'phone': data['phone'] as String,
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching contacts: $e');
    }
  }

  // Add a user to contacts with a custom nickname
  void _showAddNicknameDialog(Map<String, String> user) {
    if (_currentUsername == user['username']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content:Text('You cannot add your own number', style: GoogleFonts.inter()))
      );
      return;
    }

    if(contacts.any((contact) => contact['username'] == user['username'])) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This user is already in your emergency contacts.', style: GoogleFonts.inter()))
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Nickname', style: GoogleFonts.inter()),
          content: TextField(
            controller: _nicknameController,
            decoration: InputDecoration(
              labelText: 'Enter Nickname',
              border: OutlineInputBorder(),
            ),
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _nicknameController.clear();
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: GoogleFonts.inter()),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_currentUserId == null) return;

                final newContact = {
                  'userId': _currentUserId!,
                  'username': user['username']!,
                  'nickname': _nicknameController.text.isNotEmpty
                      ? _nicknameController.text
                      : user['username']!,
                  'phone': user['phone']!,
                };

                try {
                  final docRef = await _contactsCollection.add(newContact);
                  setState(() {
                    contacts.add({
                      'id': docRef.id,
                      ...newContact,
                    });
                    searchResults.clear();
                  });
                  _nicknameController.clear();
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error adding contact: $e');
                }
              },
              child: Text('Add Contact', style: GoogleFonts.inter()),
            ),
          ],
        );
      },
    );
  }

  // Confirm before deleting a contact
  void _confirmDeleteContact(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Contact', style: GoogleFonts.inter()),
          content: Text(
            'Are you sure you want to delete ${contacts[index]['nickname']}?',
            style: GoogleFonts.inter(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: GoogleFonts.inter()),
            ),
            TextButton(
              onPressed: () async {
                try {
                  final contactId = contacts[index]['id']!;
                  await _contactsCollection.doc(contactId).delete();
                  setState(() {
                    contacts.removeAt(index);
                  });
                  Navigator.of(context).pop();
                } catch (e) {
                  print('Error deleting contact: $e');
                }
              },
              child: Text('Delete',
                  style: GoogleFonts.inter(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Launch a phone call
  Future<void> _callContact(String phoneNumber) async {
    final uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not place a call to $phoneNumber'),
        ),
      );
    }
  }

  // Search users by username
  Future<void> _searchUsers(String username) async {
    if (username.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    try {
      final querySnapshot = await _usersCollection
          .where('username', isGreaterThanOrEqualTo: username)
          .where('username', isLessThanOrEqualTo: username + '\uf8ff')
          .get();

      setState(() {
        searchResults = querySnapshot.docs.map((doc) {
          final userData = {
            'username': doc['username'] as String,
            'phone': doc['phone'] != null ? doc['phone'] as String : '',
          };

          final isSaved = contacts.any(
              (contact) => contact['username'] == userData['username']);
          userData['status'] = isSaved ? 'Saved' : 'Add';
          return userData;
        }).toList();
      });
    } catch (e) {
      print('Error searching users: $e');
      setState(() {
        searchResults.clear();
      });
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF7DAF52), // AppBar background color
        iconTheme: IconThemeData(color: Colors.white), // Icon color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Emergency Contacts',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7DAF52), // Green color for the text
              ),
            ),
            SizedBox(height: 16),
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (value) => _searchUsers(value),
              decoration: InputDecoration(
                labelText: 'Search by Username',
                prefixIcon: Icon(Icons.search, color: Color(0xFF7DAF52)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              style: GoogleFonts.inter(),
            ),
            SizedBox(height: 16),
            // Search Results
            searchResults.isNotEmpty
                ? Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final user = searchResults[index];
                        return ListTile(
                          title: Text(user['username']!, style: GoogleFonts.inter()),
                          subtitle: Text(user['phone']!, style: GoogleFonts.inter()),
                          trailing: user['status'] == 'Saved'
                          ? Icon(Icons.check, color: Colors.green,)
                            : ElevatedButton(
                            onPressed: () => _showAddNicknameDialog(user),
                            child: Text('Add', style: GoogleFonts.inter()),
                          ),
                        );
                      },
                    ),
                  )
                : SizedBox.shrink(), // Show nothing if no results
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: contacts.length,
                itemBuilder: (context, index) {
                  final contact = contacts[index];
                  return Card(
                    child: ListTile(
                      title: Text(contact['nickname']!, style: GoogleFonts.inter()),
                      subtitle: Text(contact['phone']!, style: GoogleFonts.inter()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.phone, color: Color(0xFF7DAF52)),
                            onPressed: () => _callContact(contact['phone']!),
                          ),
                          IconButton(
                            icon: Icon(Icons.message, color: Color(0xFF7DAF52)),
                            onPressed: () {
                              // Placeholder for sending a message
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteContact(index),
                          ),
                        ],
                      )
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 100,
        height: 100,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Angela()),
            ).then((_) {
              setState(() {});
            });
          },
          backgroundColor: const Color(0xFF7DAF52),
          shape: const CircleBorder(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'ask for',
                style: GoogleFonts.squadaOne(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'ANGELA',
                style: GoogleFonts.squadaOne(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF517E4C),
        selectedItemColor: const Color(0xFF7DAF52),
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: _onBottomNavTapped,
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shield),
            label: 'Shield',
          ),
        ],
      ),
    );
  }
}
