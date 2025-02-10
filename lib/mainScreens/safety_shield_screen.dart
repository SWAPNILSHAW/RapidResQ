import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:woman_safety/drawer/custom_app_bar.dart';
import 'package:woman_safety/drawer/my_drawer.dart';
import 'package:woman_safety/widget/permissions_helper.dart';

class SafetyShieldScreen extends StatefulWidget {
  const SafetyShieldScreen({super.key});

  @override
  _SafetyShieldScreenState createState() => _SafetyShieldScreenState();
}

class _SafetyShieldScreenState extends State<SafetyShieldScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Declare the key

  int _selectedIndex = 0; // Track the selected index

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index; // Update selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      key: _scaffoldKey, // Set the key to the Scaffold
      appBar: CustomAppBar(
        title: "RapidResQ",
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer(); // Open the drawer using the key
        },
      ),    /* appBar: AppBar(
        backgroundColor: const Color(0xFF904C77),
        title: Text(
          "Safety Shield",
          style: GoogleFonts.poppins(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),*/
      drawer: MyDrawer(
        selectedIndex: _selectedIndex, // Pass the selected index
        onItemSelected: _onItemSelected, // Pass the callback function
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.05),
            Image.asset(
              'assets/images/safety_page.png',
              width: screenWidth * 0.3,
              height: screenHeight * 0.15,
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              "Self Protection Tips",
              style: GoogleFonts.poppins(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenHeight * 0.02),
            Expanded(
              child: ListView(
                children: [
                  _buildTipText("Always be aware of your surroundings and trust your instincts.", screenWidth),
                  _buildTipText("Keep your phone charged and easily accessible.", screenWidth),
                  _buildTipText("Share your location with a trusted friend or family member.", screenWidth),
                  _buildTipText("Carry a personal safety alarm or whistle.", screenWidth),
                  _buildTipText("Learn basic self-defense techniques.", screenWidth),
                  _buildTipText("Avoid sharing personal information with strangers.", screenWidth),
                  _buildTipText("Stay alert when using public transportation.", screenWidth),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            OutlinedButton(
              onPressed: () {
                PermissionHelper.requestAllPermissions(context);
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF904C77), width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.015,
                  horizontal: screenWidth * 0.1,
                ),
              ),
              child: Text(
                "ACCESS ALL PERMISSIONS",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.04,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF904C77),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildTipText(String text, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(bottom: screenWidth * 0.02),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: screenWidth * 0.04,
          color: Colors.black54,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
