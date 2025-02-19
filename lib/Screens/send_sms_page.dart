import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SendSmsPage extends StatefulWidget {
  @override
  _SendSmsPageState createState() => _SendSmsPageState();
}

class _SendSmsPageState extends State<SendSmsPage> {
  List<String> guardianPhones = [];
  final String customMessage = "Hello Guardian, this is an automated message from Flutter.";
  static const platform = MethodChannel('sendSMS');
  bool isLoading = false; // To show loading state

  @override
  void initState() {
    super.initState();
    fetchGuardianPhones(); // Fetch contacts when page loads
  }

  /// Fetch guardian phone numbers from Firestore
  Future<void> fetchGuardianPhones() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('guardians').get();

      setState(() {
        guardianPhones = querySnapshot.docs.map((doc) => doc['phone'].toString()).toList();
      });

      print("Fetched Guardians: $guardianPhones");
      showToast("Fetched ${guardianPhones.length} guardian contacts.");
    } catch (e) {
      print("Error fetching guardian contacts: $e");
      showToast("Error fetching guardian contacts");
    }
  }

  /// Request SMS permission
  Future<bool> requestSMSPermission() async {
    var status = await Permission.sms.status;
    if (!status.isGranted) {
      status = await Permission.sms.request();
    }
    return status.isGranted;
  }

  /// Show Flutter Toast
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  /// Send SMS to all guardian contacts
  Future<void> sendSMS() async {
    if (guardianPhones.isEmpty) {
      showToast("No guardian contacts found.");
      return;
    }

    bool permissionGranted = await requestSMSPermission();
    if (!permissionGranted) {
      showToast("SMS permission not granted.");
      return;
    }

    setState(() {
      isLoading = true; // Show loading indicator
    });

    try {
      final String result = await platform.invokeMethod('sendDirectSMS', {
        "phones": guardianPhones,
        "message": customMessage,
      });

      print("SMS Sent Successfully: $result");
      showToast("SMS Sent Successfully to ${guardianPhones.length} Guardians");
    } on PlatformException catch (e) {
      print("Failed to send SMS: ${e.message}");
      showToast("Retrying SMS...");

      // Retry sending SMS if it fails
      int retryCount = 0;
      bool success = false;
      while (!success && retryCount < 3) {
        try {
          final String retryResult = await platform.invokeMethod('sendDirectSMS', {
            "phones": guardianPhones,
            "message": customMessage,
          });
          print("SMS Sent on Retry: $retryResult");
          showToast("SMS Sent on Retry ${retryCount + 1}");
          success = true;
        } catch (e) {
          retryCount++;
        }
      }

      if (!success) {
        showToast("Failed to send SMS after 3 retries.");
      }
    }

    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Send SMS to Guardians")),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
          onPressed: sendSMS,
          child: Text("Send SMS to ${guardianPhones.length} Guardians"),
        ),
      ),
    );
  }
}
