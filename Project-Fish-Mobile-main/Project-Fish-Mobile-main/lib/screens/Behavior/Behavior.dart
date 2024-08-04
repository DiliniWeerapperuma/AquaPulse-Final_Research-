// import necessary packages
import 'package:projectfish2/screens/Behavior/widget/abnormal.dart';
import 'package:projectfish2/screens/Behavior/widget/actions.dart';
import 'package:projectfish2/screens/Behavior/widget/alerts.dart';
import 'package:projectfish2/screens/Behavior/widget/appbar.dart';
import 'package:projectfish2/screens/Behavior/widget/fishbehaviral.dart';
import 'package:projectfish2/screens/Behavior/widget/pregnantImage.dart';
import 'package:projectfish2/screens/Behavior/widget/tankdeviceswitch.dart';
import 'package:projectfish2/screens/tank/widget/tankcard.dart';
import 'package:flutter/material.dart';

// create a class for the Behavior screen
class BehaviorScreen extends StatelessWidget {
  // define the route name
  static String routeName = '/home';

  // create the constructor for the Behavior screen
  const BehaviorScreen({
    Key? key,
  }) : super(key: key);

  // override the build method to return the Scaffold widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // set the app bar
      appBar: HomeAppBar(),
      // set the body
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TankBehaviorSwitch(),
              const SizedBox(height: 20),
              TankCard(),
              const SizedBox(height: 15),
              FishSchoolingAndRestWidget(),
              const SizedBox(height: 20),
              const Text(
                'Live Pregnant Fish Detector',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              PregnantFishAlert(),
              const SizedBox(height: 20),
              const Text(
                'Pregnant Fish Last Captured Image',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              PregnantFishImage(),
              const SizedBox(height: 20),
              const Text(
                'Live Fish Behaviral',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              FishBehaviral(),
              const SizedBox(height: 20),
              const Text(
                'Fish Behaviral Status',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 15),
              ActionsFish(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
