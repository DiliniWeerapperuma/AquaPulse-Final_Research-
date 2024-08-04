import 'package:projectfish2/screens/tank/tank.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CleaningDateCard extends StatefulWidget {
  @override
  _CleaningDateCardState createState() => _CleaningDateCardState();
}

class _CleaningDateCardState extends State<CleaningDateCard> {
  late DatabaseReference _cleanTankDaysReference;
  int cleanTankDays = 0;
  String? tankId = TankIdManager().tankId;

  @override
  void initState() {
    super.initState();
    _cleanTankDaysReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}/Funtion_1 Task 02/Clean tank days');
    _cleanTankDaysReference.onValue.listen((event) {
      var data = event.snapshot.value;

      if (data is List<dynamic> && data.isNotEmpty) {
        setState(() {
          cleanTankDays = data[0] as int; // Cast the first element to int
        });
      } else {
        print("Unexpected data format in clean tank days: $data");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        buildAlertCard(
          icon: FontAwesomeIcons.shower, // Change the icon as needed
          title: 'Tank Cleaning Reminder',
          subtitle: '$cleanTankDays Days remaining for next clean!',
          backgroundColor:
              Colors.transparent, // Change the background color as needed
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
                color: Colors.blue, // Change the icon color if needed
              ),
              title: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  color: Colors.blue, // Change the text color if needed
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
