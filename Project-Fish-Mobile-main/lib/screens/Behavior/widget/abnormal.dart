import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class FishSchoolingAndRestWidget extends StatefulWidget {
  @override
  _FishSchoolingAndRestWidgetState createState() =>
      _FishSchoolingAndRestWidgetState();
}

class _FishSchoolingAndRestWidgetState
    extends State<FishSchoolingAndRestWidget> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.reference();
  bool fishSchooling = false;
  bool longTimeRest = false;

  @override
  void initState() {
    super.initState();
    _dbRef
        .child('1698404487/Fish Unusual')
        .onValue
        .listen((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        setState(() {
          fishSchooling = data['Fish_Schooling'] as bool? ?? false;
          longTimeRest = data['Long_time_rest'] as bool? ?? false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "Fish Tank Status",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            buildSwitchListTile(
              title: 'Fish Schooling',
              value: fishSchooling,
              onChanged: (bool value) => updateValue('Fish_Schooling', value),
              color: fishSchooling ? Colors.red : Colors.green,
              icon: Icons.group,
              subtitle: fishSchooling
                  ? 'Abnormal Schooling Detected'
                  : 'Normal Schooling Behavior',
            ),
            buildSwitchListTile(
              title: 'Long Time Rest',
              value: longTimeRest,
              onChanged: (bool value) => updateValue('Long_time_rest', value),
              color: longTimeRest ? Colors.red : Colors.green,
              icon: Icons.timer,
              subtitle: longTimeRest
                  ? 'Abnormal Resting Detected'
                  : 'Normal Resting Behavior',
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                getStatusMessage(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: getStatusColor(),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSwitchListTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required Color color,
    required IconData icon,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: color),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: color,
      ),
    );
  }

  void updateValue(String key, bool value) {
    setState(() {
      if (key == 'Fish_Schooling') {
        fishSchooling = value;
      } else if (key == 'Long_time_rest') {
        longTimeRest = value;
      }
      _dbRef.child('1698404487/Fish Unusual/$key').set(value);
    });
  }

  String getStatusMessage() {
    if (fishSchooling && longTimeRest) {
      return 'Urgent Attention Required: Multiple abnormal behaviors detected.';
    } else if (fishSchooling || longTimeRest) {
      return 'Attention Needed: Abnormal behavior detected.';
    } else {
      return 'All Normal - No abnormal behaviors detected.';
    }
  }

  Color getStatusColor() {
    if (fishSchooling || longTimeRest) {
      return Colors.red;
    } else {
      return Colors.blue; // Warning color
    }
  }
}
