import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../global/global.dart';
import '../splash screen/splash_screen.dart';
import '../widget/custom_text_field.dart';
import '../widget/progress_dialog.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController nameTextEditingController = TextEditingController();
  TextEditingController emailTextEditingController = TextEditingController();
  TextEditingController phoneTextEditingController = TextEditingController();
  TextEditingController passwordTextEditingController = TextEditingController();
  bool _isPasswordVisible = false;
  void validateAndSubmitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      saveUserInfoNow();
    } else {
      if (nameTextEditingController.text.isEmpty ||
          nameTextEditingController.text.length < 3) {
        Fluttertoast.showToast(msg: "Name must be at least 3 characters.");
      } else if (emailTextEditingController.text.isEmpty ||
          !emailTextEditingController.text.contains("@")) {
        Fluttertoast.showToast(msg: "Email address is not valid.");
      } else if (phoneTextEditingController.text.isEmpty) {
        Fluttertoast.showToast(msg: "Phone number is required.");
      } else if (phoneTextEditingController.text.length != 10) {
        Fluttertoast.showToast(msg: "Phone number should be 10 digits.");
      } else if (passwordTextEditingController.text.isEmpty ||
          passwordTextEditingController.text.length < 6) {
        Fluttertoast.showToast(msg: "Password must be at least 6 characters.");
      }
    }
  }

  saveUserInfoNow() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return const ProgressDialog(
            message: 'Processing, Please wait...',
          );
        });

    try {
      UserCredential userCredential =
      await fAuth.createUserWithEmailAndPassword(
        email: emailTextEditingController.text.trim(),
        password: passwordTextEditingController.text.trim(),
      );
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        Map userMap = {
          "id": firebaseUser.uid,
          "name": nameTextEditingController.text.trim(),
          "email": emailTextEditingController.text.trim(),
          "phone": phoneTextEditingController.text.trim(),
        };

        DatabaseReference driverRef =
        FirebaseDatabase.instance.ref().child("users");
        driverRef.child(firebaseUser.uid).set(userMap);

        currentFirebaseUser = firebaseUser;
        Navigator.pop(context); // Close progress dialog
        Fluttertoast.showToast(msg: "Account has been Created.");

        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const SplashScreen()));
      } else {
        Navigator.pop(context);
        Fluttertoast.showToast(msg: 'Account has not been Created.');
      }
    } catch (error) {
      Navigator.pop(context);
      if (error is FirebaseAuthException &&
          error.code == 'email-already-in-use') {
        Fluttertoast.showToast(
            msg: 'This email is already registered with another account.');
      } else if (error is FirebaseAuthException &&
          error.code == 'invalid-email') {
        Fluttertoast.showToast(msg: 'Enter the correct Email Address.');
      } else {
        Fluttertoast.showToast(msg: 'Error: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Light theme background
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.12,
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset('assets/images/logo.png'),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Register as a User',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.black, // Light theme text color
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: nameTextEditingController,
                  labelText: 'Name',
                  hintText: 'Enter your Name',
                  keyboardType: TextInputType.text,
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Name is required';
                    } else if (value.length < 3) {
                      return 'Name must be at least 3 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: emailTextEditingController,
                  labelText: 'Email',
                  hintText: 'Enter your email address',
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
                const SizedBox(height: 10),
                CustomTextField(
                  controller: phoneTextEditingController,
                  labelText: 'Phone',
                  hintText: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                  obscureText: false,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    } else if (value.length != 10) {
                      return 'Phone number should be 10 digits.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: passwordTextEditingController,
                  labelText: 'Password',
                  hintText: 'Enter your password',
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
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: validateAndSubmitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF904C77), // Light theme button color
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                  ),
                  child: const Text(
                    'Create Account',
                    style: TextStyle(
                      color: Colors.white, // Light theme button text color
                      fontSize: 20,
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.black54), // Light theme text
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const LoginScreen()),
                        );
                      },
                      child: const Text(
                        'Login Here',
                        style: TextStyle(
                          color: Color(0xFF904C77), // Light theme text link color
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
