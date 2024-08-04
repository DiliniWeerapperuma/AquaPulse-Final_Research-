import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:projectfish2/screens/tank/tank.dart';

class Spots extends StatefulWidget {
  @override
  _SpotsState createState() => _SpotsState();
}

class _SpotsState extends State<Spots> {
  Map<dynamic, dynamic> predictions = {};
  String? tankId = TankIdManager().tankId;
  DatabaseReference? ref;
  StreamSubscription<DatabaseEvent>? _databaseSubscription;

  @override
  void initState() {
    super.initState();
    tankId = TankIdManager().tankId;
    if (tankId != null) {
      ref = FirebaseDatabase.instance.ref('$tankId/Funtion 4/predictions');
      fetchPredictions();
    }
  }

  void fetchPredictions() {
    if (ref != null) {
      _databaseSubscription = ref!.onValue.listen((DatabaseEvent event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          setState(() {
            predictions = data;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _databaseSubscription?.cancel(); // Cancels the subscription
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...predictions.entries
              .map((entry) => predictionBar(entry.key, entry.value.toString()))
              .toList(),
        ],
      ),
    );
  }

  Widget predictionBar(String disease, String probability) {
    double progress = double.parse(probability) / 100.0;
    Color progressBarColor;
    if (progress == 1) {
      progressBarColor = Colors.redAccent; // Fully Positive redAccent
    } else if (progress >= 0.5) {
      progressBarColor = Colors.orange; // Intermediate
    } else {
      progressBarColor = Colors.greenAccent[700]!; // Critical
    }

    return Container(
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                disease,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(2)}%', // Displaying the percentage
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(progressBarColor),
              minHeight: 20,
            ),
          ),
        ],
      ),
    );
  }
}
