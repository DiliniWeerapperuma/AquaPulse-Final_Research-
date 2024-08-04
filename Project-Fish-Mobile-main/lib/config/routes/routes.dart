import 'package:projectfish2/screens/tank/tank.dart';
import 'package:flutter/widgets.dart';

// Map to store the routes for different screens
final Map<String, WidgetBuilder> routes = {
  // LoginScreen.routeName: (context) => const LoginScreen(),
  // SplashScreen.routeName: (context) => const SplashScreen(),
  // Route for the TankScreen
  TankScreen.routeName: (context) => const TankScreen()
};

