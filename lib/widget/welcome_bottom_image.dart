import 'package:flutter/material.dart';

class WelcomeBottomImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.48, // Adjust height as needed
      alignment: Alignment.bottomCenter,
      child: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/Welcome_bottom_image.png',
            fit: BoxFit.cover, // Ensures the image covers the container
            width: double.infinity,
            height: double.infinity,
          ),
        ],
      ),
    );
  }
}
