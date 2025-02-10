import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SosHelper {
  static stt.SpeechToText speech = stt.SpeechToText();
  static BuildContext? globalContext;
  static CollectionReference<Map<String, dynamic>>? _guardianCollection;

  static Future<void> initialize(BuildContext context) async {
    globalContext = context;
    await Firebase.initializeApp();
    _initializeGuardianCollection();
    _startDropDetection();
    _startVoiceDetection();
  }

  static void _initializeGuardianCollection() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        _guardianCollection = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('guardians');
      } else {
        _guardianCollection = null;
      }
    });
  }

  static Future<String> getCurrentLocationLink() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      return "http://maps.google.com/?q=${position.latitude},${position.longitude}"; // Corrected format
    } catch (e) {
      print("Error getting location: $e");
      return "Could not get location.";
    }
  }

  static Future<List<String>> getGuardianContacts() async {
    List<String> contacts = [];
    if (_guardianCollection != null) {
      try {
        QuerySnapshot querySnapshot = await _guardianCollection!.get();

        for (var doc in querySnapshot.docs) {
          contacts.add(doc['number']);
        }
      } catch (e) {
        print("❌ Error fetching guardians: $e");
      }
    } else {
      print("❌ Guardian collection not initialized. User not logged in?");
    }
    return contacts;
  }

  static Future<void> sendSOSMessage() async {
    if (globalContext == null) return;

    String locationLink = await getCurrentLocationLink();
    String message = "🚨 SOS Alert! I need help. My location: $locationLink";
    List<String> recipients = await getGuardianContacts();

    if (recipients.isNotEmpty) {
      await sendWhatsAppMessage(recipients, message);
      await saveToFirebase(message, recipients);

      ScaffoldMessenger.of(globalContext!).showSnackBar(
        const SnackBar(content: Text("🚨 SOS Alert Sent!")),
      );
    } else {
      ScaffoldMessenger.of(globalContext!).showSnackBar(
        const SnackBar(content: Text("No guardians found. Add guardians first.")),
      );
    }
  }

  static Future<void> sendWhatsAppMessage(
      List<String> contacts, String message) async {
    String encodedMessage = Uri.encodeComponent(message);

    for (String phoneNumber in contacts) {
      phoneNumber = phoneNumber.replaceAll(" ", "");
      phoneNumber = phoneNumber.replaceAll("+", "");
      if (!phoneNumber.startsWith("91")) {
        phoneNumber = "91" + phoneNumber;
      }

      print("Phone number: $phoneNumber");
      String url = "https://wa.me/$phoneNumber?text=$encodedMessage";
      print("WhatsApp URL: $url");

      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        print("Could not launch WhatsApp for $phoneNumber");
        ScaffoldMessenger.of(globalContext!).showSnackBar(
          SnackBar(content: Text("Could not send message to $phoneNumber")),
        );
      }
    }
  }

  static Future<void> saveToFirebase(String message, List<String> contacts) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      CollectionReference sosCollection = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('sos_alerts');
      await sosCollection.add({
        "message": message,
        "contacts": contacts,
        "timestamp": FieldValue.serverTimestamp()
      });
    } else {
      print("User not logged in. Cannot save SOS alert.");
    }
  }

  static void _startDropDetection() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      double threshold = 25.0;
      if (event.x.abs() > threshold ||
          event.y.abs() > threshold ||
          event.z.abs() > threshold) {
        print("📉 Drop detected! Sending SOS...");
        sendSOSMessage();
      }
    });
  }

  static void _startVoiceDetection() async {
    bool available = await speech.initialize();
    if (available) {
      speech.listen(
        onResult: (result) {
          if (result.recognizedWords.toLowerCase().contains("bachao")) {
            print("🗣️ 'Bachao' detected! Sending SOS...");
            sendSOSMessage();
          }
        },
        listenFor: Duration(seconds: 30),
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }
}

// Example usage in your widget (e.g., SosAlertPage):

class SosAlertPage extends StatefulWidget {
  @override
  _SosAlertPageState createState() => _SosAlertPageState();
}

class _SosAlertPageState extends State<SosAlertPage> {
  bool _isUserLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        _isUserLoggedIn = user != null;
      });
    });
  }

  void _handleSOS() async {
    if (_isUserLoggedIn) {
      await SosHelper.sendSOSMessage();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please log in to send SOS.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SOS Alert")), // Example AppBar
      body: Center( // Example body
        child: ElevatedButton(
          onPressed: _handleSOS,
          child: const Text("Send SOS"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleSOS,
        child: const Icon(Icons.sos),
      ),
    );
  }
}