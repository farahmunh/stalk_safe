import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stalk_safe/message_thread.dart';

class Inbox extends StatefulWidget {
  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> emergencyContacts = [];
  String searchText = "";

  @override
  void initState() {
    super.initState();
    _fetchEmergencyContacts();
  }

  void _fetchEmergencyContacts() async {
    final userId = _auth.currentUser?.uid;
    if (userId != null) {
      final contactsSnapshot = await _firestore
          .collection('contacts')
          .where('userId', isEqualTo: userId)
          .get();

      setState(() {
        emergencyContacts = contactsSnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'nickname': doc['nickname'],
            'username': doc['username'],
          };
        }).toList();
      });
    }
  }

  List<Map<String, dynamic>> _filterContacts() {
    return emergencyContacts
        .where((contact) =>
            contact['nickname'].toLowerCase().contains(searchText.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredContacts = _filterContacts();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inbox',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7DAF52),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search contacts...',
                filled: true,
                fillColor: Colors.grey[200],
                prefixIcon: Icon(Icons.search, color: const Color(0xFF517E4C)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredContacts.isNotEmpty
                ? ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 8),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF7DAF52),
                              child: Text(
                                contact['nickname'][0].toUpperCase(),
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              contact['nickname'],
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: const Color(0xFF344E41),
                              ),
                            ),
                            subtitle: Text(
                              contact['username'],
                              style: GoogleFonts.inter(
                                color: Colors.grey[700],
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MessageThread(contact['username']),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person_off, size: 80, color: Colors.grey[400]),
                        SizedBox(height: 10),
                        Text(
                          'No contacts found.',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
