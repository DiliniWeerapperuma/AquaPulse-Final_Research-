import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class InternetProvider extends ChangeNotifier {
  //Declare a boolean variable to store the internet connection status
  bool _hasInternet = false;
  //Declare a getter to return the boolean variable
  bool get hasInternet => _hasInternet;

  //Constructor to initialize the internet connection status
  InternetProvider() {
    //Call the checkInternetConnection method to check the internet connection
    checkInternetConnection();
  }

  //Method to check the internet connection
  Future checkInternetConnection() async {
    //Call the Connectivity class to check the internet connection
    var result = await Connectivity().checkConnectivity();
    //Check the result of the connection and set the boolean variable accordingly
    if (result == ConnectivityResult.none) {
      _hasInternet = false;
    } else {
      _hasInternet = true;
    }
    //Notify the listeners that the internet connection status has changed
    notifyListeners();
  }
}