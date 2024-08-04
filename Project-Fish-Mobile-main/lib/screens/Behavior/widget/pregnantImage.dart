import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Create a class for the pregnant fish image widget
class PregnantFishImage extends StatefulWidget {
  // Create a state for the widget
  @override
  _PregnantFishImageState createState() => _PregnantFishImageState();
}

// Create a state for the widget
class _PregnantFishImageState extends State<PregnantFishImage> {
  // Declare a variable to store the pregnant fish status
  String pregnantFishStatus = '';
  // Declare a variable to store the image URL
  String imageUrl = '';

  // Initialize the state
  @override
  void initState() {
    super.initState();
    // Load the image
    _loadImage();
  }

  // Load the image
  Future<void> _loadImage() async {
    try {
      // Get a reference to the image
      final ref = FirebaseStorage.instance
          .ref()
          .child('/1698404487/Pregnant_Fish_detection/Pregnant Fish_Img');
      // Get the download URL
      final url = await ref.getDownloadURL();
      // Update the state
      setState(() {
        imageUrl = url;
      });
    } catch (e) {
      print("Failed to load image: $e");
    }
  }

  // Build the widget
  @override
  Widget build(BuildContext context) {
    // Return a column with the image
    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Center the column content
      children: [
        imageUrl.isNotEmpty
            ? Center(
                // Center the image
                child: Container(
                  height: 230, // Adjust the height as needed
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.contain, // Maintain aspect ratio
                  ),
                ),
              )
            : CircularProgressIndicator(), // Display loading indicator
      ],
    );
  }

}

