import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DeadFish extends StatefulWidget {
  @override
  _DeadFishState createState() => _DeadFishState();
}

class _DeadFishState extends State<DeadFish> {
  VideoPlayerController? _controller;
  String videoUrl = '';

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  _loadVideo() async {
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('1698404487/Dead_fish_detection/Dead_fish_video');
      final videoUrl = await ref.getDownloadURL();
      _controller = VideoPlayerController.network(videoUrl)
        ..initialize().then((_) {
          setState(() {});
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
        ElevatedButton(
          onPressed: () {
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
