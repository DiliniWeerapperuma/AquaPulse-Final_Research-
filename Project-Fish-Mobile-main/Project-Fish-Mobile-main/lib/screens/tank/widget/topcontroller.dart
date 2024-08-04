import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:projectfish2/config/colors.dart';
import 'package:projectfish2/screens/tank/tank.dart';
import 'dart:async'; // Import the async library

class TopCard extends StatefulWidget {
  @override
  _TopCardState createState() => _TopCardState();
}

class _TopCardState extends State<TopCard> {
  DatabaseReference? _dbRef;
  Map<dynamic, dynamic> data = {};
  StreamSubscription<DatabaseEvent>? _subscription;
  String predictedClassProbability = "Loading...";

  double calculateAmmonia(double pH, double temperature) {
    // Placeholder calculation
    return (pH * temperature) / 10;
  }

  double calculateNitrate(double dissolvedOxygen, double salinity) {
    // Placeholder calculation
    return (dissolvedOxygen + salinity) / 2;
  }

  void updateFirebase(DatabaseReference dbRef, double ammonia, double nitrate) {
    dbRef.update({"Ammonia": ammonia, "Nitrate": nitrate});
  }

  @override
  void initState() {
    super.initState();
    final String? tankId = TankIdManager().tankId;
    fetchPredictedClassProbability();
    if (tankId != null) {
      _dbRef = FirebaseDatabase.instance
          .ref()
          .child(tankId)
          .child('environmental_conditions');
      _subscription = _dbRef!.onValue.listen((DatabaseEvent event) {
        var snapshotData = event.snapshot.value as Map<dynamic, dynamic>;

        // Ensure values are treated as doubles
        double pH = (snapshotData['pH']?.toDouble()) ?? 7.0;
        double temperature = (snapshotData['temperature']?.toDouble()) ?? 25.0;
        double dissolvedOxygen =
            (snapshotData['Dissolved oxygen']?.toDouble()) ?? 8.0;
        double salinity = (snapshotData['Salinity']?.toDouble()) ?? 35.0;

        double ammonia = calculateAmmonia(pH, temperature);
        double nitrate = calculateNitrate(dissolvedOxygen, salinity);

        updateFirebase(_dbRef!, ammonia, nitrate);

        setState(() {
          data = Map<dynamic, dynamic>.from(snapshotData);
          data['Ammonia'] = ammonia;
          data['Nitrate'] = nitrate;
        });
      });
    }
  }

  void fetchPredictedClassProbability() {
    final String? tankId = TankIdManager().tankId;

    // Setting up the reference to the specific value in the database
    DatabaseReference probabilityRef = FirebaseDatabase.instance
        .reference()
        .child('$tankId/Funtion_1 Task 01');
    print('Firebase Reference: $probabilityRef');

    probabilityRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null &&
          data.containsKey('Predicted Class Probability (%):')) {
        // Note the colon at the end
        double probability = double.tryParse(
                data['Predicted Class Probability (%):'].toString()) ??
            0;
        String formattedProbability = "${probability.toStringAsFixed(1)}";

        setState(() {
          predictedClassProbability = formattedProbability;
          print('Formatted Probability: $predictedClassProbability');
        });
      } else {
        setState(() {
          predictedClassProbability = "No data";
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  IconData getIconForCondition(String condition) {
    switch (condition.toLowerCase()) {
      case "ammonia":
        return Icons.opacity; // Example icon, change as needed
      case "dissolved oxygen":
        return Icons.bubble_chart; // Example icon, change as needed
      case "nitrate":
        return Icons.grain; // Example icon, change as needed
      case "salinity":
        return Icons.water_drop; // Example icon, change as needed
      case "light_intensity":
        return Icons.wb_sunny; // Example icon, change as needed
      case "ph":
        return Icons.thermostat; // Example icon, change as needed
      case "temperature":
        return Icons.thermostat_auto; // Example icon, change as needed
      default:
        return Icons.help_outline; // Default icon
    }
  }

  Widget buildPredictedProbabilityBox() {
    return Container(
      width: 70, // Adjust width as needed
      margin: EdgeInsets.all(4),
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.thikgreen, AppColors.thikgreen],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.show_chart,
              color: AppColors.font5, size: 30), // Example icon
          SizedBox(height: 8),
          Text("%",
              style: TextStyle(color: AppColors.font5, fontSize: 20)), // Short label
          SizedBox(height: 8),
          Text(predictedClassProbability,
              style: TextStyle(color: AppColors.font6, fontSize: 20)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> shortNames = {
      "Ammonia": "NH3",
      "Dissolved oxygen": "O2",
      "Nitrate": "NO3",
      "Salinity": "Sal",
      "light intensity": "Light", // Make sure the key matches exactly
      "pH": "pH",
      "temperature": "Temp"
    };

    List<Widget> boxes = data.entries.map((entry) {
      String keyName =
          entry.key.toString().replaceAll('_', ' '); // Replace underscores
      String displayValue;
      if (entry.value is double) {
        displayValue = (entry.value as double).toStringAsFixed(1);
      } else {
        displayValue = entry.value.toString();
      }

      IconData icon = getIconForCondition(entry.key);
      String shortName = shortNames[keyName] ?? keyName;

      return Container(
        width: 70, // Adjust width as needed
        margin: EdgeInsets.all(4),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.thikgreen, AppColors.thikgreen],
          ),
          borderRadius: BorderRadius.circular(8),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: AppColors.font5, size: 30),
            SizedBox(height: 8),
            Text(shortName, style: TextStyle(color: AppColors.font5)),
            SizedBox(height: 8),
            Text(displayValue,
                style: TextStyle(color: AppColors.font6, fontSize: 20)),
          ],
        ),
      );
    }).toList();

    int halfLength = (boxes.length / 2).ceil();
    List<Widget> firstRowBoxes = boxes.sublist(0, halfLength);
    List<Widget> secondRowBoxes = [
      buildPredictedProbabilityBox(),
      ...boxes.sublist(halfLength)
    ];
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tank Controllers',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: firstRowBoxes),
          ),
          SizedBox(height: 10), // Spacing between the rows
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: secondRowBoxes),
          ),
        ],
      ),
    );
  }
}
