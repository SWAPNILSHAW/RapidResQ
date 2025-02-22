import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For orientation lock
import 'package:google_fonts/google_fonts.dart';
import 'package:woman_safety/splash%20screen/splash_screen.dart';
import 'package:woman_safety/widget/sos_helper.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restricting the app to portrait mode
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, // Lock to portrait mode
  ]);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  /// **Restart the App**
  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_MyAppState>()?.restartApp();
  }
}

class _MyAppState extends State<MyApp> {
  Key key = UniqueKey();

  @override
  void initState() {
    super.initState();
    SosHelper.startDropMonitoring(); // Start drop detection when app launches
  }

  @override
  void dispose() {
    SosHelper.stopDropMonitoring(); // Stop monitoring when app closes
    super.dispose();
  }

  /// **Restart the App**
  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: MaterialApp(
        title: 'Woman Safety App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          textTheme: GoogleFonts.poppinsTextTheme(),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
