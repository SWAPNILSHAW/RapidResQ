import 'package:flutter/material.dart';

class CustomWelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content of the screen
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo.png', width: 200), // Replace with your asset
                const SizedBox(height: 20),
                const Text(
                  "Empowering Women",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Pink curved background at the bottom

        ],
      ),
    );
  }
}

// Custom Clipper for the curve
class BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 100); // Start from bottom-left
    path.quadraticBezierTo(
        size.width / 2, size.height, size.width, size.height - 100); // Curve
    path.lineTo(size.width, 0); // Top-right
    path.close(); // Close the path
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
