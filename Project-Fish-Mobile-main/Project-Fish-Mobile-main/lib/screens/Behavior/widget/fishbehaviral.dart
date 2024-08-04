import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FishBehaviral extends StatefulWidget {
  @override
  _FishBehaviralState createState() => _FishBehaviralState();
}

class _FishBehaviralState extends State<FishBehaviral> {
  // Create a VideoPlayerController to control the video player
  VideoPlayerController? _controller;
  // Holds the URL of the video
  String videoUrl = '';

  @override
  void initState() {
    super.initState();
    // Load the video from Firebase Storage
    _loadVideo();
  }

  _loadVideo() async {
    try {
      // Get a reference to the video file stored in Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('1698404487/fish_behaviral/fish_behaviral_video');
      // Get the download URL of the video
      final videoUrl = await ref.getDownloadURL();
      // Create a new VideoPlayerController and initialize it with the video URL
      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          // Set the state when the video is initialized
          setState(() {});
          // Play the video when it's initialized
          _controller!.play(); // Autoplay the video
        }).catchError((error) {
          print("Error initializing video player: $error");
        });
    } catch (e) {
      print("Error loading video: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // Display the video player if it's initialized
        _controller != null && _controller!.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              )
            : Container(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
        // Display a button to pause or play the video
        ElevatedButton(
          onPressed: () {
            // If the video is initialized, toggle between pause and play
            if (_controller != null) {
              setState(() {
                if (_controller!.value.isPlaying) {
                  _controller!.pause();
                } else {
                  _controller!.play();
                }
              });
            }
          },
          child: Icon(
            _controller != null && _controller!.value.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
  }
}

