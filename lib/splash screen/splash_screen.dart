import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:woman_safety/Welcome_pages/page1.dart';
import 'package:woman_safety/mainScreens/home_screen.dart';
import 'package:woman_safety/mainScreens/safety_shield_screen.dart';
import '../Animations/slide_page_route.dart';
import '../authentication/login_screen.dart';
import '../global/global.dart';
import '../widget/permissions_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  /// **Handles navigation logic**
  Future<void> handleNavigation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    bool hasVisitedSafetyShield = prefs.getBool('hasVisitedSafetyShield') ?? false;
    bool isFirstTimeUser = prefs.getBool('isFirstTimeUser') ?? true;

    if (await fAuth.currentUser != null) {
      currentFirebaseUser = fAuth.currentUser;

      // **Check permissions before deciding where to go**
      bool permissionsGranted = await PermissionHelper.requestAllPermissions(context);

      if (isFirstTimeUser || !permissionsGranted) {
        // New user OR missing permissions → `SafetyShieldScreen`
        Navigator.pushReplacement(context, SlidePageRoute(page: const SafetyShieldScreen()),
        );

        await prefs.setBool('isFirstTimeUser', false);
      } else {
        // Existing user with permissions → `HomeScreen`
        Navigator.pushReplacement(
          context,
          SlidePageRoute(page: const HomeScreen()),
        );
      }
    } else {
      // If user is NOT logged in
      if (!hasVisitedSafetyShield) {
        Navigator.pushReplacement(
          context,
          SlidePageRoute(page: const Page1()),
        );
        await prefs.setBool('hasVisitedSafetyShield', true);
      } else {
        Navigator.pushReplacement(
          context,
          SlidePageRoute(page: const LoginScreen()),
        );
      }
    }
  }

  /// **Start timer to navigate**
  startTimer() {
    Timer(const Duration(seconds: 3), () => handleNavigation());
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    return Material(
      child: WillPopScope(
        onWillPop: () async => false, // Disable back button
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/lower.png',
                width: screenWidth,
                height: screenHeight * 0.09,
                fit: BoxFit.cover,
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: screenWidth * 0.6,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'RapidResQ',
                    style: GoogleFonts.poppins(
                      fontSize: screenWidth * 0.12,
                      color: const Color(0xFF904C77),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/upper.png',
                width: screenWidth,
                height: screenHeight * 0.09,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
