import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:woman_safety/drawer/custom_app_bar.dart';

import '../services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String userName = "Loading...";
  String userEmail = "Loading...";
  String userPhone = "Loading...";

  bool _isLoading = false;

  final UserService _userService = UserService();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserDetails(); // Fetch user details on init
  }

  // Fetch user details from local storage and Firebase
  void _loadUserDetails() async {
    setState(() {
      _isLoading = true;
    });

    // Fetch user details from Firebase
    Map<String, String> firebaseData = await _userService.getUserDetails();

    // Optionally, load from local storage if needed
    Map<String, String> localData = await _userService.loadUserDetails();

    setState(() {
      userName = firebaseData['name'] ?? localData['name'] ?? "Loading...";
      userEmail = firebaseData['email'] ?? localData['email'] ?? "Loading...";
      userPhone = firebaseData['phone'] ?? localData['phone'] ?? "Loading...";

      // Initialize the text controllers with Firebase data
      _nameController.text = userName;
      _emailController.text = userEmail;
      _phoneController.text = userPhone;

      _isLoading = false;
    });
  }

  // Update profile
  void _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    // Prepare user data
    Map<String, String> updatedData = {
      'name': _nameController.text,
      'email': _emailController.text,
      'phone': _phoneController.text,
    };

    try {
      await _userService.updateUserDetails(updatedData);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profile updated successfully!")));
    } catch (e) {
      // Handle error (e.g., show error message)
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update profile: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Edit Profile", onMenuPressed: (){},showLeading: false,),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF904C77),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5,
                  ),
                  onPressed: _updateProfile,
                  child: Text("Save Changes",style: GoogleFonts.poppins(fontSize:15,fontWeight: FontWeight.bold,color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
