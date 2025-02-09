import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:woman_safety/mainScreens/home_screen.dart';
import '../Animations/slide_page_route.dart';

class PermissionHelper {
  static Future<bool> requestAllPermissions(BuildContext context) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.camera,
      Permission.microphone,
      Permission.sms,
      Permission.contacts,
      Permission.reminders,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    return _processPermissionStatus(context, statuses);
  }

  static bool _processPermissionStatus(BuildContext context, Map<Permission, PermissionStatus> statuses) {
    bool allPermissionsGranted = true;

    statuses.forEach((permission, status) {
      String permissionName = permission.toString().split('.').last;
      String statusMessage = '$permissionName: $status';

      if (status == PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
        Fluttertoast.showToast(
          msg: statusMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (status != PermissionStatus.granted) {
        allPermissionsGranted = false;
      }
    });

    if (statuses.values.contains(PermissionStatus.permanentlyDenied)) {
      _showSettingsDialog(context);
    }

    return allPermissionsGranted;
  }

  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Some permissions are permanently denied. Please enable them in settings to continue using the app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}
