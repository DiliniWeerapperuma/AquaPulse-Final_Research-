import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:projectfish2/screens/tank/tank.dart';

class SpotReachAlrt extends StatefulWidget {
  @override
  _SpotReachAlrtState createState() => _SpotReachAlrtState();
}

class _SpotReachAlrtState extends State<SpotReachAlrt> {
  late DatabaseReference _predictionsReference;
  Map<String, double> predictionPercentages = {};

  String? tankId = TankIdManager().tankId; // Assuming this gets the correct tank ID

  @override
  void initState() {
    super.initState();
    // Update the reference to the path of the predictions
    _predictionsReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}/Funtion 4/predictions');
    _predictionsReference.onValue.listen((event) {
      var data = event.snapshot.value;

      if (data is Map) {
        // Expecting a map with disease names and their prediction percentages
        setState(() {
          predictionPercentages = data.map((key, value) => MapEntry(key, double.tryParse(value) ?? 0.0));
        });
      } else {
        print("Unexpected data format for predictions: $data");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...predictionPercentages.entries.map((entry) {
          if (entry.value > 50.0) {
            return buildAlertCard(
              icon: FontAwesomeIcons.fish, // Choose an appropriate icon
              title: 'Disease Alert: ${entry.key}',
              subtitle: 'High risk detected: ${entry.value.toStringAsFixed(2)}%',
              backgroundColor: Colors.transparent, // Change color to indicate alert
            );
          }
          return SizedBox.shrink(); // No alert for predictions below 50%
        }).toList(),
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
      borderRadius: BorderRadius.circular(30), // Adjust the border radius as needed
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
                  fontSize: 14,
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
