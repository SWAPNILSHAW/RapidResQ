import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class SosHelper {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  static stt.SpeechToText speech = stt.SpeechToText();
  static BuildContext? globalContext;

  static Future<void> initialize(BuildContext context) async {
    globalContext = context;
    await Firebase.initializeApp();
    _initializeNotifications();
    _startDropDetection();
    _startVoiceDetection();
  }

  /// Initialize local notifications
  static Future<void> _initializeNotifications() async {
    var androidInitialize =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: androidInitialize);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  /// Show SOS notification
  static Future<void> showNotification() async {
    var androidDetails = const AndroidNotificationDetails(
        'sos_channel', 'SOS Alerts',
        importance: Importance.high, priority: Priority.high);
    var generalNotificationDetails =
    NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
        0,
        "🚨 SOS Alert Sent!",
        "Your emergency alert has been sent to contacts.",
        generalNotificationDetails);
  }

  /// Get current location as a Google Maps link
  static Future<String> getCurrentLocationLink() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
  }

  /// Fetch guardian contacts from Firebase Firestore
  static Future<List<String>> getGuardianContacts() async {
    List<String> contacts = [];
    try {
      CollectionReference guardians =
      FirebaseFirestore.instance.collection('guardians');
      QuerySnapshot querySnapshot = await guardians.get();

      for (var doc in querySnapshot.docs) {
        contacts.add(doc['phone']);
      }
    } catch (e) {
      print("❌ Error fetching guardians: $e");
    }
    return contacts;
  }

  /// Send SOS alert via SMS & WhatsApp
  static Future<void> sendSOSMessage() async {
    if (globalContext == null) return;

    String locationLink = await getCurrentLocationLink();
    String message = "🚨 SOS Alert! I need help. My location: $locationLink";
    List<String> recipients = await getGuardianContacts();

    if (recipients.isNotEmpty) {
      await sendSMS(message: message, recipients: recipients, sendDirect: true);
      await sendWhatsAppMessage(recipients, message);
      await saveToFirebase(message, recipients);
      showNotification();

      ScaffoldMessenger.of(globalContext!).showSnackBar(
          const SnackBar(content: Text("🚨 SOS Alert Sent!")));
    }
  }

  /// Send message via WhatsApp
  static Future<void> sendWhatsAppMessage(
      List<String> contacts, String message) async {
    String encodedMessage = Uri.encodeComponent(message);

    for (String phoneNumber in contacts) {
      String url = "https://wa.me/$phoneNumber?text=$encodedMessage";
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  /// Save SOS alert details to Firebase
  static Future<void> saveToFirebase(
      String message, List<String> contacts) async {
    CollectionReference sosCollection =
    FirebaseFirestore.instance.collection('sos_alerts');
    await sosCollection.add({
      "message": message,
      "contacts": contacts,
      "timestamp": FieldValue.serverTimestamp()
    });
  }

  /// Detect sudden drop (fall detection)
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

  /// Detect "bachao" voice command
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
        listenFor: Duration(seconds: 30), // Auto-restart after 30 seconds
        cancelOnError: false,
        listenMode: stt.ListenMode.confirmation,
      );
    }
  }
}
