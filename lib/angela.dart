import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart'; // Ensure this is the correct import for your home.dart file
import 'image.dart'; // Import the Image screen file

class Angela extends StatelessWidget {
  const Angela({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF92C97D), // Green color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the Home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Home()),
            );
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Header Text
            Text(
              "ask for ANGELA",
              style: GoogleFonts.poppins(
                fontSize: 24, // Keep original header size
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7AA15C),
              ),
            ),
            const SizedBox(height: 40),
            // Image Button
            GestureDetector(
              onTap: () {
                // Navigate to the Image screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ImageScreen()),
                );
              },
              child: Container(
                height: 300, // Bigger height
                width: 300, // Bigger width
                decoration: BoxDecoration(
                  color: const Color(0xFF92C97D),
                  borderRadius:
                      BorderRadius.circular(20), // Slightly rounded corners
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 150,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Image",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Text Button
            GestureDetector(
              onTap: () {
                // Handle text functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Text functionality coming soon!')),
                );
              },
              child: Container(
                height: 300, // Bigger height
                width: 300, // Bigger width
                decoration: BoxDecoration(
                  color: const Color(0xFF92C97D),
                  borderRadius:
                      BorderRadius.circular(20), // Slightly rounded corners
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.text_fields,
                      color: Colors.white,
                      size: 150,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Text",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
