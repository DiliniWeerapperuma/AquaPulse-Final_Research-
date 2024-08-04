import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:projectfish2/config/colors.dart';
import 'package:projectfish2/screens/tank/tank.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Reminder extends StatefulWidget {
  @override
  _ReminderState createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  String? tankId = TankIdManager().tankId;
  late DatabaseReference databaseReference;
  List<ReminderData> reminders = [];
  bool notificationsEnabled =
      true; // You can save this value using shared_preferences to persist the state

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('drawable/logo');
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones(); // Initialization
    databaseReference = FirebaseDatabase.instance
        .reference()
        .child('${tankId}')
        .child('other_data')
        .child('reminders');
    _loadReminders();
  }

  void scheduleNotification(ReminderData reminder) async {
    var scheduledNotificationDateTime = tz.TZDateTime(
      tz.local,
      reminder.date.year,
      reminder.date.month,
      reminder.date.day,
      reminder.time.hour,
      reminder.time.minute,
    );

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'reminder_id', 'reminders',
        importance: Importance.max, priority: Priority.high, showWhen: false);

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    int notificationId =
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await flutterLocalNotificationsPlugin.zonedSchedule(
        notificationId,
        reminder.title,
        'Your reminder',
        scheduledNotificationDateTime,
        platformChannelSpecifics, // Corrected variable name here
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  void _loadReminders() {
    databaseReference.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;

      if (snapshot.value is! Map) {
        return;
      }

      Map<dynamic, dynamic> rawData = snapshot.value as Map;

      Map<String, dynamic> remindersData = {};
      for (var key in rawData.keys) {
        var stringKey = key.toString();
        var value = rawData[key];

        if (value is Map) {
          // if the value is a map, convert its keys to strings as well
          var newValue = Map<String, dynamic>.from(value);
          remindersData[stringKey] = newValue;
        } else {
          remindersData[stringKey] = value;
        }
      }

      List<ReminderData> loadedReminders = [];
      for (String key in remindersData.keys) {
        loadedReminders.add(
            ReminderData.fromJson(remindersData[key] as Map<String, dynamic>));
      }

      setState(() {
        reminders = loadedReminders;
      });
    }).catchError((error) {});
  }

  void _saveReminders() {
    Map<String, Map<String, dynamic>> remindersMap = {};
    for (var i = 0; i < reminders.length; i++) {
      remindersMap['reminder_$i'] = reminders[i].toJson();
    }

    databaseReference.set(remindersMap);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Manual Reminders',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: Image.asset(
                  'assets/icons/+.png', // Replace with the path to your icon
                  width: 27, // Adjust the size as needed
                  height: 27,
                ),
                onPressed: () {
                  _showAddReminderDialog(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 20),
          Column(
            children: reminders.map((reminder) {
              return Column(
                children: [
                  buildReminderCard(reminder),
                  const SizedBox(
                      height: 10), // Add spacing after each reminder card
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildReminderCard(ReminderData reminder) {
    return GestureDetector(
      onTap: () {
        _showDeleteConfirmationDialog(context, reminder);
      },
      child: Container(
          height: 85,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.font5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Image.asset(
                          'assets/icons/clock.png',
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          reminder.time.format(context),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            color: AppColors.font6,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Image.asset(
                          'assets/icons/dot.png',
                          height: 16,
                          width: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '${reminder.date.day} ${_getMonthName(reminder.date.month)}, ${reminder.date.year}',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            color: AppColors.font6,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              SizedBox(
                width: 60, // Adjust the width as needed
                child: Image.asset(
                  'assets/icons/Timer.png',
                  fit: BoxFit.contain, // Adjust the fit property as needed
                ),
              ),
            ],
          )),
    );
  }

  String _getMonthName(int month) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, ReminderData reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  reminders
                      .remove(reminder); // Remove the reminder from the list
                });
                _saveReminders(); // Save the updated reminders
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _showAddReminderDialog(BuildContext context) {
    String newReminderTitle = ''; // Initialize with an empty title
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Any Reminder You Want'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  newReminderTitle = value;
                },
                decoration: const InputDecoration(
                  labelText: 'Reminder Name',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null && pickedDate != selectedDate) {
                    setState(() {
                      selectedDate = pickedDate;
                    });
                  }
                },
                child: const Text('Select Date'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null && pickedTime != selectedTime) {
                    setState(() {
                      selectedTime = pickedTime;
                    });
                  }
                },
                child: const Text('Select Time'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ReminderData newReminder = ReminderData(
                  title: newReminderTitle,
                  time: selectedTime,
                  date: selectedDate,
                );
                setState(() {
                  reminders.add(newReminder);
                });
                _saveReminders(); // Save the updated reminders
                scheduleNotification(newReminder); // Schedule the notification
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}

class ReminderData {
  final String title;
  final TimeOfDay time;
  final DateTime date;

  ReminderData({
    required this.title,
    required this.time,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'dateYear': date.year,
      'dateMonth': date.month,
      'dateDay': date.day,
    };
  }

  factory ReminderData.fromJson(Map<String, dynamic> json) {
    return ReminderData(
      title: json['title'],
      time: TimeOfDay(hour: json['timeHour'], minute: json['timeMinute']),
      date: DateTime(json['dateYear'], json['dateMonth'], json['dateDay']),
    );
  }
}
