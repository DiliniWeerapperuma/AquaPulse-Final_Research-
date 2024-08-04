import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'components/body.dart';

class ProfileScreen extends StatelessWidget {
  final user = FirebaseAuth.instance.currentUser;

  static String routeName = '/profile';

   ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Body(user: user),    );
  }
}
