import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Privacy extends StatelessWidget {
  const Privacy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
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
              'At StalkSafe, we respect your privacy and are committed to protecting your personal information. This Privacy Policy explains how we collect, use, and share your data when you use our application.\n',
              style: GoogleFonts.inter(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('1. Information We Collect'),
            _buildSectionContent(
              '• Personal Information: When you create an account, we collect your username, email address, phone number, and password.\n'
              '• Location Data: StalkSafe collects your real-time location to provide location tracking and sharing features.\n'
              '• Emergency Contacts: You can add emergency contacts to share your location with them.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('2. How We Use Your Information'),
            _buildSectionContent(
              '• To Provide Services: Your personal information is used to create and manage your account, provide location-based services, and enable location sharing with emergency contacts.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('3. Sharing Your Information'),
            _buildSectionContent(
              '• With Emergency Contacts: Your location may be shared with the emergency contacts you select.\n'
              '• With Third-Party Service Providers: We may share data with trusted service providers for app functionality, such as location services.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('4. Data Security'),
            _buildSectionContent(
              '• We use industry-standard security measures to protect your personal information from unauthorized access, disclosure, or misuse.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('5. User Choices'),
            _buildSectionContent(
              '• Manage Account Data: You can update your username and emergency contacts directly through the app.\n'
              '• Control Location Sharing: You have the option to enable or disable location tracking and sharing features at any time.',
            ),
            const SizedBox(height: 16),
            _buildSectionTitle('6. Data Retention'),
            _buildSectionContent(
              '• We retain your personal information for as long as your account is active or as needed to provide services.',
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
