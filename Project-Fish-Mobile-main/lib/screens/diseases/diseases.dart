import 'package:flutter/material.dart';
import 'package:projectfish2/screens/diseases/widget/alerts.dart';
import 'package:projectfish2/screens/diseases/widget/medicineRec.dart';
import 'package:projectfish2/screens/diseases/widget/spots.dart';
import 'package:projectfish2/screens/diseases/widget/tankcageswitch.dart';
import 'package:projectfish2/screens/tank/widget/appbar.dart';
import 'package:projectfish2/screens/tank/widget/tankcard.dart';

class ExerciseScreen extends StatefulWidget {
  // create a const ExerciseScreen widget class
  const ExerciseScreen({Key? key}) : super(key: key);

  // create a StatefulWidget that will use the ExerciseScreen class
  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    // return a scroll view with padding and a column of widgets
    return Scaffold(
      appBar: HomeAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TankBehaviorSwitchb(),
              const SizedBox(height: 20),
              TankCard(),
              const SizedBox(height: 15),
              const Text(
                'Diseases Prediction ',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              SpotReachAlrt(),
              const SizedBox(height: 20),
              const Text(
                'Diseases Possibilities',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Spots(),
              const SizedBox(height: 10),
              MedicineRecomendation(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
