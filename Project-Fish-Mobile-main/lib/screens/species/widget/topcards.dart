import 'package:firebase_database/firebase_database.dart';
import 'package:projectfish2/config/colors.dart';
import 'package:flutter/material.dart';
import 'package:projectfish2/screens/tank/tank.dart';

class SpeciesCard extends StatefulWidget {
  SpeciesCard({Key? key}) : super(key: key);

  @override
  _SpeciesCardState createState() => _SpeciesCardState();
}

class _SpeciesCardState extends State<SpeciesCard> {
  final dbRef = FirebaseDatabase.instance.ref();
  Map<dynamic, dynamic> fishData = {};
  String? tankId = TankIdManager().tankId;
  
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    dbRef.child("$tankId/fish_detection").onValue.listen((event) {
      final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
      if (mounted) {
        setState(() {
          fishData = data;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Various Fish Species',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: fishData.length,
            itemBuilder: (context, index) {
              String key = fishData.keys.elementAt(index);
              int count = fishData[key];
              return buildSpeciesCard(key, count);
            },
          ),
        ],
      ),
    );
  }

  Widget buildSpeciesCard(String species, int count) {
    String imagePath = 'assets/images/${species.toLowerCase()}.png'; 

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.thikgreen, AppColors.thikgreen],
        ),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(imagePath, height: 60, width: 60), 
          // SizedBox(height: 2),
          Text(
            species,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.font5,
            ),
          ),
          SizedBox(height: 2),
          Text(
            '$count',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              color: AppColors.font5,
            ),
          ),
        ],
      ),
    );
  }
}
