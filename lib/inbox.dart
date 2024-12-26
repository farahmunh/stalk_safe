import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'message_thread.dart';

class Inbox extends StatefulWidget {
  @override
  _InboxState createState() => _InboxState();
}

class _InboxState extends State<Inbox> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Map<String, dynamic>> emergencyContacts = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Inbox',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFF7DAF52), // Green color for AppBar background
      ),
      body: ListView.builder(
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = emergencyContacts[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text(contact['nickname'][0].toUpperCase()),
            ),
            title: Text(contact['nickname'], style: GoogleFonts.inter()),
            subtitle: Text(contact['username'], style: GoogleFonts.inter()),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MessageThread(contact['username']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
