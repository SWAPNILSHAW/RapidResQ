import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestAllPermissions(BuildContext context) async {
    bool allPermissionsGranted = false;

    while (!allPermissionsGranted) {
      Map<Permission, PermissionStatus> statuses = await _requestPermissions();

      allPermissionsGranted = _processPermissionStatus(context, statuses);

      if (!allPermissionsGranted) {
        // Wait a bit before asking again
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    return allPermissionsGranted;
  }

  static Future<Map<Permission, PermissionStatus>> _requestPermissions() async {
    return await [
      Permission.location,
      Permission.camera,
      Permission.microphone,
      Permission.contacts,
      Permission.audio,
      Permission.sensors,
      Permission.notification,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  static bool _processPermissionStatus(BuildContext context, Map<Permission, PermissionStatus> statuses) {
    bool allPermissionsGranted = true;
    List<Permission> deniedPermissions = [];
    bool hasPermanentlyDenied = false;

    statuses.forEach((permission, status) {
      String permissionName = permission.toString().split('.').last;
      String statusMessage = '$permissionName: $status';

      if (status == PermissionStatus.denied) {
        Fluttertoast.showToast(
          msg: "Permission Denied: $statusMessage. Asking again...",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        deniedPermissions.add(permission);
      }

      if (status == PermissionStatus.permanentlyDenied) {
        hasPermanentlyDenied = true;
        Fluttertoast.showToast(
          msg: "Permission Permanently Denied: $statusMessage",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }

      if (status != PermissionStatus.granted) {
        allPermissionsGranted = false;
      }
    });

    if (hasPermanentlyDenied) {
      _showSettingsDialog(context);
    }

    // Ask only for denied permissions again (not permanently denied)
    if (deniedPermissions.isNotEmpty) {
      Future.delayed(const Duration(seconds: 1), () {
        _requestDeniedPermissions(deniedPermissions);
      });
    }

    return allPermissionsGranted;
  }

  static Future<void> _requestDeniedPermissions(List<Permission> deniedPermissions) async {
    await deniedPermissions.request();
  }

  static void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
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
