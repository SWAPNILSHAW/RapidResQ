import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../drawer/custom_app_bar.dart';
import '../drawer/my_drawer.dart';

class PrivacyPolicy extends StatefulWidget {
  const PrivacyPolicy({super.key});

  @override
  State<PrivacyPolicy> createState() => _PrivacyPolicyState();
}

class _PrivacyPolicyState extends State<PrivacyPolicy> {
  final GlobalKey<ScaffoldState> _scaffoldKey =
  GlobalKey<ScaffoldState>(); // Declare the key
  int _selectedIndex = 2; // Track the selected index for the drawer

  // Function to handle item selection from the drawer
  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Assign GlobalKey to Scaffold
      appBar: CustomAppBar(
        title: "Privacy Policy",
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer(); // Open drawer on menu press
        },
        showLeading: true,
      ),
      drawer: MyDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildParagraph(
                "Welcome to [Your App Name]. Your privacy and security are our top priorities. This Privacy Policy outlines how we collect, use, share, and protect your personal data."),
            _buildSectionTitle("1. Information We Collect"),
            _buildBulletPoint("Full name, phone number, and email address."),
            _buildBulletPoint("Emergency contacts for SOS alerts."),
            _buildBulletPoint("Real-time GPS location for safety tracking."),
            _buildBulletPoint("Device information (e.g., model, OS version)."),
            _buildSectionTitle("2. How We Use Your Information"),
            _buildBulletPoint(
                "To provide emergency assistance and real-time tracking."),
            _buildBulletPoint("To send alerts, notifications, and updates."),
            _buildBulletPoint("To ensure compliance and prevent fraud."),
            _buildSectionTitle("3. Information Sharing & Disclosure"),
            _buildBulletPoint(
                "We do not sell, rent, or trade your personal data."),
            _buildBulletPoint(
                "Location is shared with emergency contacts only during SOS alerts."),
            _buildBulletPoint(
                "Data may be shared with law enforcement in critical situations."),
            _buildSectionTitle("4. Data Security"),
            _buildBulletPoint("End-to-end encryption for sensitive data."),
            _buildBulletPoint("Secure cloud storage with restricted access."),
            _buildBulletPoint("Regular security updates to prevent cyber threats."),
            _buildSectionTitle("5. Your Rights & Choices"),
            _buildBulletPoint(
                "You can update or delete your personal information anytime."),
            _buildBulletPoint("You can disable location tracking in app settings."),
            _buildBulletPoint("You can request account deletion by contacting support."),
            _buildSectionTitle("6. Children's Privacy"),
            _buildParagraph(
                "This app is intended for users aged 18 and above. We do not knowingly collect data from children under 13."),
            _buildSectionTitle("7. Changes to This Privacy Policy"),
            _buildParagraph(
                "We may update this policy occasionally. Any changes will be communicated via the app."),
            _buildSectionTitle("8. Contact Us"),
            _buildParagraph("📧 Email: [your email]"),
            _buildParagraph("📞 Phone: [your contact number]"),
            _buildParagraph("🌐 Website: [your website]"),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text("Back"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
      ),
    );
  }

  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ",
              style: GoogleFonts.poppins(fontSize: 18, color: Colors.purple)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
