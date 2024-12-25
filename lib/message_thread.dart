import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    try {
      _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .listen((snapshot) {
      if (mounted) {
        setState(() {
          messages = snapshot.docs.map((doc) => doc.data()).toList();
        });
      }
    });
  } catch (e) {
      // Handle Firestore listener exceptions
      print("Error fetching messages: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load messages.")),
      );
    }
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        try {
          // Write the message to Firestore
          await _firestore.collection('chats').doc(chatId).collection('messages').add({
            'senderId': currentUser.uid,
            'content': text,
            'timestamp': FieldValue.serverTimestamp(),
          });

          // Clear the input field after successful send
          if (mounted) {
            setState(() {
              _controller.clear();
            });
          }
        } catch (e) {
          // Handle Firestore exceptions
          print("Error sending message: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to send message. Please try again.")),
          );
        }
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
            const Color(0xFF7DAF52), // Green color for AppBar background
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

                return Align(
                  alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(message['content'], style: GoogleFonts.inter()),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.inter(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
