import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:projectfish2/screens/tank/tank.dart'; // Make sure this import is correct

class DeadFishAlrt extends StatefulWidget {
  @override
  _DeadFishAlrtState createState() => _DeadFishAlrtState();
}

class _DeadFishAlrtState extends State<DeadFishAlrt> {
  late DatabaseReference _deadFishReference;
  late DatabaseReference _diseasePredictionReference;
  int deadFishCount = 0;
  String? tankId =
      TankIdManager().tankId; // Assuming this gets the correct tank ID
  String cardSubtitle =
      ' dead fish detected in the tank!'; // Initial subtitle message
  Map<String, double> diseasePredictions = {}; // To store disease predictions

  @override
  void initState() {
    super.initState();
    _deadFishReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}/Death_fish_detection/Dead Fish');
    _diseasePredictionReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}/Funtion 4/predictions');

    _deadFishReference.onValue.listen((event) {
      var data = event.snapshot.value;

      if (data is int) {
        setState(() {
          deadFishCount = data;
          cardSubtitle = '$deadFishCount dead fish detected in the tank!';
        });
      } else {
        print("Unexpected data format for dead fish count: $data");
      }
    });

    _diseasePredictionReference.onValue.listen((event) {
      var predictions = event.snapshot.value as Map<dynamic, dynamic>?;

      setState(() {
        diseasePredictions = predictions?.map(
                (key, value) => MapEntry(key, double.tryParse(value) ?? 0.0)) ??
            {};
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        buildAlertCard(
          icon: FontAwesomeIcons.fish,
          title: 'Dead Fish Alert ($deadFishCount)',
          subtitle: cardSubtitle,
          backgroundColor: Colors.red.withOpacity(0.1),
          onTap: () => showDiseaseWarning(context),
        ),
      ],
    );
  }

  void showDiseaseWarning(BuildContext context) {
    // Determine if there's a high disease prediction
    String warningMessage =
        "Please check water quality and remove dead fish immediately.";
    List<Widget> warningWidgets = [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          warningMessage,
          style: TextStyle(fontSize: 16),
        ),
      ),
    ];

    diseasePredictions.forEach((disease, probability) {
      if (probability > 50.0) {
        warningWidgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: Colors.black),
                children: [
                  TextSpan(text: ""),
                  TextSpan(
                    text: "High possibility of $disease detected!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    });

    // Show popup message
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.yellow[700]),
              SizedBox(width: 10),
              Expanded(child: Text("Dead Fish Detected")),
            ],
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: warningWidgets,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                primary: Colors.white,
              ),
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        );
      },
    );

    // Optionally update card subtitle
    setState(() {
      cardSubtitle = "Remove the dead fish from the tank.";
    });
  }

  Widget buildAlertCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Container(
          color: backgroundColor,
          child: SizedBox(
            height: 75,
            child: Card(
              child: ListTile(
                leading: Icon(icon, color: Colors.red),
                title: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 17,
                    color: Colors.red,
                  ),
                ),
                subtitle: Text(subtitle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
