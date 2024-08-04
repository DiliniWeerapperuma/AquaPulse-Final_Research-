import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

ThemeData theme() {
  return ThemeData(
    // sets the background color of the scaffold
    scaffoldBackgroundColor: Colors.white,
    // sets the font family of the app
    fontFamily: "Fredoka",
    // sets the app bar theme
    appBarTheme: appBarTheme(),
    // sets the visual density of the app
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
AppBarTheme appBarTheme() {
  return AppBarTheme(
    // sets the color of the app bar
    color: Colors.white,
    // sets the elevation of the app bar
    elevation: 0,
    // sets the icon theme of the app bar
    iconTheme: const IconThemeData(color: Colors.black), systemOverlayStyle: SystemUiOverlayStyle.dark, toolbarTextStyle: const TextTheme(
      // sets the title large text style
      titleLarge: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ).bodyMedium, titleTextStyle: const TextTheme(
      // sets the title large text style
      titleLarge: TextStyle(color: Color(0XFF8B8B8B), fontSize: 18),
    ).titleLarge,
  );
}