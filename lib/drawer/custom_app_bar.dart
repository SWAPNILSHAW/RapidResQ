import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onMenuPressed;
  final VoidCallback? onActionPressed;
  final bool showLeading; // New parameter to control leading visibility

  const CustomAppBar({
    super.key,
    required this.title,
    required this.onMenuPressed,
    this.onActionPressed,
    this.showLeading = true, // Default value is true, you can change it when needed
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF904C77),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: MediaQuery.of(context).size.width * 0.06,
          fontWeight: FontWeight.bold,
          color: Colors.white,  // Ensure the text is visible
        ),
      ),
      leading: showLeading // Conditionally show leading widget
          ? Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: onMenuPressed,
        ),
      )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: onActionPressed ?? () {},
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);  // Ensure app bar height
}
