import 'package:projectfish2/screens/tank/widget/alerts.dart';
import 'package:projectfish2/screens/tank/widget/alertsIOT.dart';
import 'package:projectfish2/screens/tank/widget/appbar.dart';
import 'package:projectfish2/screens/tank/widget/topcontroller.dart';
import 'package:projectfish2/screens/tank/widget/tankdeviceswitch.dart';
import 'package:projectfish2/screens/tank/widget/tankcard.dart';
import 'package:projectfish2/screens/tank/widget/reminders.dart';

import 'package:flutter/material.dart';

class TankIdManager {
  static TankIdManager? _instance;

  String? _tankId;
  String? _tankName;
  String? _tankType;
  String? _tankAge;

  factory TankIdManager() {
    _instance ??= TankIdManager._();
    return _instance!;
  }

  TankIdManager._();

  String? get tankId => _tankId;
  String? get tankName => _tankName;
  String? get tanktype => _tankType;
  String? get tanksize => _tankAge;

  void setTankId(String? newTankId) {
    _tankId = newTankId;
  }

  void setTankName(String? newTankName) {
    _tankName = newTankName;
  }

  void setTankType(String? newTankType) {
    _tankType = newTankType;
  }

  void setTankAge(String? newTankAge) {
    _tankAge = newTankAge;
  }
}

class TankScreen extends StatelessWidget {
  static String routeName = '/home';
  final String? tankId;
  final String? tanktitle;
  final String? tanktype;
  final String? tanksize;

  const TankScreen({
    Key? key,
    this.tankId,
    this.tanktitle,
    this.tanktype,
    this.tanksize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TankIdManager().setTankId(tankId);
    TankIdManager().setTankName(tanktitle);
    TankIdManager().setTankType(tanktype);
    TankIdManager().setTankAge(tanksize);

    return Scaffold(
      appBar: HomeAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TankBehaviorSwitch(),
              const SizedBox(height: 20),
              TankCard(),
              const SizedBox(height: 15),
              CleaningDateCard(),
              const SizedBox(height: 10),
              IOTAlertCard(),
              const SizedBox(height: 20),
              TopCard(),
              const SizedBox(height: 15),
              Reminder(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
