import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectfish2/notification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projectfish2/config/theme.dart';
import 'package:projectfish2/permission.dart';
import 'package:projectfish2/provider/internet_provider.dart';
import 'package:projectfish2/provider/sign_in_provider.dart';
import 'package:projectfish2/screens/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:projectfish2/screens/tank/tank.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// This function is used to initialize the main application.
Future<void> main() async {
  // Ensure that the Flutter binding is initialized.
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase.
  await Firebase.initializeApp();
  // Initialize the timezones.
  tz.initializeTimeZones();
  // Get the IST timezone.
  var ist = tz.getLocation('Asia/Kolkata'); // IST time zone
  // Set the local timezone.
  tz.setLocalLocation(ist);
  // Run the application.
  runApp(MyApp());
  // Request permission for notifications.
  NotificationPermissions();
  // Create a notification service.
  NotificationService();
}

// This class is used to create the main application.
class MyApp extends StatefulWidget {
  // Create a state for the main application.
  @override
  _MyAppState createState() => _MyAppState();
}

// This class is used to create the state for the main application.
class _MyAppState extends State<MyApp> {
  // Create a String variable to store the tank ID.
  String? tankId = TankIdManager().tankId;
  // Create a Firebase Firestore instance.
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // This function is used to initialize the state.
  @override
  void initState() {
    super.initState();
    // Fetch the tank IDs.
    fetchTankIDs();
    // Fetch the tank IDs again.
    fetchTankIDs();
    // Initialize the timezones.
    tz.initializeTimeZones();
  }

  // This function is used to fetch the tank IDs.
  Future<void> fetchTankIDs() async {
    // Get the current user.
    final user = FirebaseAuth.instance.currentUser;
    // Check if the user is not null.
    if (user != null) {
      // Get the user ID.
      final userId = user.uid;
      // Create a collection of tank IDs.
      final tankIdsCollection = firestore.collection('users/$userId/tankids');
      // Get the tank IDs query.
      final tankIdsQuery = await tankIdsCollection.get();

      // Create a list of tank IDs.
      final List<String> tankIds = [];
      // Iterate through the documents in the query.
      for (final doc in tankIdsQuery.docs) {
        // Add the tank ID to the list.
        tankIds.add(doc.id);
      }
    }
  }

  // This function is used to build the main application.
  @override
  Widget build(BuildContext context) {
    // Return a MultiProvider with the SignInProvider and InternetProvider.
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: ((context) => SignInProvider()),
          ),
          ChangeNotifierProvider(
            create: ((context) => InternetProvider()),
          ),
        ],
        // Return a MaterialApp with the theme and the home screen.
        child: ScreenUtilInit(
            designSize: const Size(375, 812),
            builder: (context, child) {
              return MaterialApp(
                theme: theme(),
                debugShowCheckedModeBanner: false,
                home: const SplashScreen(),
              );
            }));
  }
}