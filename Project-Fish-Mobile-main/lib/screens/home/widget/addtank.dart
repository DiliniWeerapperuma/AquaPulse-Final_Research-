import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projectfish2/config/colors.dart';
import 'package:projectfish2/provider/sign_in_provider.dart';
import 'package:projectfish2/screens/tank/tank.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class AddTank extends StatefulWidget {
  @override
  _AddTankState createState() => _AddTankState();
}

class _AddTankState extends State<AddTank> {
  // Reference to the current user
  final user = FirebaseAuth.instance.currentUser;
  // List of tanks
  List<TankData> tanks = [];
  // Instance of the SignInProvider
  final signInProvider = SignInProvider();
  // Reference to the FirebaseDatabase
  final FirebaseDatabase _database = FirebaseDatabase.instance;
  // Reference to the root of the database
  final DatabaseReference _dbRef = FirebaseDatabase.instance.reference();
  // Map to store temporary levels
  Map<String, String> tempLevels = {};
  // Map to store oxygen levels
  Map<String, String> oxyLevels = {};
  // Map to store predicted class H
  Map<String, String> predictedClassH = {};
  // Global tank ID
  String globalTankId = '';
  // Timer to fetch data
  Timer? _dataFetchTimer;
  // Future to fetch tank data
  Future<List<TankData>>? _tankDataFuture;
  // StreamSubscription to listen to database changes
  StreamSubscription<DatabaseEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    // Get the fish detection reference
    DatabaseReference fishDetectionRef =
        _database.reference().child('1698404487/fish_detection');

    // Listen for changes to the fish detection reference
    fishDetectionRef.onValue.listen((DatabaseEvent event) {
      // Get the data from the snapshot
      final data = event.snapshot.value as Map<dynamic, dynamic> ?? {};
      // Update the species count
      updateSpeciesCount(data);
    });

