import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woman_safety/Screens/change_password_screen.dart';
import 'package:woman_safety/Screens/edit_profile_screen.dart';

import '../Animations/slide_page_route.dart';
import '../drawer/custom_app_bar.dart';
import '../drawer/my_drawer.dart';
import '../services/user_service.dart';

class SettingsPage extends StatefulWidget {
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>(); // Declare the key
  int _selectedIndex = 0; // Track the selected index for the drawer

  String userName = "Loading...";
  String userEmail = "Loading...";
  String userPhone = "Loading...";

  bool pushNotifications = false;
  bool promotions = false;
  bool appUpdates = false;

  final UserService _userService = UserService(); // Create an instance of UserService

  @override
  void initState() {
    super.initState();
    _loadUserDetails(); // Load user details
    _loadNotificationPreferences(); // Load notification preferences
  }

  /// Loads user details from SharedPreferences first, then fetches from Firebase
  void _loadUserDetails() async {
    // Load from local storage first
    Map<String, String> localData = await _userService.loadUserDetails();
    setState(() {
      userName = localData['name']!;
      userEmail = localData['email']!;
      userPhone = localData['phone']!;
    });

    // Fetch from Firebase for latest data
    Map<String, String> firebaseData = await _userService.getUserDetails();
    setState(() {
      userName = firebaseData['name']!;
      userEmail = firebaseData['email']!;
      userPhone = firebaseData['phone']!;
    });
  }

  /// Loads saved notification preferences from SharedPreferences
  Future<void> _loadNotificationPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      pushNotifications = prefs.getBool('pushNotifications') ?? false;
      promotions = prefs.getBool('promotions') ?? false;
      appUpdates = prefs.getBool('appUpdates') ?? false;
    });
  }

  /// Saves notification preferences in SharedPreferences
  Future<void> _saveNotificationPreference(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Drawer item selection function
  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Settings",
        onMenuPressed: () {
          _scaffoldKey.currentState?.openDrawer(); // Open the drawer using the key
        },
      ),
      drawer: MyDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Profile Picture
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/profile.jpg"), // Add profile image in assets
            ),
            const SizedBox(height: 10),

            // Profile Name
            Text(
              userName,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(userEmail, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
            Text(userPhone, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),

            // Account Settings Section
            buildSectionTitle("Account Settings"),
            buildSettingOption("Edit Profile",(){Navigator.push(
              context,
              SlidePageRoute(page: EditProfileScreen()),
            );}),
            buildSettingOption("Change your password",(){
              Navigator.push(
                context,
                SlidePageRoute(page:  ChangePasswordScreen()),
              );
            }),
            buildSettingOption("Security & Privacy",(){}),
            const SizedBox(height: 20),

            // Notification Settings Section
            buildSectionTitle("Notification Settings"),
            buildSwitchOption("Push Notification", "pushNotifications", pushNotifications),
            buildSwitchOption("Promotions", "promotions", promotions),
            buildSwitchOption("App Updates", "appUpdates", appUpdates),
          ],
        ),
      ),
    );
  }

  // Widget for section titles
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5), // Add spacing
          Divider(color: Colors.grey[300]), // Light grey divider for separation
        ],
      ),
    );
  }

  // Widget for list tile options
  Widget buildSettingOption(String title,VoidCallback onTapAction) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTapAction,
    );
  }

  // Widget for toggle switches with proper state management
  Widget buildSwitchOption(String title, String prefKey, bool value) {
    return SwitchListTile(
      title: Text(title),
      value: value,
      onChanged: (bool newValue) {
        setState(() {
          if (prefKey == 'pushNotifications') pushNotifications = newValue;
          if (prefKey == 'promotions') promotions = newValue;
          if (prefKey == 'appUpdates') appUpdates = newValue;
        });
        _saveNotificationPreference(prefKey, newValue); // Save the state
      },
    );
  }
}
