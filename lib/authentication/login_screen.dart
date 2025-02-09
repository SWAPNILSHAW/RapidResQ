import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:woman_safety/authentication/signup_screen.dart';

import '../global/global.dart';
import '../splash screen/splash_screen.dart';
import '../widget/custom_text_field.dart';
import '../widget/progress_dialog.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();// Key for form
  bool _isPasswordVisible = false;

  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();

  // This is to validate the form and submit
  void validateAndSubmitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      loginUserNow(); // Proceed to login if the form is valid
    } else {
      // Custom validation logic
      if (emailTextEditingController.text.isEmpty ||
          !emailTextEditingController.text.contains("@")) {
        Fluttertoast.showToast(msg: "Email address is not valid.");
      } else if (passwordTextEditingController.text.isEmpty) {
        Fluttertoast.showToast(msg: "Password is Required.");
      }
    }
  }

  loginUserNow() async {
    // Show Progress Dialog using a correct context
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext context) {
        return const ProgressDialog(
          message: 'Processing, Please wait...',
        );
      },
    );

    try {
      UserCredential userCredential = await fAuth.signInWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      );
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        currentFirebaseUser = firebaseUser;
        Navigator.pop(context); // Close progress dialog
        Fluttertoast.showToast(msg: "Login Successful.");

        // Navigate to home screen (or replace with the intended screen)
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const SplashScreen()));
      } else {
        Navigator.pop(context); // Close progress dialog
        Fluttertoast.showToast(msg: 'Error Occurred during Login.');
      }

    } catch (error) {
      // Close the progress dialog on error
      Navigator.pop(context);
      debugPrint('Error: $error');

      if (error is FirebaseAuthException) {
        print('FirebaseAuthException: ${error.code}');
        if (error.code == 'invalid-credential') {
          Fluttertoast.showToast(msg: 'Incorrect Email or Password, please try again.');
        }
      } else {
        Fluttertoast.showToast(msg: 'An error occurred: ${error.toString()}');
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey, // Assign the key to the form
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2, // 20% of screen height
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Login as a User',
                  style: TextStyle(
                      fontSize: 26,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 10,
                ),

                // Custom email text field with validation
                CustomTextField(
                  controller: emailTextEditingController,
                  labelText: 'Email',
                  hintText: 'Enter Your email Address',
                  keyboardType: TextInputType.emailAddress,
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email is required';
                    } else if (!value.contains('@')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 10,
                ),

                // Custom password text field with validation
                CustomTextField(
                  controller: passwordTextEditingController,
                  labelText: 'Password',
                  hintText: 'Enter your Password',
                  keyboardType: TextInputType.text,
                  obscureText: !_isPasswordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10,),

                // Login button
                ElevatedButton(
                  onPressed: validateAndSubmitForm, // Submit form if valid
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF904C77),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),

                // Row for signup redirect
                Row(
                  children: [
                    const Text(
                      "Don't Have an Account?",
                      style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const SignupScreen()),
                        );
                      },
                      child: const Text(
                        'Create Here',
                        style: TextStyle(
                          color: Color(0xFF904C77),
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
