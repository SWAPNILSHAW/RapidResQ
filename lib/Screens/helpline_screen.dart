import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

class HelplineScreen extends StatelessWidget {
  HelplineScreen({super.key});

  final List<Map<String, String>> helplines = [
    {"name": "Police", "number": "100", "icon": "assets/police.png"},
    {"name": "Ambulance", "number": "102", "icon": "assets/ambulance.png"},
    {"name": "Women Helpline", "number": "1091", "icon": "assets/women.png"},
    {"name": "Child Helpline", "number": "1098", "icon": "assets/child.png"},
    {"name": "Fire Brigade", "number": "101", "icon": "assets/fire.png"},
  ];

  /// **Function to make a direct call**
  Future<void> _callHelpline(BuildContext context, String number) async {
    // Request CALL_PHONE permission
    if (await Permission.phone.request().isGranted) {
      final Uri url = Uri.parse("tel:$number");

      try {
        await launchUrl(url);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("❌ Unable to make the call. Check phone settings.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Phone call permission is required.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Emergency Helplines", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.redAccent,
      ),
      body: ListView.builder(
        itemCount: helplines.length,
        itemBuilder: (context, index) {
          final helpline = helplines[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(helpline["icon"]!),
                backgroundColor: Colors.transparent,
              ),
              title: Text(helpline["name"]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              subtitle: Text("Call: ${helpline["number"]}"),
              trailing: IconButton(
                icon: const Icon(Icons.call, color: Colors.green),
                onPressed: () => _callHelpline(context, helpline["number"]!),
              ),
            ),
          );
        },
      ),
    );
  }
}
