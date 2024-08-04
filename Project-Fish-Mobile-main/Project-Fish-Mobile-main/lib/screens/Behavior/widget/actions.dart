import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ActionsFish extends StatefulWidget {
  @override
  _ActionsState createState() => _ActionsState();
}

class _ActionsState extends State<ActionsFish> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.reference();
  Map<String, dynamic> fishBehavior = {};
  Map<String, bool> fishBehaviorCheck = {};
  bool videoPath = false;
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _dbRef.child('1698404487').onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          fishBehavior = Map<String, dynamic>.from(data['Fish Behavior'] ?? {});
          fishBehaviorCheck = Map<String, bool>.from(data['Fish Unusual'] ?? {});
          videoPath = data['Video_Path'] as bool? ?? false;
        });
        print('Video Path: $videoPath');
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...buildBehaviorCards(fishBehavior),
        ...buildCheckCards(fishBehaviorCheck),
        buildVideoPathCard(),
      ],
    );
  }

  Widget buildVideoPathCard() {
    return Card(
      child: SwitchListTile(
        title: Text('Video Path'),
        value: videoPath,
        onChanged: (bool value) {
          setState(() {
            videoPath = value;
            _dbRef.child('1698404487/Video_Path').set(value);
          });
        },
        secondary: Icon(Icons.videocam, color: Colors.blue),
      ),
    );
  }

  List<Widget> buildBehaviorCards(Map<String, dynamic> behaviors) {
    behaviors.remove('Fish-Schooling'); // Remove Fish-Schooling entries
    return behaviors.entries.map((entry) {
      IconData iconData;
      switch (entry.key) {
        case 'Feeding':
          iconData = Icons.restaurant;
          break;
        case 'Resting':
          iconData = Icons.airline_seat_individual_suite;
          break;
        case 'Swimming':
          iconData = Icons.pool;
          break;
        default:
          iconData = Icons.help_outline;
      }
      return Card(
        child: ListTile(
          leading: Icon(iconData, color: Colors.blue),
          title: Text(entry.key),
          trailing: Text('${entry.value} times'),
        ),
      );
    }).toList();
  }

  List<Widget> buildCheckCards(Map<String, bool> checks) {
    checks.remove('Fish_Schooling'); // Remove Fish_Schooling check
    checks.remove('Long_time_rest'); // Remove Long_time_rest check
    return checks.entries.map((entry) {
      IconData iconData = Icons.help_outline;
      return Card(
        child: SwitchListTile(
          title: Text(entry.key.replaceAll('_', ' ')),
          value: entry.value,
          onChanged: (bool value) {
            setState(() {
              checks[entry.key] = value;
              _dbRef.child('1698404487/Fish Unusual/${entry.key}').set(value);
            });
          },
          secondary: Icon(iconData, color: Colors.blue),
        ),
      );
    }).toList();
  }
}
