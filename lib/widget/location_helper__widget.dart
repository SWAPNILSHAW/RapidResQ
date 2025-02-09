import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationHelperWidget extends StatelessWidget {
  final Function(Position?) onLocationFetched; // Callback to send location back

  const LocationHelperWidget({Key? key, required this.onLocationFetched}) : super(key: key);

  Future<Position> _determinePosition(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Location Services are disabled."),
          action: SnackBarAction(
            label: "Enable",
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          ),
        ),
      );
      return Future.error("Location Services are disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location Permissions are denied");
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Location permissions are permanently denied."),
          action: SnackBarAction(
            label: "Settings",
            onPressed: () {
              Geolocator.openAppSettings();
            },
          ),
        ),
      );
      return Future.error("Location Permissions are permanently denied");
    }

    return await Geolocator.getCurrentPosition();
  }

  void _fetchLocation(BuildContext context) async {
    try {
      Position position = await _determinePosition(context);
      onLocationFetched(position); // Send the position back via callback
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      onLocationFetched(null); // Return null if fetching failed
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fetch location on widget build
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchLocation(context));

    return const SizedBox.shrink(); // No UI for this widget
  }
}
