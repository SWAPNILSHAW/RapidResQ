import 'package:flutter/material.dart';
import 'package:woman_safety/Screens/send_sms_page.dart';

import '../widget/sos_helper.dart';

class SosAlertPage extends StatefulWidget {
  @override
  _SosAlertPageState createState() => _SosAlertPageState();
}

class _SosAlertPageState extends State<SosAlertPage> {
  bool isSending = false;

  @override
  void initState() {
    super.initState();
    SosHelper.initialize(context); // ✅ Corrected context initialization
  }

  void _handleSOS() async {
    setState(() {
      isSending = true;
    });

    await SendSmsPage(); // ✅ Removed unnecessary context argument

    setState(() {
      isSending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("🚨 SOS Alert"),backgroundColor: Colors.redAccent,),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning, color: Colors.red, size: 80),
            const SizedBox(height: 20),
            const Text(
              "Press the button to send an SOS alert!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: isSending ? null : _handleSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // ✅ Fixed deprecation issue
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
