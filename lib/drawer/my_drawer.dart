import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:woman_safety/Screens/privacy_policy.dart';
import 'package:woman_safety/Screens/setting_page.dart';
import '../global/global.dart';
import '../mainScreens/home_screen.dart';
import '../services/user_service.dart';
import '../splash screen/splash_screen.dart';

class MyDrawer extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
 // final DatabaseReference _database = FirebaseDatabase.instance.ref();

const   MyDrawer({super.key, required this.selectedIndex, required this.onItemSelected});

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  String userName = "Loading..."; // Default name while fetching
  String phone = "Loading...";
  bool pushNotifications = false;
  bool promotions = false;
  bool appUpdates = false;

  final UserService _userService = UserService(); // Create an instance of UserService

  @override
  void initState() {
    super.initState();
    _loadUserDetails(); // Load user details
  }

  /// Loads user details from SharedPreferences first, then fetches from Firebase
  void _loadUserDetails() async {
    // Load from local storage first
    Map<String, String> localData = await _userService.loadUserDetails();
    setState(() {
      userName = localData['name']!;
      phone = localData['phone']!;
    });

    // Fetch from Firebase for latest data
    Map<String, String> firebaseData = await _userService.getUserDetails();
    setState(() {
      userName = firebaseData['name']!;
      phone = firebaseData['phone']!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.15,
            alignment: const Alignment(-0.8, 0.3),
            color: const Color(0xFF904C77),
            child: userName == "Loading..."
                ? const CircularProgressIndicator(color: Colors.white) // Show a loader until data is fetched
                : Text(
              userName, // Display the fetched name or fallback message
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 29),
            ),

          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            selected: widget.selectedIndex == 0,
            selectedTileColor: Colors.blue.shade50,
            onTap: () {
              widget.onItemSelected(0);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("Settings"),
            selected: widget.selectedIndex == 1,
            selectedTileColor: Colors.blue.shade100,
            onTap: () {
              widget.onItemSelected(1);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text("Privacy Policy"),
            selected: widget.selectedIndex == 2,
            selectedTileColor: Colors.blue.shade100,
            onTap: () {
              widget.onItemSelected(1);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  PrivacyPolicy()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Abouts us"),
            selected: widget.selectedIndex == 3,
            selectedTileColor: Colors.blue.shade100,
            onTap: () {
              widget.onItemSelected(1);
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) =>  SettingsPage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text("Logout"),
            selected: widget.selectedIndex == 4,
            selectedTileColor: Colors.blue.shade100,
            onTap: () async {
              widget.onItemSelected(2);
              await fAuth.signOut();
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => const SplashScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
