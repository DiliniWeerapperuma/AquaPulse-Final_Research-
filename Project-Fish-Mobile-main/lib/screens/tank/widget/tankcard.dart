import 'package:projectfish2/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:projectfish2/screens/tank/tank.dart';
import 'dart:async';

class TankCard extends StatefulWidget {
  @override
  _TankCardState createState() => _TankCardState();
}

class _TankCardState extends State<TankCard> {
  late DatabaseReference _databaseReferenceDissolvedOxygen;
  late DatabaseReference _databaseReferenceTemperature;
  String dissolvedOxygenPercentage = '';
  String temperaturePercentage = '';
  final double maxDissolvedOxygen = 10.0; // Example value
  final double maxTemperature = 40.0; // Example value
  Timer? _debounceTimerOxygen;
  Timer? _debounceTimerTemperature;

  void _updateOxygenLevel(double oxygenLevel) {
    if (_debounceTimerOxygen?.isActive ?? false) _debounceTimerOxygen!.cancel();
    _debounceTimerOxygen = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          int oxygenPercentage =
              (oxygenLevel / maxDissolvedOxygen * 100).round();
          dissolvedOxygenPercentage = '$oxygenPercentage%';
        });
      }
    });
  }

  void _updateTemperature(double temp) {
    if (_debounceTimerTemperature?.isActive ?? false)
      _debounceTimerTemperature!.cancel();
    _debounceTimerTemperature = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          int tempPercentage = (temp / maxTemperature * 100).round();
          temperaturePercentage = '$tempPercentage%';
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    String? tankId = TankIdManager().tankId;

    _databaseReferenceDissolvedOxygen = FirebaseDatabase.instance
        .reference()
        .child('$tankId/environmental_conditions/Dissolved oxygen');

    _databaseReferenceTemperature = FirebaseDatabase.instance
        .reference()
        .child('$tankId/environmental_conditions/temperature');

    _databaseReferenceDissolvedOxygen.onValue.listen((event) {
      if (event.snapshot.value != null) {
        double oxygenLevel = double.parse(event.snapshot.value.toString());
        _updateOxygenLevel(oxygenLevel);
      }
    });

    _databaseReferenceTemperature.onValue.listen((event) {
      if (event.snapshot.value != null) {
        double temp = double.parse(event.snapshot.value.toString());
        _updateTemperature(temp);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimerOxygen?.cancel();
    _debounceTimerTemperature?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? tankName = TankIdManager().tankName;
    String? tanktype = TankIdManager().tanktype;
    String? tanksize = TankIdManager().tanksize;

    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 138,
            width: 344,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  AppColors.cardleft,
                  AppColors.cardright,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/gold.png',
                        height: 120,
                        width: 120,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Image.asset(
                          //   'assets/icons/Fish.png',
                          //   height: 20,
                          //   width: 20,
                          // ),
                          // const SizedBox(width: 5),
                          Text(
                            '$tanktype',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.font5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$tankName',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          color: AppColors.font5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$tanksize',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          color: AppColors.font6,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/Scuba Tank.png',
                            height: 20,
                            width: 20,
                            color: AppColors.font6,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            dissolvedOxygenPercentage,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.font6,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Image.asset(
                            'assets/icons/Temperature High.png',
                            height: 20,
                            width: 20,
                            color: AppColors.font6,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            temperaturePercentage,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.font6,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
