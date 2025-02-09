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
  int _selectedIndex = 0;
  String userName = "Loading...";
  String userEmail = "Loading...";
  String userPhone = "Loading...";

  bool pushNotifications = false;
  bool promotions = false;
  bool appUpdates = false;

  final UserService _userService = UserService(); // Ensure this is correctly implemented

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
    _loadNotificationPreferences();
  }
  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }
  /// Loads user details from SharedPreferences first, then fetches from Firebase
  Future<void> _loadUserDetails() async {
    try {
      Map<String, String> localData = await _userService.loadUserDetails();
      setState(() {
        userName = localData['name'] ?? "Unknown User";
        userEmail = localData['email'] ?? "No Email";
        userPhone = localData['phone'] ?? "No Phone";
      });

      // Fetch from Firebase (this may take longer)
      Map<String, String> firebaseData = await _userService.getUserDetails();
      setState(() {
        userName = firebaseData['name'] ?? userName;
        userEmail = firebaseData['email'] ?? userEmail;
        userPhone = firebaseData['phone'] ?? userPhone;
      });
    } catch (e) {
      debugPrint("Error fetching user details: $e");
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        title: "Settings",
        onMenuPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      drawer: MyDrawer(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemSelected,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            // Profile Picture
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/profile.jpg"), // Ensure this asset exists
            ),
            const SizedBox(height: 10),

            // User Info
            Text(userName, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(userEmail, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
            Text(userPhone, style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 20),

            // Account Settings
            _buildSectionTitle("Account Settings"),
            _buildSettingOption("Edit Profile", () => _navigateTo(EditProfileScreen())),
            _buildSettingOption("Change Password", () => _navigateTo(ChangePasswordScreen())),
            _buildSettingOption("Security & Privacy", () {}),

            const SizedBox(height: 20),

            // Notification Settings
            _buildSectionTitle("Notification Settings"),
            _buildSwitchOption("Push Notifications", "pushNotifications", pushNotifications),
            _buildSwitchOption("Promotions", "promotions", promotions),
            _buildSwitchOption("App Updates", "appUpdates", appUpdates),
          ],
        ),
      ),
    );
  }

  /// Section Title Widget
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Divider(color: Colors.grey[300]),
        ],
      ),
    );
  }

  /// Setting Option Widget
  Widget _buildSettingOption(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  /// Toggle Switch Widget
  Widget _buildSwitchOption(String title, String prefKey, bool value) {
    return SwitchListTile(
      title: Text(title, style: GoogleFonts.poppins(fontSize: 16)),
      value: value,
      onChanged: (bool newValue) {
        setState(() {
          if (prefKey == 'pushNotifications') pushNotifications = newValue;
          if (prefKey == 'promotions') promotions = newValue;
          if (prefKey == 'appUpdates') appUpdates = newValue;
        });
        _saveNotificationPreference(prefKey, newValue);
      },
    );
  }

  /// Navigation Function
  void _navigateTo(Widget page) {
    Navigator.push(context, SlidePageRoute(page: page));
  }
}
