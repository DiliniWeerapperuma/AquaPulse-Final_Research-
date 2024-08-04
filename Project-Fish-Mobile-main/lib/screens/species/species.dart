import 'package:projectfish2/screens/species/widget/alerts.dart';
import 'package:projectfish2/screens/species/widget/appbar.dart';
import 'package:projectfish2/screens/species/widget/deadfish.dart';
import 'package:projectfish2/screens/species/widget/speciesvideo.dart';
import 'package:projectfish2/screens/species/widget/topcards.dart';
import 'package:projectfish2/screens/tank/widget/tankcard.dart';
import 'package:flutter/material.dart';
import 'widget/tankcageswitch.dart';

class SpeciesScreen extends StatelessWidget {
  static String routeName = '/home';

  const SpeciesScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add a tank card

              // Add a tank cage switch
              TankCageSwitch(),
              const SizedBox(height: 20),
              TankCard(),
              const SizedBox(height: 15),
              // Add a title
              const Text(
                'Live Dead Fish Count',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              // Add a dead fish alert
              DeadFishAlrt(),
              const SizedBox(height: 20),
              // Add a title
              const Text(
                'Live Dead Fish Detection',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Add a dead fish widget
              DeadFish(),
              const SizedBox(height: 15),
              // Add a species card
              SpeciesCard(),
              const SizedBox(height: 30),
              // Add a title
              const Text(
                'Live Fish Detection',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              // Add a species video
              SpeciesVideo(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
