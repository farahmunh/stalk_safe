import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_fonts/google_fonts.dart';
import 'shield.dart';

class TextScreen extends StatefulWidget {
  @override
  _TextScreenState createState() => _TextScreenState();
}

class _TextScreenState extends State<TextScreen> {
  final TextEditingController _controller = TextEditingController();
  String _result = "";
  bool _isLoading = false;

  // Speech-to-Text
  late stt.SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Speech recognition start
  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => print("Speech status: $status"),
        onError: (errorNotification) =>
            print("Speech error: ${errorNotification.errorMsg}"),
      );

      if (available) {
        setState(() {
          _isListening = true;
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Speech recognition is not available.",
              style: GoogleFonts.inter(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Stop listening
  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Sentiment Analysis Function
  Future<void> _analyzeSentiment(String text) async {
    const apiUrl =
        "https://api-inference.huggingface.co/models/SamLowe/roberta-base-go_emotions";
    const apiToken = "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";

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter some text or use the mic before analyzing.",
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
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

        // Navigate to Shield page if sentiment matches
        if (_result == 'fear' ||
            _result == 'sadness' ||
            _result == 'surprise') {
          await Future.delayed(Duration(seconds: 1));
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => Shield()),
          );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF7DAF52),
        centerTitle: true,
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
              "Enter your text below:",
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7DAF52),
              ),
            ),
            SizedBox(height: 10),
            // Input Field
            TextField(
              controller: _controller,
              maxLines: 4,
              style: GoogleFonts.inter(fontSize: 16),
              decoration: InputDecoration(
                hintText: "Type your message here...",
                hintStyle: GoogleFonts.inter(fontSize: 14, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: Icon(
                    _isListening ? Icons.mic : Icons.mic_none,
                    color: _isListening ? Colors.red : Colors.grey,
                  ),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
              ),
            ),
            SizedBox(height: 16),
            // Analyze Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _analyzeSentiment(_controller.text);
                },
                icon: Icon(Icons.search),
                label: Text(
                  "Analyze Sentiment",
                  style: GoogleFonts.inter(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: const Color(0xFF7DAF52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
            SizedBox(height: 20),
            // Loading Indicator
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF7DAF52),
                ),
              ),
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
