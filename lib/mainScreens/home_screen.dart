import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:woman_safety/Screens/add_guardians_details.dart';
import 'package:woman_safety/Screens/helpline_screen.dart';
import 'package:woman_safety/Screens/sos_alert_page.dart';
import 'package:woman_safety/widget/welcome_bottom_image.dart';
import '../Animations/slide_page_route.dart';
import '../drawer/custom_app_bar.dart';
import '../drawer/my_drawer.dart';
import '../widget/show_exit_confirmation_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Declare the key

  int _selectedIndex = 0; // Track the selected index for the drawer

  // Function to handle item selection from the drawer
  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  // Function to show exit confirmation dialog
  Future<bool> _onWillPop() async {
    // Call the exit confirmation function from the new file
    return await showExitConfirmationDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return WillPopScope(
      onWillPop: _onWillPop, // Set back button restriction here
      child: Scaffold(
        key: _scaffoldKey, // Set the key to the Scaffold
        appBar: CustomAppBar(
          title: "Home",
          onMenuPressed: () {
            _scaffoldKey.currentState?.openDrawer(); // Open the drawer using the key
          },
        ),
        drawer: MyDrawer(
          selectedIndex: _selectedIndex,
          onItemSelected: _onItemSelected,
        ),
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Background Image
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: WelcomeBottomImage(),
            ),

            // "Safety Shield" Text
            Positioned(
              top: screenHeight * 0.01,
              left: screenWidth * 0.08,
              child: Center(
                child: Text(
                  "RapidResQ",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF904C77),
                  ),
                ),
              ),
            ),

            // Image in the Center
            Positioned(
              top: screenHeight * 0.081,
              left: 0,
              right: 0,
              child: Center(
                child: Image.asset(
                  'assets/images/home.png',
                  width: screenWidth * 0.9,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Grid of Buttons
            Positioned(
              top: screenHeight * 0.43,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildButton(context, Icons.phone, "Helpline", () {
                      // Navigate to Helpline screen
                      Navigator.push(
                        context,
                        SlidePageRoute(page:  HelplineScreen()),
                      );
                    }),
                    _buildButton(context, Icons.sos, "SOS Alert", () {
                      // Navigate to Camera screen
                      Navigator.push(
                        context,
                        SlidePageRoute(page:  SosAlertPage()),
                      );
                    }),
                    _buildButton(context, Icons.location_on, "Location", () {
                      // Navigate to Location screen
                    }),
                    _buildButton(context, Icons.people, "Parents", () {
                      // Navigate to Parents screen
                      Navigator.push(
                        context,
                        SlidePageRoute(page: const AddGuardiansDetails()),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Button creation
  Widget _buildButton(BuildContext context, IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF904C77),
        padding: const EdgeInsets.all(20),
        textStyle: GoogleFonts.poppins(
          fontSize: 19,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 50),
          const SizedBox(height: 10),
          Text(label),
        ],
      ),
    );
  }
}
