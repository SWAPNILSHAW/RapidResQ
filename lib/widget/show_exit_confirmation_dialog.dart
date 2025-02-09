import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> showExitConfirmationDialog(BuildContext context) async {
  // Show a confirmation dialog when the back button is pressed
  bool exit = await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text("Exit"),
        content: const Text("Do you really want to exit the app?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Don't exit the app
            },
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              SystemNavigator.pop();            },
            child: const Text("Yes"),
          ),
        ],
      );
    },
  );
  return exit ?? false; // Return whether the user confirmed exit
}
