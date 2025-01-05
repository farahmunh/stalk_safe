import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stalk_safe/home.dart';
import 'package:stalk_safe/location_sharing_service.dart';

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
  final LocationSharingService _locationService = LocationSharingService();

  List<Map<String, dynamic>> messages = [];
  late String chatId;
  String? friendId;

  @override
  void initState() {
    super.initState();
    _setupChat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _setupChat() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    final currentUserId = currentUser.uid;
    final recipientSnapshot = await _firestore
        .collection('users')
        .where('username', isEqualTo: widget.recipientUsername)
        .get();

    if (recipientSnapshot.docs.isNotEmpty) {
      friendId = recipientSnapshot.docs.first.id;
      final recipientId = friendId!;
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

  void _toggleLocationSharing() async {
    if (_locationService.isSharingLocation && _locationService.currentRecipientId == friendId) {
      await _locationService.stopSharingLocation();
      _sendSystemMessage("User has stopped sharing their location.");
    } else {
      if (friendId != null) {
        await _locationService.startSharingLocation(recipientId: friendId);
        _sendSystemMessage("User has started sharing their location with you.");
      }
    }
    setState(() {});
  }

  Future<void> _sendSystemMessage(String content) async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      await _firestore.collection('chats').doc(chatId).collection('messages').add({
        'senderId': currentUser.uid,
        'content': content,
        'type': 'location-system',
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
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

  void _navigateToFriendLocation() {
    if (friendId != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Home(friendId: friendId, friendName: widget.recipientUsername),
        ),
      );
    }
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, bool isMine) {
    bool isSystemMessage = message['type'] == 'location-system';

    return GestureDetector(
      onLongPress: () {
        if (isMine) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Delete Message"),
                content: const Text("Are you sure you want to delete this message?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteMessage(message['id']);
                    },
                    child: const Text("Delete", style: TextStyle(color: Colors.red)),
                  ),
                ],
              );
            },
          );
        }
      },
      onTap: () {
        if (isSystemMessage) {
          _navigateToFriendLocation();
        }
      },
      child: Align(
        alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: isMine
                ? const LinearGradient(
                    colors: [Color(0xFF7DAF52), Color(0xFF517E4C)],
                  )
                : LinearGradient(
                    colors: [Colors.grey[300]!, Colors.grey[400]!],
                  ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
                isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                message['content'],
                style: TextStyle(
                  fontSize: 16,
                  color: isMine ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message['timestamp'] != null
                    ? (message['timestamp'] as Timestamp).toDate().toString()
                    : '',
                style: TextStyle(
                  fontSize: 12,
                  color: isMine ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7DAF52),
        title: Text(
          'Chat with ${widget.recipientUsername}',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _toggleLocationSharing,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: _locationService.isSharingLocation && _locationService.currentRecipientId == friendId
                    ? const Color(0xFF7DAF52) // Active
                    : Colors.grey[300], // Inactive
              ),
              child: Row(
                children: [
                  Icon(
                    _locationService.isSharingLocation && _locationService.currentRecipientId == friendId
                        ? Icons.location_on
                        : Icons.location_off,
                    color: _locationService.isSharingLocation && _locationService.currentRecipientId == friendId
                        ? Colors.white
                        : Colors.grey[800],
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _locationService.isSharingLocation && _locationService.currentRecipientId == friendId 
                        ? 'Sharing' 
                        : 'Not Sharing',
                    style: TextStyle(
                      color: _locationService.isSharingLocation && _locationService.currentRecipientId == friendId
                          ? Colors.white
                          : Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
                return _buildMessageBubble(message, isMine);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF517E4C)),
                  onPressed: () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      _sendSystemMessage(text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
