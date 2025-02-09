import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:woman_safety/authentication/login_screen.dart';
import '../Animations/slide_page_route.dart';
import '../widget/welcome_bottom_image.dart';

class Page4 extends StatelessWidget {
  const Page4({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Stack(
        children: [
          // "Share Location" Text at the Top
          Positioned(
            top: screenHeight * 0.11,
            left: 0,
            right: 0,
            child: Container(
              alignment: Alignment.topCenter,
              child: Text(
                "Share Location",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.11, // Responsive font size
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF904C77),
                ),
              ),
            ),
          ),

          // Center Image
          Positioned(
            top: screenHeight * 0.20,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset(
                  'assets/images/page_4.png',
                  width: screenWidth * 1, // Adjust width for responsiveness
                ),
                SizedBox(height: screenHeight * 0.04), // Scalable spacing
              ],
            ),
          ),

          // Bottom Image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: WelcomeBottomImage(),
          ),

          // Text Positioned Above the Bottom Image
          Positioned(
            bottom: screenHeight * 0.15, // Adjust position above the image
            left: screenWidth * 0.05,
            right: screenWidth * 0.05,
            child: Text(
              '''On emergency situation easily share your live location with our friends, family, and closed ones.''',
              style: TextStyle(
                fontSize: screenWidth * 0.045, // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.7),
                    offset: const Offset(2, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Dots Indicator at the Bottom Center
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.08),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: index == 3 ? const Color(0xFF904C77) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // "Get Started" Button at the Bottom Right
          Positioned(
            bottom: screenHeight * 0.02,
            right: screenWidth * 0.05,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SlidePageRoute(page: const LoginScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text(
                'Get Start',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
