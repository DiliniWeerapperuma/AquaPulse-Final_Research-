import 'package:projectfish2/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Create a Profile widget
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

/// Create a state for the Profile widget
class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: AppColors.homebg,
      padding: const EdgeInsets.all(15),
      child: GestureDetector(
        onTap: () {
          /// Navigate to the ProfileScreen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  ProfileScreen(), // Navigate to your ProfileScreen
            ),
          );
        },
        child: const Row(
          children: [
            Flexible(
              child: Icon(
                /// Use the icon you want here
                FontAwesomeIcons.bars,
                // color: AppColors.,
                size: 20.0, // Adjust the size as needed
              ),
            ),
          ],
        ),
      ),
    );
  }
}

