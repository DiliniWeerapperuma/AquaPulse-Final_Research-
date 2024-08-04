import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:projectfish2/screens/tank/tank.dart';

class MedicineRecomendation extends StatefulWidget {
  @override
  _MedicineRecomendationState createState() => _MedicineRecomendationState();
}

class _MedicineRecomendationState extends State<MedicineRecomendation> {
  late DatabaseReference _predictionsReference;
  Map<String, double> predictionPercentages = {};

  String? tankId =
      TankIdManager().tankId; // Assuming this gets the correct tank ID

  Map<String, List<String>> medicineSuggestions = {
    'Fin Rot': [
      'Broad-Spectrum Antibiotic for Bacterial Infections',
      'Water Treatment to Enhance Fin Regrowth',
      'Anti-Fungal Medication for Secondary Infections',
      'Vitamin Boosters to Strengthen Immune System',
      'Specialized Fin Rot Treatment Solution'
    ],
    'Red Spot': [
      'Anti-Parasitic Treatment for External Infections',
      'Advanced Bacterial Control Formula',
      'Stress Coat Medication to Heal Skin Wounds',
      'Nutritional Supplements for Immune Support',
      'High-Quality Water Conditioner for Disease Prevention'
    ],
    'White Spot (Ich)': [
      'Rapid-Action Ich Treatment Formula',
      'Aquarium Salt to Disrupt Parasite Lifecycle',
      'Temperature Adjustment Therapy for Ich',
      'Medicated Fish Food to Treat Internally',
      'Preventive Ich Guard for Aquariums'
    ],
  };

  List<String> getMedicineSuggestions(String disease) {
    return medicineSuggestions[disease] ?? [];
  }

  void refreshRecommendations() {
    setState(() {
      medicineSuggestions.forEach((key, value) {
        value.shuffle(); // Shuffle the list of medicines
      });
    });
  }

  @override
  void initState() {
    super.initState();
    // Update the reference to the path of the predictions
    _predictionsReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}/Funtion 4/predictions');
    _predictionsReference.onValue.listen((event) {
      var data = event.snapshot.value;

      if (data is Map) {
        // Expecting a map with disease names and their prediction percentages
        setState(() {
          predictionPercentages = data.map(
              (key, value) => MapEntry(key, double.tryParse(value) ?? 0.0));
        });
      } else {
        print("Unexpected data format for predictions: $data");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> cards = [];
    predictionPercentages.forEach((disease, percentage) {
      if (percentage > 50.0) {
        cards.addAll(buildMedicineCards(getMedicineSuggestions(disease)));
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Medicine Recommendations',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: refreshRecommendations,
                  ),
                ],
              ),
              SizedBox(height: 4), // Spacing between title and subtitle
              Text(
                'Appropriate treatments for identified diseases',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  color: Colors.grey[600], // Subtitle color
                ),
              ),
            ],
          ),
        ),
        ...cards,
      ],
    );
  }

  List<Widget> buildMedicineCards(List<String> medicines) {
    return medicines
        .map((medicine) => Card(
              elevation: 4, // Elevation for a subtle shadow
              margin: const EdgeInsets.symmetric(
                  vertical: 4.0, horizontal: 8.0), // Margin around the card
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15), // Rounded corners for the card
              ),
              child: ListTile(
                title: Text(
                  medicine, // Medicine name
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ))
        .toList();
  }
}
