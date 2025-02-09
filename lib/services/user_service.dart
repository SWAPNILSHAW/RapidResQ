import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  /// Fetch user details from Firebase Realtime Database
  Future<Map<String, String>> getUserDetails() async {
    Map<String, String> userDetails = {
      'name': 'Loading...',
      'email': 'Loading...',
      'phone': 'Loading...',
      'guardian': 'Loading...',
    };

    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      return {
        'name': 'No user signed in',
        'email': 'N/A',
        'phone': 'N/A',
        'guardian': 'N/A',
      };
    }

    try {
      String userId = firebaseUser.uid;
      DatabaseReference userRef = _database.child('users').child(userId);

      DataSnapshot snapshot = await userRef.get();

      if (snapshot.exists && snapshot.value != null) {
        Map<dynamic, dynamic>? data = snapshot.value as Map<dynamic, dynamic>?;

        userDetails['name'] = data?['name'] ?? 'Not available';
        userDetails['email'] = data?['email'] ?? firebaseUser.email ?? 'Not available';
        userDetails['phone'] = data?['phone'] ?? 'Not available';
        userDetails['guardian'] = data?['guardian'] ?? 'Not available';

        // Store data in SharedPreferences for local storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userName', userDetails['name']!);
        prefs.setString('userEmail', userDetails['email']!);
        prefs.setString('userPhone', userDetails['phone']!);
        prefs.setString('userGuardian', userDetails['guardian']!);
      }
    } catch (error) {
      return {
        'name': 'Error: $error',
        'email': 'Error',
        'phone': 'Error',
        'guardian': 'Error',
      };
    }

    return userDetails;
  }

  /// Load user details from SharedPreferences (local storage)
  Future<Map<String, String>> loadUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('userName') ?? 'Loading...',
      'email': prefs.getString('userEmail') ?? 'Loading...',
      'phone': prefs.getString('userPhone') ?? 'Loading...',
      'guardian': prefs.getString('userGuardian') ?? 'Loading...',
    };
  }

  /// Update user details in Firebase Realtime Database
  Future<void> updateUserDetails(Map<String, String> updatedDetails) async {
    final User? firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      throw Exception('No user signed in');
    }

    try {
      String userId = firebaseUser.uid;
      DatabaseReference userRef = _database.child('users').child(userId);

      // Update user data in Firebase
      await userRef.update({
        'name': updatedDetails['name'],
        'email': updatedDetails['email'],
        'phone': updatedDetails['phone'],
        'guardian': updatedDetails['guardian'],
      });

      // Also, update the SharedPreferences data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('userName', updatedDetails['name']!);
      prefs.setString('userEmail', updatedDetails['email']!);
      prefs.setString('userPhone', updatedDetails['phone']!);
      prefs.setString('userGuardian', updatedDetails['guardian']!);
    } catch (error) {
      throw Exception('Error updating user details: $error');
    }
  }
}
