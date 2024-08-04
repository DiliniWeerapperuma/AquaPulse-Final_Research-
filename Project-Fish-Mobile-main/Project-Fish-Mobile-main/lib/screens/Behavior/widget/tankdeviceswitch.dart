import 'package:projectfish2/screens/species/species.dart';
import 'package:projectfish2/screens/diseases/diseases.dart';
import 'package:projectfish2/screens/tank/tank.dart';
import 'package:flutter/material.dart';

class TankBehaviorSwitch extends StatelessWidget {
  // Key for this widget
  TankBehaviorSwitch({
    Key? key,
  }) : super(key: key);
  // Tank ID
  String? tankId = TankIdManager().tankId;
  // Tank Name
  String? tankName = TankIdManager().tankName;
  // Tank Type
  String? tanktype = TankIdManager().tanktype;
  // Tank Size
  String? tanksize = TankIdManager().tanksize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TankScreen(
                            tankId: tankId,
                            tanktitle: tankName,
                            tanktype: tanktype,
                            tanksize: tanksize)),
                  );
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          'assets/icons/rosecircle.png',
                          width: 53,
                          height: 53,
                        ),
                        Positioned(
                          top: 15,
                          left: 15,
                          child: Image.asset(
                            'assets/icons/Water(2).png',
                            width: 23,
                            height: 23,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tank',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/icons/circle.png',
                        width: 53,
                        height: 53,
                      ),
                      Positioned(
                        top: 15,
                        left: 15,
                        child: Image.asset(
                          'assets/icons/To Do(2).png',
                          width: 23,
                          height: 23,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Behavior',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SpeciesScreen()),
                  );
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          'assets/icons/bluecircle.png',
                          width: 53,
                          height: 53,
                        ),
                        Positioned(
                          top: 12,
                          left: 11,
                          child: Image.asset(
                            'assets/icons/Koi Fish(2).png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Species',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ExerciseScreen()),
                  );
                },
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Image.asset(
                          'assets/icons/browncircle.png',
                          width: 53,
                          height: 53,
                        ),
                        Positioned(
                          top: 11,
                          left: 10,
                          child: Image.asset(
                            'assets/icons/Virus.png',
                            width: 32,
                            height: 32,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Diseases',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
