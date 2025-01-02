import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stalk_safe/home.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageThread extends StatefulWidget {
  final String recipientUsername;

  MessageThread(this.recipientUsername);

  @override
  _MessageThreadState createState() => _MessageThreadState();
}

class _MessageThreadState extends State<MessageThread> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  late String chatId;

  @override
  void initState() {
    super.initState();
    _setupChat();
  }

  void _setupChat() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    // Combine userIds to create a unique chatId
    final currentUserId = currentUser.uid;
    final recipientSnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: widget.recipientUsername)
        .get();

    if (recipientSnapshot.docs.isNotEmpty) {
      final recipientId = recipientSnapshot.docs.first.id;
      chatId = currentUserId.compareTo(recipientId) < 0
          ? '$currentUserId-$recipientId'
          : '$recipientId-$currentUserId';

      _fetchMessages();
    }
  }

  void _fetchMessages() {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          messages = snapshot.docs.map((doc) {
            return {
              ...doc.data(),
              'id': doc.id,
            };
          }).toList();
        });
      }
    });
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
          await _firestore.collection('chats').doc(chatId).collection('messages').add({
            'senderId': currentUser.uid,
            'content': text,
            'timestamp': FieldValue.serverTimestamp(),
            'type': 'text',
          });

          setState(() {
          _controller.clear();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with ${widget.recipientUsername}',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
            const Color(0xFF7DAF52),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - index - 1];
                final isMine = message['senderId'] == _auth.currentUser?.uid;

                return GestureDetector(
                  onLongPress: () {
                    // Show confirmation dialog for deleting the message
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Delete Message"),
                          content: Text("Are you sure you want to delete this message?"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                _deleteMessage(message['id']); // Delete the message
                              },
                              child: Text("Delete", style: TextStyle(color: Colors.red)),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Align(
                    alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMine ? Colors.green[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: message['type'] == 'location'
                          ? GestureDetector(
                              onTap: () {
                                // Handle shared location navigation
                                final Uri locationUri = Uri.parse(message['content']);
                                final double latitude = double.parse(
                                    locationUri.queryParameters['q']!.split(',')[0]);
                                final double longitude = double.parse(
                                    locationUri.queryParameters['q']!.split(',')[1]);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        Home(friendLocation: LatLng(latitude, longitude)),
                                  ),
                                );
                              },
                              child: Text(
                                '📍 Shared Location',
                                style: GoogleFonts.inter(color: Colors.blue),
                              ),
                            )
                          : Text(
                              message['content'],
                              style: GoogleFonts.inter(),
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: IconButton(
                    icon: Icon(Icons.location_on, color: Colors.grey[700], size:28),
                    onPressed: _sendLocation,),
                ),
                const SizedBox(width: 5),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.grey[500]!,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(20), 
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Type a message...',
                        hintStyle: GoogleFonts.inter(color: Colors.grey[700]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),

                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green, 
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _deleteMessage(String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Message deleted.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete message: $e")),
      );
    }
  }

  void _sendLocation() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final locationMessage = 'https://maps.google.com/?q=${position.latitude},${position.longitude}';

      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUser.uid,
        'content': locationMessage,
        'type': 'location', // Add a type field to differentiate location messages
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location shared successfully!")),
      );
    } catch (e) {
      print("Error sharing location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to share location.")),
      );
    }
  }
}