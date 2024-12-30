import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Terms extends StatelessWidget {
  const Terms({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms and Conditions',
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF7DAF52),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Effective Date: 7/1/2025\n',
              style:
                  GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'Welcome to StalkSafe! By using our application, you agree to comply with and be bound by the following Terms and Conditions. Please read them carefully before using our services.\n',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('1. User Account Registration'),
            _buildSectionContent(
              '• To use StalkSafe, you must create an account by providing your username, email address, phone number, and password.\n'
              '• You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account.\n'
              '• Ensure that the information you provide is accurate, complete, and up-to-date.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('2. Location Tracking and Sharing'),
            _buildSectionContent(
              '• StalkSafe uses location-based services to provide key features, such as tracking your real-time location and sharing it with emergency contacts.\n'
              '• By using the location tracking feature, you agree to allow StalkSafe to access and use your device\'s location data.\n'
              '• The location-sharing feature enables you to share your location with individuals you add to your emergency contact list. You are solely responsible for managing and maintaining your contact list.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('3. User Conduct'),
            _buildSectionContent(
              '• You agree to use the application responsibly and not to abuse the location-sharing features to infringe on the privacy or safety of others.\n'
              '• Sharing inaccurate, false, or malicious information through the platform is strictly prohibited.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('4. Privacy and Data Security'),
            _buildSectionContent(
              '• We prioritize the privacy and security of your personal information. StalkSafe collects user data such as usernames, email addresses, phone numbers, and location data as outlined in our Privacy Policy.\n'
              '• By using the application, you agree to the collection, storage, and usage of your data as described in our Privacy Policy.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: GoogleFonts.inter(fontSize: 14),
    );
  }
}