    // Fetch the tank data once
    _tankDataFuture = fetchTankDataOnce().then((tanksData) {
      // Set the tanks data
      tanks = tanksData;
      // Iterate through the tanks and fetch the oxygen, oxygen levels and water quality for each tank
      for (var tank in tanks) {
        fetchOxygenLevelForTank(tank.tankid);
        fetchTempLevelsForTank(tank.tankid);
        fetchWaterQualityTank(tank.tankid);
      }
      // Return the tanks data
      return tanksData;
    });
    // Fetch the tank data once
    _tankDataFuture = fetchTankDataOnce();
    // Create a timer to fetch the tank data every 5 seconds
    _dataFetchTimer =
        Timer.periodic(Duration(seconds: 05), (Timer t) => fetchTankData());
  }

  @override
  void dispose() {
    // Cancel the subscription
    _subscription?.cancel();
    // Dispose the super class
    super.dispose();
  }

  Future<void> refreshSpeciesCount() async {
    // Get the data from the Realtime Database
    DatabaseReference fishDetectionRef =
        _database.reference().child('1698404487/fish_detection');
    DatabaseEvent event = await fishDetectionRef.once();
    DataSnapshot snapshot = event.snapshot;

    // Check if the data is not null
    if (snapshot.value != null) {
      // Get the data from the snapshot
      final data = snapshot.value as Map<dynamic, dynamic>;
      // Update the species count
      updateSpeciesCount(data);
    }
  }

  void updateSpeciesCount(Map<dynamic, dynamic> data) {
    // Initialize the total count
    int totalCount = 0;
    // Iterate through the data
    data.forEach((key, value) {
      // Convert the value to an integer
      int count = int.tryParse(value.toString()) ?? 0;
      // Add the count to the total count
      totalCount += count;
    });

    // Update the species count in the Realtime Database
    DatabaseReference speciesCountRef = _database
        .reference()
        .child('1698404487/Funtion_1 Task 02/input/Species Count');
    speciesCountRef.set(totalCount);
  }

  Future<List<TankData>> fetchTankDataOnce() async {
    // Get the data from the Realtime Database
    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("tankids")
        .get();

    // Create a list to store the tank data
    List<TankData> tanksList = [];
    // Iterate through the data
    for (var doc in snapshot.docs) {
      // Get the tank id
      String tankId = doc.id;
      // Get the tank size from the Realtime Database
      DatabaseReference tankSizeRef = _database
          .reference()
          .child(tankId)
          .child('Funtion_1 Task 02/input/Tank Size');

      // Correctly retrieving the value from Realtime Database
      DataSnapshot tankSizeSnapshot = (await tankSizeRef.once()).snapshot;
      String tankSize = tankSizeSnapshot.value?.toString() ?? "Unknown";

      // Add the tank data to the list
      tanksList.add(TankData(
        title: doc['tank_name'],
        tankid: tankId,
        tanktype: doc['tank_type'],
        tanksize: tankSize,
      ));
    }

    // Return the list of tank data
    return tanksList;
  }

  void fetchTankData() {
    // Fetch data for each tank
    for (var tank in tanks) {
      fetchOxygenLevelForTank(tank.tankid);
      fetchTempLevelsForTank(tank.tankid);
      fetchWaterQualityTank(tank.tankid);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Return a FutureBuilder to display a loading indicator while the data is being fetched
    return FutureBuilder<List<TankData>>(
      future: _tankDataFuture,
      builder: (context, snapshot) {
        // If the connection state is waiting, show a loading indicator
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        // If there is an error, display it
        if (snapshot.hasError) {
          // If there is an error, display it
          return Text('Error: ${snapshot.error}');
        }

        // Update the tank data list if data is found
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          tanks = snapshot.data!;
        }

        // Return the widget tree
        return Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display the add tank button regardless of whether tanks are found
              buildAddTankButton(),

              // If there is data, show the tank list, else show 'No tanks found'
              if (snapshot.hasData && snapshot.data!.isNotEmpty)
                ...buildTankList(snapshot.data!),
              if (snapshot.data == null || snapshot.data!.isEmpty)
                const Text('No tanks found.'),
            ],
          ),
        );
      },
    );
  }

  List<Widget> buildTankList(List<TankData> tankDataList) {
    // Return a list of widgets to display the tank list
    return [
      const SizedBox(height: 20),
      const Text(
        'Tanks Overview',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      // Create a column to display the tank list
      Column(
        children: tankDataList.map((tank) {
          // Return a card for each tank in the list
          return Column(
            children: [
              buildTankCard(tank),
              const SizedBox(height: 15),
            ],
          );
        }).toList(),
      ),
      const SizedBox(height: 10),
    ];
  }

  Widget buildAddTankButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Add Your Tanks Here',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        IconButton(
          icon: Image.asset(
            'assets/icons/+.png',
            width: 27,
            height: 27,
          ),
          onPressed: () {
            _showAddTankDialog(context);
          },
        ),
      ],
    );
  }

  Widget buildTankCard(TankData tank) {
    return GestureDetector(
      onTap: () {
        // _showDeleteConfirmationDialog(context, tank);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TankScreen(
                tankId: tank.tankid,
                tanktitle: tank.title,
                tanktype: tank.tanktype,
                tanksize: tank.tanksize), // Pass the tankId
          ),
        );
      },
      onLongPress: () {
        // Show the delete confirmation dialog when long-pressed
        _showDeleteConfirmationDialog(context, tank);
      },
      child: Container(
        height: 85,
        width: 390,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Color.fromARGB(255, 216, 214, 233),
              Color.fromARGB(255, 199, 232, 233),
            ],
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          children: [
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 8),
                  Text(
                    tank.title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.font5,
                    ),
                  ),
                  // const SizedBox(height: 3),
                  Text(
                    '${predictedClassH[tank.tankid] ?? "N/A"}',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/Scuba Tank.png',
                        height: 20,
                        width: 20,
                        color: AppColors.font5,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${tempLevels[tank.tankid] ?? "N/A"}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.font5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Oxygen Level',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: AppColors.font5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/icons/Temperature High.png',
                        height: 20,
                        width: 20,
                        color: AppColors.font5,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${oxyLevels[tank.tankid] ?? "N/A"}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.font5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Temperature',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: AppColors.font5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 60,
              width: 80,
              child: Stack(
                children: [
                  Container(
                    height: 70,
                    width: 70,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/icons/tank.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get the latest oxygen level for the tank
  void fetchOxygenLevelForTank(String tankId) {
    // Get the dissolved oxygen reference
    DatabaseReference tankOxygenRef = _database
        .reference()
        .child('$tankId/environmental_conditions/Dissolved oxygen');

    // Listen for changes to the oxygen level
    tankOxygenRef.onValue.listen((DatabaseEvent event) {
      // Get the latest oxygen level
      tankOxygenRef.onValue.listen((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          // Parse the value to a double
          double value = double.tryParse(snapshot.value.toString()) ?? 0;
          // Convert the value to a percentage
          String percentage = '${(value / 10.0 * 100).round()}%';
          // Update the state with the new percentage
          setState(() {
            tempLevels[tankId] = percentage;
          });
        }
      });
    });
  }

  // Fetch the latest oxygen levels for the tank
  void fetchTempLevelsForTank(String tankId) {
    // Get the reference to the oxygen level
    DatabaseReference tankOxyRef = _database
        .reference()
        .child('$tankId/environmental_conditions/temperature');

    // Listen for changes to the oxygen level
    tankOxyRef.onValue.listen((DatabaseEvent event) {
      // Get the latest oxygen level
      // Get the latest oxygen level
      tankOxyRef.onValue.listen((DatabaseEvent event) {
        DataSnapshot snapshot = event.snapshot;
        if (snapshot.value != null) {
          // Convert the value to double
          double value = double.tryParse(snapshot.value.toString()) ?? 0;
          // Calculate the percentage
          String percentage = '${(value / 40.0 * 100).round()}%';
          // Update the state
          setState(() {
            oxyLevels[tankId] = percentage;
          });
        }
      });
    });
  }

  void fetchWaterQualityTank(String tankId) {
    // Get the latest oxygen level
    DatabaseReference tankWaterRef = _database
        .reference()
        .child('$tankId/Funtion_1 Task 01/Predicted Class');

    tankWaterRef.onValue.listen((DatabaseEvent event) {
      // Get the latest oxygen level
      DataSnapshot snapshot = event.snapshot;
      if (snapshot.value != null) {
        String predictedClass = snapshot.value.toString(); // Handle as a string
        // Do something with the predictedClass
        setState(() {
          // Assuming oxyLevels is a Map<String, String>
          predictedClassH[tankId] = predictedClass;
        });
      }
    });
  }

  void checkTankIdsInDatabase() {
    // Get the reference to the tanks collection
    final DatabaseReference tankIdsRef = _database.reference();

    // Get the latest tank IDs
    tankIdsRef.once().then((event) {
      if (event.snapshot.value == null) {
        // No tanks in database
      } else {
        // Get the latest tank IDs
        Map<dynamic, dynamic>? tankIdsMap =
            event.snapshot.value as Map<dynamic, dynamic>?;
        if (tankIdsMap != null) {
          List<String> databaseTankIds =
              tankIdsMap.keys.cast<String>().toList();

          // Check if any of the tank IDs match the current tanks
          for (String tankId in databaseTankIds) {
            if (tanks.any((tank) => tank.tankid == tankId)) {
              // Tank ID matches, fetch and update oxygen level
              fetchOxygenLevelForTank(tankId);
              fetchTempLevelsForTank(tankId);
              fetchWaterQualityTank(tankId);
            }
          }
        } else {}
      }
    }).catchError((error) {});
  }

// This method shows a confirmation dialog to the user when they want to delete a tank
  void _showDeleteConfirmationDialog(
      BuildContext context, TankData tank) async {
    // Show the dialog with a context and builder
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        // Create an AlertDialog with a title and content
        return AlertDialog(
          title: const Text('Delete Tank'),
          content: const Text('Are you sure you want to delete this tank?'),
          actions: [
            // Create a TextButton for the cancel option
            TextButton(
              onPressed: () {
                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            // Create a TextButton for the delete option
            TextButton(
              onPressed: () {
                // Remove the tank from the list
                setState(() {
                  tanks.remove(tank);
                });

                // Remove the tank from Firestore
                removeTankFromFirestore(tank.tankid);

                // Close the dialog
                Navigator.of(context).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void removeTankFromFirestore(String tankId) {
    // Get the user's uid from the Firebase user
    FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        // Get the tank's id from the Firebase document
        .collection("tankids")
        .doc(tankId)
        // Delete the document from the Firebase collection
        .delete()
        .then((_) {})
        // Catch any errors that occur
        .catchError((error) {});
  }

  void _showAddTankDialog(BuildContext context) async {
    GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    String newTankTitle = '';
    String newTankId = '';
    String newTankType = '';
    String newTankAge = '';
    String newTankSize = 'Small';
    String newUneatenFood = 'Average Amount';
    int feedingFrequency = 1;
    bool isSliderInteractive = true;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Tank'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'Please use Tank Id as your IOT device connected database referance id.\n\nDefault: \n1698404487\n3398404487\n9998404487'),
                  TextFormField(
                    onChanged: (value) => newTankTitle = value,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a tank name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(labelText: 'Tank Name'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      newTankId = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter Tank Id',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: (value) {
                      newTankType = value;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Enter Tank Type',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Select Tank Size'),
                  ),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return DropdownButtonFormField<String>(
                        value: newTankSize,
                        onChanged: (String? newValue) {
                          setState(() => newTankSize = newValue!);
                        },
                        items: <String>['Small', 'Medium', 'Large']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a size';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text('Select Uneaten Food Amount'),
                  ),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return DropdownButtonFormField<String>(
                        value: newUneatenFood,
                        onChanged: (String? newValue) {
                          setState(() => newUneatenFood = newValue!);
                        },
                        items: <String>['No', 'Average Amount', 'Small Amount']
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select a size';
                          }
                          return null;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              Icons
                                  .schedule, // Icon changed to reflect feeding frequency
                              color: Colors.blue, // Replace with your color
                            ),
                            title: Text(
                                'Feeding Frequency: ${feedingFrequency.toString()}'),
                          ),
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor:
                                  Colors.blue, // Replace with your color
                              inactiveTrackColor: Colors.blue
                                  .withOpacity(0.5), // Replace with your color
                            ),
                            child: Slider(
                              value: feedingFrequency.toDouble(),
                              min: 1,
                              max: 5,
                              divisions: 4,
                              label: feedingFrequency.toString(),
                              activeColor:
                                  Colors.blue, // Replace with your color
                              onChanged: isSliderInteractive
                                  ? (double value) {
                                      setState(() {
                                        feedingFrequency = value.toInt();
                                      });
                                    }
                                  : null,
                              onChangeStart: (double value) {
                                setState(() {
                                  isSliderInteractive = false;
                                });
                              },
                              onChangeEnd: (double value) {
                                setState(() {
                                  isSliderInteractive = true;
                                });
                              },
                            ),
                          )
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Ensure this method is async
                if (_formKey.currentState!.validate()) {
                  TankData newTank = TankData(
                    title: newTankTitle,
                    tankid: newTankId,
                    tanktype: newTankType,
                    tanksize: newTankAge,
                  );

                  DatabaseReference tankRef = _database
                      .reference()
                      .child(newTankId)
                      .child('Funtion_1 Task 02/input');
                  tankRef.set({
                    'Tank Size': newTankSize,
                    'Feeding Frequency':
                        feedingFrequency, // Use feedingFrequency directly
                    'Uneaten Food': newUneatenFood,
                    // Other fields if necessary
                  });

                  globalTankId = newTankId;

                  signInProvider.addNewTank(
                      newTankTitle, newTankId, newTankType, newTankAge);

                  // Fetch and set oxygen level
                  fetchOxygenLevelForTank(newTankId);
                  fetchTempLevelsForTank(newTankId);
                  fetchWaterQualityTank(newTankId);

                  // Update the list of tanks and rebuild the widget
                  setState(() {
                    tanks.add(newTank);
                  });
                  await refreshSpeciesCount();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class TankData {
  // The title of the tank
  final String title;
  // The id of the tank
  final String tankid;
  // The type of the tank
  final String tanktype;
  // The size of the tank
  final String tanksize;

  TankData({
    required this.title,
    required this.tankid,
    required this.tanktype,
    required this.tanksize,
  });

  // Convert the object to a json object
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'tankid': tankid,
      'tanktype': tanktype,
      'tanksize': tanksize,
    };
  }

  // Create a new TankData object from a json object
  factory TankData.fromJson(Map<String, dynamic> json) {
    return TankData(
      title: json['title'],
      tankid: json['tankid'],
      tanktype: json['tanktype'],
      tanksize: json['tanksize'],
    );
  }
}
