import 'dart:async'; // For the Timer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stalk_safe/location_sharing_service.dart';

class Angela extends StatefulWidget {
  @override
  _AngelaState createState() => _AngelaState();
}

class _AngelaState extends State<Angela> {
  final TextEditingController _controller = TextEditingController();
  final LocationSharingService locationService = LocationSharingService();
  
  String _result = "";
  bool _isLoading = false;

  Timer? _debounce;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _contactsCollection = FirebaseFirestore.instance.collection('contacts');
  String? _priorityContactPhone;

  @override
  void initState() {
    super.initState();
    _fetchPriorityContact();
  }

  Future<void> _fetchPriorityContact() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        final querySnapshot = await _contactsCollection
            .where('userId', isEqualTo: user.uid)
            .where('isPriority', isEqualTo: true)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          setState(() {
            _priorityContactPhone = querySnapshot.docs.first['phone'];
          });
        }
      } catch (e) {
        print('Error fetching priority contact: $e');
      }
    }
  }

  Future<void> _sendSosAlerts() async {
  final user = _auth.currentUser;
  if (user == null) return;
  await locationService.startSharingLocation();

  try {
    final contactsSnapshot = await _contactsCollection
        .where('userId', isEqualTo: user.uid)
        .get();

    final List<Map<String, dynamic>> emergencyContacts = contactsSnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();

    for (var contact in emergencyContacts) {
      final String recipientUsername = contact['username'];
      await _sendMessageToContact(
        recipientUsername,
        "🚨 **SOS ALERT!** 🚨 User is in danger. Location sharing is active.",
        isSos: true, 
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "🚨 SOS alerts sent to emergency contacts, and location sharing activated.",
          style: GoogleFonts.inter(color: Colors.red),
        ),
      ),
    );
  } catch (e) {
    print('Error sending SOS alerts: $e');
  }
}

Future<void> _sendMessageToContact(String recipientUsername, String message, {bool isSos = false}) async {
  try {
    final user = _auth.currentUser;
    if (user == null) return;

    final currentUserId = user.uid;

    final recipientSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: recipientUsername)
        .get();

    if (recipientSnapshot.docs.isEmpty) {
      print("Recipient not found: $recipientUsername");
      return;
    }

    final recipientId = recipientSnapshot.docs.first.id;

    final String chatId = currentUserId.compareTo(recipientId) < 0
        ? '$currentUserId-$recipientId'
        : '$recipientId-$currentUserId';

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'senderId': currentUserId,
      'content': message,
      'type': isSos ? 'sos-alert' : 'location-system',
      'timestamp': FieldValue.serverTimestamp(),
    });

    print("Message sent to $recipientUsername");
  } catch (e) {
    print("Error sending message to $recipientUsername: $e");
  }
}

  Future<void> _callPriorityContact() async {
    if (_priorityContactPhone == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "No priority contact found. Please set one in the Shield page.",
            style: GoogleFonts.inter(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final uri = Uri(scheme: 'tel', path: _priorityContactPhone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Could not place a call to $_priorityContactPhone",
            style: GoogleFonts.inter(),
          ),
        ),
      );
    }
  }

  final List<String> _emergencyKeywords = [
    "Angela",
    "Urgent",
    "Emergency",
    "SOS",
    "Help",
    "Help me",
    "stalk",
    "stalking",
    "I'm followed",
    "following",
    "followed",
    "being followed",
    "follow",
    "trailing",
    "harassed",
    "danger",
    "scared",
    "panic",
    "stranger"
  ];

  // Sentiment Analysis Function
  Future<void> _analyzeSentiment(String text) async {
    const apiUrl =
        "https://api-inference.huggingface.co/models/SamLowe/roberta-base-go_emotions";
    const apiToken = "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";

    if (text.isEmpty) {
      setState(() {
        _result = "";
      });
      return;
    }

    if (_containsEmergencyKeywords(text)) {
      setState(() {
        _result =
            "fear"; 
      });
      await Future.delayed(Duration(seconds: 1));
      await _sendSosAlerts();
      await _callPriorityContact();
      return; 
    }

    setState(() {
      _isLoading = true;
      _result = "";
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $apiToken",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"inputs": text}),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _result = result[0][0]['label'];
          _isLoading = false;
        });

        if (_result == 'fear' ||
            _result == 'sadness' ||
            _result == 'surprise' ||
            _result == 'anger' ||
            _result == 'nervousness' ||
            _result == 'annoyance') {
          await Future.delayed(Duration(seconds: 1));
          await _sendSosAlerts();
          await _callPriorityContact();
        } else {
          _showRetryAlert();
        }
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error analyzing sentiment: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  bool _containsEmergencyKeywords(String text) {
    text = text.toLowerCase();
    for (var keyword in _emergencyKeywords) {
      if (text.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      _analyzeSentiment(text);
    });
  }

  void _showRetryAlert() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const Text(
                  "No Match Detected",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Message
                Text(
                  "The sentiment does not indicate a stalking incident. Please try entering another message.",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // Retry Button
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    setState(() {
                      _controller.clear(); // Clear the input field
                      _result = ""; // Reset the result
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF517E4C),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  child: Text(
                    "Retry",
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Angela',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF7DAF52),
        titleSpacing: 0, // Left-align title
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade100, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Angela is here for you:",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7DAF52),
              ),
            ),
            SizedBox(height: 10),
            // Text Input Field
            TextField(
              controller: _controller,
              maxLines: 4,
              onChanged: _onTextChanged, // Automatically trigger analysis
              style: GoogleFonts.inter(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Type your message here...",
                hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            // Loading Indicator
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF7DAF52),
                ),
              ),
            // Result Display
            if (!_isLoading && _result.isNotEmpty)
              Center(
                child: Card(
                  color: Colors.green.shade50,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      "Sentiment: $_result",
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF517E4C),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}