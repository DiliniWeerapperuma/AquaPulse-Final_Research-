import 'package:projectfish2/screens/tank/tank.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class IOTAlertCard extends StatefulWidget {
  @override
  _IOTAlertCardState createState() => _IOTAlertCardState();
}

class _IOTAlertCardState extends State<IOTAlertCard> {
  late DatabaseReference _ADC_FailureReference;
  late DatabaseReference _camera_failReference;
  late DatabaseReference _Salinity_FailureReference;
  late DatabaseReference _Temperature_FailureReference;
  late DatabaseReference _light_sensor_failureReference;

  bool camera_fail = false;
  bool ADC_Failure = false;
  bool Salinity_Failure = false;
  bool Temperature_Failure = false;
  bool light_sensor_failure = false;
  String? tankId = TankIdManager().tankId;

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    // _initializeNotifications();
    _camera_failReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}/hardware_failure/camera_fail');

    // Initialize Firebase Realtime Database references
    _ADC_FailureReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}/hardware_failure/ADC_Failure');

    _Salinity_FailureReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}/hardware_failure/Salinity_Failure');

    _Temperature_FailureReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}/hardware_failure/Temperature_Failure');
    _light_sensor_failureReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}/hardware_failure/light_sensor_failure');

    _camera_failReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          camera_fail = event.snapshot.value == true;
        });
      }
    });

    _ADC_FailureReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          ADC_Failure = event.snapshot.value == true;
        });
      }
    });

    // Set up a listener to update tempHumiSensorFailure in real-time
    _Salinity_FailureReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          Salinity_Failure = event.snapshot.value ==
              true; // Check if temp & humi sensor failure is false
        });
      }
    });

    _Temperature_FailureReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          Temperature_Failure = event.snapshot.value ==
              true; // Check if temp & humi sensor failure is false
        });
      }
    });

    _light_sensor_failureReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          light_sensor_failure = event.snapshot.value ==
              true; // Check if temp & humi sensor failure is false
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display an alert if light sensor failure is detected
        if (camera_fail)
          buildAlertCard(
            icon: FontAwesomeIcons.solidLightbulb,
            title: 'Camera Failure!',
            subtitle: 'Camera has been Failed',
            backgroundColor: Colors.transparent,
          ),
        if (ADC_Failure)
          buildAlertCard(
            icon: FontAwesomeIcons.solidLightbulb,
            title: 'ADC Failure!',
            subtitle: 'Data converter has been Failed',
            backgroundColor: Colors.transparent,
          ),
        if (Salinity_Failure)
          buildAlertCard(
            icon: FontAwesomeIcons.waterLadder,
            title: 'Sensor Failure!',
            subtitle: 'Salinity Sensors Failed',
            backgroundColor: Colors.transparent,
          ),

        if (Temperature_Failure)
          buildAlertCard(
            icon: FontAwesomeIcons.thermometerFull,
            title: 'Sensor Failure!',
            subtitle: 'Temperature Sensors Failed',
            backgroundColor: Colors.transparent,
          ),

        if (light_sensor_failure)
          buildAlertCard(
            icon: FontAwesomeIcons.boltLightning,
            title: 'Sensor Failure!',
            subtitle: 'Light Sensors Failed',
            backgroundColor: Colors.transparent,
          ),
      ],
    );
  }

  Widget buildAlertCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
  }) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(30), // Adjust the border radius as needed
      child: Container(
        color: backgroundColor, // Set the background color
        child: SizedBox(
          height: 75, // Adjust the height as needed
          child: Card(
            child: ListTile(
              leading: Icon(
                icon,
                color: Colors.red, // Change the icon color if needed
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  color: Colors.red, // Change the text color if needed
                ),
              ),
              subtitle: Text(subtitle),
            ),
          ),
        ),
      ),
    );
  }
}
