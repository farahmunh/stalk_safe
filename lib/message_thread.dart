import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:stalk_safe/home.dart';
class LocationSharingService {
  static final LocationSharingService _instance = LocationSharingService._internal();
  factory LocationSharingService() => _instance;

  LocationSharingService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<Position>? _locationSubscription;
  bool isSharingLocation = false;

  Future<void> startSharingLocation() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    isSharingLocation = true;

    await _firestore.collection('users').doc(currentUser.uid).update({
      'isSharingLocation': true,
    });

    _locationSubscription = Geolocator.getPositionStream().listen((position) async {
      await _firestore.collection('users').doc(currentUser.uid).update({
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        }
      });
    });
  }

  Future<void> stopSharingLocation() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) return;

    isSharingLocation = false;

    await _firestore.collection('users').doc(currentUser.uid).update({
      'isSharingLocation': false,
      'location': FieldValue.delete(),
    });

    _locationSubscription?.cancel();
  }

  void dispose() {
    _locationSubscription?.cancel();
  }
}
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
    _locationService.dispose();
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

  Future<void> _toggleLocationSharing() async {
    if (_locationService.isSharingLocation) {
      await _locationService.stopSharingLocation();
      setState(() {});
      _sendSystemMessage("User has stopped sharing their location.");
    } else {
      await _locationService.startSharingLocation();
      setState(() {});
      _sendSystemMessage("User has started sharing their location.");
    }
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
                title: Text("Delete Message"),
                content: Text("Are you sure you want to delete this message?"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Cancel"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _deleteMessage(message['id']);
                    },
                    child: Text("Delete", style: TextStyle(color: Colors.red)),
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
          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isMine ? Colors.green[100] : Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message['content'],
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.recipientUsername}'),
        actions: [
          IconButton(
            icon: Icon(
              _locationService.isSharingLocation ? Icons.location_off : Icons.location_on,
            ),
            onPressed: _toggleLocationSharing,
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
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send),
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