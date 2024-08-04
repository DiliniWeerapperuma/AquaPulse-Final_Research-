import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Stateful widget to display the pregnant fish alert
class PregnantFishAlert extends StatefulWidget {
  @override
  _PregnantFishAlertState createState() => _PregnantFishAlertState();
}

class _PregnantFishAlertState extends State<PregnantFishAlert> {
  // Reference to the database to get the pregnant fish status
  late DatabaseReference _pregnantFishReference;
  // Variable to store the current pregnant fish status
  String pregnantFishStatus = '';

  @override
  void initState() {
    super.initState();
    // Update the reference to the path of the pregnant fish status
    _pregnantFishReference = FirebaseDatabase.instance
        .reference()
        .child('1698404487/Function 2 Task 03/pregnant Fish');
    _pregnantFishReference.onValue.listen((event) {
      var data = event.snapshot.value;

      if (data is String) {
        // Expecting a string value
        setState(() {
          pregnantFishStatus = data;
        });
      } else {
        print("Unexpected data format for pregnant fish status: $data");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildAlertCard(
          icon: FontAwesomeIcons.fish, // You can choose an appropriate icon
          title: 'Pregnant Fish Status',
          subtitle: pregnantFishStatus,
          backgroundColor: Colors.transparent, // Change color to indicate alert
        ),
      ],
    );
  }

  // Function to build the alert card
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

