import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math';

class SosHelper {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static const MethodChannel _channel = MethodChannel("sos_channel");
  static StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  /// **Start Monitoring for Drop Detection**
  static void startDropMonitoring() {
    _accelerometerSubscription = accelerometerEvents.listen((event) {
      double acceleration = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);

      if (acceleration < 2) { // If acceleration is very low, phone is likely dropped
        print("⚠ Phone drop detected! Triggering SOS...");
        triggerSOSAlert();
      }
    });
  }

  /// **Stop Monitoring Drop Detection**
  static void stopDropMonitoring() {
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
  }

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
      print("❌ Error sending SMS to $phoneNumber: $e");
    }
  }

  /// **Trigger SOS Alert (Call 1st Guardian, SMS to All)**
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
          .get(); // Fetch all guardians

      if (snapshot.docs.isNotEmpty) {
        String locationLink = await getCurrentLocation();
        String message = "🚨 SOS Alert! I need help. My location: $locationLink";

        // Call the first guardian
        String firstGuardianNumber = snapshot.docs.first.data()["number"];
        print("📞 Calling First Guardian: $firstGuardianNumber");
        await _channel.invokeMethod("makeCall", {"phoneNumber": firstGuardianNumber});

        // Send SMS to all guardians
        for (var doc in snapshot.docs) {
          String phoneNumber = doc.data()["number"];
          await sendSms(phoneNumber, message);
        }
      } else {
        print("❌ No guardians found.");
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
