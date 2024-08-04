import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:projectfish2/screens/tank/tank.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  //late final variables for database references
  late final DatabaseReference _ADC_FailureReference;
  late final DatabaseReference _camera_failReference;
  late final DatabaseReference _Salinity_FailureReference;
  late final DatabaseReference _Temperature_FailureReference;
  late final DatabaseReference _LightSensorFailureReference;
  late final DatabaseReference _remindersReference;
  late final DatabaseReference _cleanTankDaysReference;
  late final DatabaseReference _diseasePredictionsReference;
  //late final variables for notifications
  late final FlutterLocalNotificationsPlugin _notificationsPlugin;
  //late final variable for tankId
  String? tankId = TankIdManager().tankId;

  NotificationService() {
    _initializeNotifications();
    _setupFirebaseListeners();
  }

  void _initializeNotifications() async {
    tz.initializeTimeZones();

    var initializationSettingsAndroid =
        AndroidInitializationSettings('drawable/logo');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _notificationsPlugin = FlutterLocalNotificationsPlugin();
    await _notificationsPlugin.initialize(initializationSettings);
  }

 void _setupFirebaseListeners() {
    // Camera Fail
    _camera_failReference = FirebaseDatabase.instance
        .reference()
        .child('1698404487/hardware_failure/camera_fail');
    // ADC Fail
    _ADC_FailureReference = FirebaseDatabase.instance
        .reference()
        .child('1698404487/hardware_failure/ADC_Failure');
    // Salinity Fail
    _Salinity_FailureReference = FirebaseDatabase.instance
        .reference()
        .child('1698404487/hardware_failure/Salinity_Failure');
    // Temperature Fail
    _Temperature_FailureReference = FirebaseDatabase.instance
        .reference()
        .child('1698404487/hardware_failure/Temperature_Failure');
    // Light Sensor Fail
    _LightSensorFailureReference = FirebaseDatabase.instance
        .reference()
        .child('1698404487/hardware_failure/light_sensor_failure');

    // Clean Tank Days
    _cleanTankDaysReference = FirebaseDatabase.instance
        .reference()
        .child('1698404487/Funtion_1 Task 02/Clean tank days');

    // Dead Fish Count
    DatabaseReference _deadFishCountReference = FirebaseDatabase.instance
        .reference()
        .child('1698404487/Death_fish_detection/Dead Fish');

    int previousDeadFishCount = 0;

   // Listen for changes in the number of dead fish
    _deadFishCountReference.onValue.listen((event) {
      // Get the new data
      var data = event.snapshot.value;

      // Check if the new data is an integer and if it is greater than the previous count
      if (data is int && data > previousDeadFishCount) {
        // Show a notification with the new count
        _showNotification(
            'Dead Fish Alert', '$data dead fish detected in your tank!');
        // Update the previous count
        previousDeadFishCount = data;
      } else if (data is int) {
        // Update the count even if no new dead fish are detected
        previousDeadFishCount =
            data; // Update the count even if no new dead fish are detected
      } else {
        // Print an error message if the data is not an integer
        print("Unexpected data format for dead fish count: $data");
      }
    });

    _diseasePredictionsReference = FirebaseDatabase.instance
        .reference()
        .child('1698404487/Funtion 4/predictions');

    _diseasePredictionsReference.onValue.listen((event) {
      var data = event.snapshot.value;

      if (data is Map) {
        data.forEach((disease, percentageString) {
          double percentage = double.tryParse(percentageString) ?? 0.0;
          if (percentage > 50.0) {
            _showNotification('Disease Alert: $disease',
                'High risk detected: ${percentage.toStringAsFixed(2)}%');
          }
        });
      } else {
        print("Unexpected data format for disease predictions: $data");
      }
    });
    _cleanTankDaysReference.onValue.listen((event) {
      var data = event.snapshot.value;

      if (data is List<dynamic> && data.isNotEmpty) {
        var days = data[0];
        if (days == 0) {
          _showNotification('Tank Cleaning', 'Cleaning date is today');
        }
      } else {
        print("Unexpected data format in clean tank days: $data");
      }
    });

    _ADC_FailureReference.onValue.listen((event) {
      if (event.snapshot.value == true) {
        _showNotification('ADC Failure', 'Data converter has been Failed');
      }
    });
    _camera_failReference.onValue.listen((event) {
      if (event.snapshot.value == true) {
        _showNotification('Camera Failure', 'Camera has been Failed');
      }
    });

    _Salinity_FailureReference.onValue.listen((event) {
      if (event.snapshot.value == true) {
        _showNotification('Salinity Failure', 'Salinity sensor has failed');
      }
    });

    _Temperature_FailureReference.onValue.listen((event) {
      if (event.snapshot.value == true) {
        _showNotification(
            'Temperature Failure', 'Temperature sensor has failed');
      }
    });

    _LightSensorFailureReference.onValue.listen((event) {
      if (event.snapshot.value == true) {
        _showNotification('Light Sensor Failure', 'Light sensor has failed');
      }
    });

    _remindersReference = FirebaseDatabase.instance
        .reference()
        .child('1698404487/other_data/reminders');

    _remindersReference.onChildAdded.listen((event) {
      _scheduleReminder(event.snapshot);
    });
  }

 void _scheduleReminder(DataSnapshot snapshot) {
    try {
      // Retrieve the reminder data from the snapshot
      final reminderData = snapshot.value as Map<dynamic, dynamic>;
      final title = reminderData['title'];
      final year = reminderData['dateYear'];
      final month = reminderData['dateMonth'];
      final day = reminderData['dateDay'];
      final hour = reminderData['timeHour'];
      final minute = reminderData['timeMinute'];

      // Convert the time to IST
      var istTime = tz.TZDateTime(
          tz.getLocation('Asia/Kolkata'), year, month, day, hour, minute);

      // Validate the date and time
      if (_isValidDateTime(istTime.year, istTime.month, istTime.day,
          istTime.hour, istTime.minute)) {
        // Create the notification details
        var androidPlatformChannelSpecifics = AndroidNotificationDetails(
            'reminder_channel_id', 'Reminders',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true);
        var platformChannelSpecifics =
            NotificationDetails(android: androidPlatformChannelSpecifics);

        // Schedule the notification
        _notificationsPlugin.zonedSchedule(snapshot.key.hashCode, title,
            'Reminder for $title', istTime, platformChannelSpecifics,
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time);
      } else {
        print("Invalid date/time data for reminder: $title");
      }
    } catch (e) {
      print("Error scheduling reminder: $e");
    }
  }

  // Validate the date and time
  bool _isValidDateTime(int year, int month, int day, int hour, int minute) {
    // Add validation logic for the date and time
    return true; // Placeholder, add actual validation
  }

  // Show a notification
  Future<void> _showNotification(String title, String subtitle) async {
    // Create the notification details
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your_channel_id', 'your_channel_name',
        importance: Importance.max, priority: Priority.high, showWhen: false);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    // Show the notification
    await _notificationsPlugin.show(
        0, title, subtitle, platformChannelSpecifics);
  }
}
