import 'package:projectfish2/screens/home/widget/addtank.dart';
import 'package:projectfish2/screens/home/widget/profileIcon.dart';
import 'package:projectfish2/screens/tank/tank.dart';
import 'package:flutter/material.dart';
import 'package:projectfish2/config/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

//Class for the Home Screen
class HomeScreen extends StatefulWidget {
  //Create a State for the Home Screen
  @override
  _HomeScreen createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  //Declare variables for batteryPercentage and camera_status
  String batteryPercentage = '';
  String camera_status = '';
  //Declare variable for tankId
  String? tankId = TankIdManager().tankId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Get the current user from Firebase Auth
    final user = FirebaseAuth.instance.currentUser!;
    //Return the Scaffold with the AppBar and body
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const Profile(),
      ),
      body: SingleChildScrollView(
        //padding: EdgeInsets.all(10),
        child: Container(
          //color: Color(0xFFF5F5F5),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(user.photoURL!),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Hi,${user.displayName!}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppColors.font3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Let’s take care of your beautiful fishes!',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 17,
                      color: AppColors.font4,
                    ),
                  ),
                  SizedBox(height: 5), // Adds some space before the image
                  Center(
                    // Center the image
                    child: Image.asset(
                      "assets/images/finder.png",
                      width: 220, // Set your desired image width
                      height: 220, // Set your desired image height
                      fit: BoxFit.cover, // Cover the container's bounds
                    ),
                  ),
                  SizedBox(height: 5), // Adds space after the image
                  Text(
                    "Enhance Your Fish Feeding with AI",
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      AddTank(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
