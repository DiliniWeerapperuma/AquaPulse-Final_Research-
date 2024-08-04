import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:app_settings/app_settings.dart';

// StatefulWidget to show the notification permissions
class NotificationPermissions extends StatefulWidget {
  @override
  _NotificationPermissionsState createState() => _NotificationPermissionsState();
}

class _NotificationPermissionsState extends State<NotificationPermissions> {
  // Instance of FlutterLocalNotificationsPlugin
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // Request notification permissions
    requestNotificationPermissions();
  }

  // Request notification permissions
  void requestNotificationPermissions() async {
    // Get the result of the request as a bool
    final bool result = (await flutterLocalNotificationsPlugin) as bool;
    // Open the app settings
openAppSettings();
    // If the result is not null and true, permission is granted
    if (result != null && result) {
      print("Notification Permission Granted");
      // Do something if permission is granted
    } else {
      print("Notification Permission Denied");
      // Handle the situation when permission is denied
    }
  }

// Open the app settings
void openAppSettings() {
  AppSettings.openAppSettings();
}

  @override
  Widget build(BuildContext context) {
    // Build your Scaffold or any other widget depending on your app's structure
    return Container();
  }
}

