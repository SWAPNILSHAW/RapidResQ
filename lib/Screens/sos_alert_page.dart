import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widget/sos_helper.dart';

class SosAlertPage extends StatefulWidget {
  @override
  _SosAlertPageState createState() => _SosAlertPageState();
}

class _SosAlertPageState extends State<SosAlertPage> {
  bool isSending = false;
  String statusMessage = "Press the button to send an SOS alert!";

  /// **Check and Request Required Permissions**
  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.phone,
      Permission.sms
    ].request();

    if (statuses[Permission.location]!.isDenied ||
        statuses[Permission.phone]!.isDenied ||
        statuses[Permission.sms]!.isDenied) {
      setState(() {
        statusMessage = "⚠️ Permissions required to send SOS!";
      });
      return false;
    }
    return true;
  }

  /// **Handle SOS Button Press**
  void _handleSOS() async {
    bool hasPermissions = await _requestPermissions();
    if (!hasPermissions) return;

    setState(() {
      isSending = true;
      statusMessage = "🚨 Sending SOS Alert...";
    });

    try {
      await SosHelper.triggerSOSAlert();
      setState(() {
        statusMessage = "✅ SOS Alert Sent!";
      });
    } catch (e) {
      setState(() {
        statusMessage = "❌ Error Sending SOS: $e";
      });
    } finally {
      setState(() => isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🚨 SOS Alert"),
        backgroundColor: Colors.redAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            Text(
              statusMessage,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isSending ? null : _handleSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: isSending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("SEND SOS", style: TextStyle(fontSize: 20, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
