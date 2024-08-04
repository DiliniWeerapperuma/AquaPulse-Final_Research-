import 'package:projectfish2/config/colors.dart';
import 'package:projectfish2/screens/home/home_screen.dart';
import 'package:flutter/material.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: const Color(0xFFF5F5F5),
      leading: IconButton(
        icon: Image.asset(
          'assets/icons/back.png',
          width: 27,
          height: 27,
        ),
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
          );
        },
      ),
      title: const Align(
        alignment: Alignment.center,
        child: Text(
          'Species',
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
