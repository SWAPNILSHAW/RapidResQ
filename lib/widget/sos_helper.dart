import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class SosHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const MethodChannel _channel = MethodChannel("sos_channel");

  /// **Get User's Current Location (Google Maps Link)**
  static Future<String> getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return "https://maps.google.com/?q=${position.latitude},${position.longitude}";
    } catch (e) {
      print("❌ Error fetching location: $e");
      return "Location unavailable.";
    }
  }

  /// **Send SMS via Native Android**
  static Future<void> sendSms(String phoneNumber, String message) async {
    try {
      await _channel.invokeMethod("sendSMS", {
        "phoneNumber": phoneNumber,
        "message": message,
      });
      print("✅ SOS SMS sent to $phoneNumber");
    } catch (e) {
      print("❌ Error sending SMS: $e");
    }
  }

  /// **Trigger SOS Alert (Call & SMS)**
  static Future<void> triggerSOSAlert() async {
    User? user = _auth.currentUser;
    if (user == null) {
      print("❌ User not logged in.");
      return;
    }

    if (!(await _requestPermissions())) {
      print("❌ Permissions not granted.");
      return;
    }

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('guardians')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        String phoneNumber = snapshot.docs.first.data()["number"];
        print("📞 Calling Guardian: $phoneNumber");

        await _channel.invokeMethod("makeCall", {"phoneNumber": phoneNumber});

        String locationLink = await getCurrentLocation();
        String message = "🚨 SOS Alert! I need help. My location: $locationLink";

        await sendSms(phoneNumber, message);
      } else {
        print("❌ No guardian found.");
      }
    } catch (e) {
      print("❌ Error triggering SOS alert: $e");
    }
  }

  /// **Request Necessary Permissions**
  static Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.phone,
      Permission.sms,
      Permission.location
    ].request();

    return statuses[Permission.phone]!.isGranted &&
        statuses[Permission.sms]!.isGranted &&
        statuses[Permission.location]!.isGranted;
  }
}
