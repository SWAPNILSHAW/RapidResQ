import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon; // Add suffixIcon parameter

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.keyboardType,
    required this.obscureText,
    this.validator,
    this.suffixIcon, // Accept suffixIcon
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        labelStyle: const TextStyle(
            color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
        hintStyle: const TextStyle(
            color: Colors.black, fontSize: 10, fontWeight: FontWeight.bold),
        suffixIcon: suffixIcon, // Set suffixIcon
      ),
      validator: validator,
    );
  }
}
