import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';

void main() async {
  // Initialize the local notifications plugin
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterLocalNotificationsPlugin().initialize(
    // Add the required initialization settings here
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    ),
  );

  // Load the timezone data
  tz.initializeTimeZones();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool isTimerRunning = false;
  int countdownSeconds = 5;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduleNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Reminder App'),
        ),
        body: Center(
          child: isTimerRunning ? buildCountdown() : buildSetReminderButton(),
        ),
      ),
    );
  }

  Widget buildCountdown() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formatDuration(Duration(seconds: countdownSeconds)),
          style: const TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isTimerRunning = false;
            });
          },
          child: const Text('Return to Set Reminder'),
        ),
      ],
    );
  }

  Widget buildSetReminderButton() {
    countdownSeconds = 5;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isTimerRunning = true;
          print('isTimerRunning = true');
        });
        startCountdown();
      },
      child: const Text('Set Reminder'),
    );
  }

  Future<void> scheduleNotification() async {
    // ...
  }

  void startCountdown() {
    print('startCountdown');
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (timer) {
      setState(() {
        print("countdownSeconds = " + countdownSeconds.toString());
        countdownSeconds--;
        if (countdownSeconds <= 0) {
          timer.cancel();
          print('Countdown completed');
        }
      });
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}
