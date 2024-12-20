import 'dart:async'; // For the Timer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'shield.dart';

class Angela extends StatefulWidget {
  @override
  _AngelaState createState() => _AngelaState();
}

class _AngelaState extends State<Angela> {
  final TextEditingController _controller = TextEditingController();
  String _result = "";
  bool _isLoading = false;

  // Timer for debouncing
  Timer? _debounce;

  // List of keywords related to "fear" and seeking help
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

    // Check if the input contains any emergency-related keywords
    if (_containsEmergencyKeywords(text)) {
      setState(() {
        _result =
            "fear"; // Force the result to "fear" if any emergency keywords are found
      });

      // Navigate to Shield page if "fear" is detected
      await Future.delayed(Duration(seconds: 1));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => Shield()),
      );
      return; // Skip further sentiment analysis
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

        // Navigate to Shield page if sentiment matches fear
        if (_result == 'fear' ||
            _result == 'sadness' ||
            _result == 'surprise' ||
            _result == 'anger' ||
            _result == 'nervousness' ||
            _result == 'annoyance') {
          await Future.delayed(Duration(seconds: 1));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Shield()),
          );
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

  // Function to check if the text contains emergency-related keywords
  bool _containsEmergencyKeywords(String text) {
    text = text.toLowerCase();
    for (var keyword in _emergencyKeywords) {
      if (text.contains(keyword.toLowerCase())) {
        return true;
      }
    }
    return false;
  }

  // Function to handle the text change and trigger the debounce
  void _onTextChanged(String text) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () {
      _analyzeSentiment(text);
    });
  }

  // Function to show a retry alert
  void _showRetryAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "No Match Detected",
          style: GoogleFonts.inter(fontWeight: FontWeight.bold),
        ),
        content: Text(
          "The sentiment does not indicate a stalking incident. Please try entering another message.",
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              setState(() {
                _controller.clear(); // Clear the input field
                _result = ""; // Clear the result
              });
            },
            child: Text(
              "Retry",
              style: GoogleFonts.inter(color: const Color(0xFF517E4C)),
            ),
          ),
        ],
      ),
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
