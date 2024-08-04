import 'package:projectfish2/config/colors.dart';
import 'package:projectfish2/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Get the preferred size of the widget
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  // Build the widget
  @override
  Widget build(BuildContext context) {
    // Return the app bar
    return AppBar(
      // Remove the elevation
      elevation: 0,
      // Set the background color
      backgroundColor: const Color(0xFFF5F5F5),
      // Add an icon button to the leading position
      leading: IconButton(
        // Set the icon
        icon: Image.asset(
          'assets/icons/back.png',
          width: 27,
          height: 27,
        ),
        // When pressed, push a replacement route
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
      ),
      // Set the title
      title: const Align(
        alignment: Alignment.center,
        child: Text(
          'Behavior',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 17,
            color: AppColors.font1,
          ),
        ),
      ),
    );
  }
}