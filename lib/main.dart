import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  MyApp() {
    initializeLocalNotifications();
    loadTimezoneData();
  }

  void initializeLocalNotifications() async {
    WidgetsFlutterBinding.ensureInitialized();
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
  }

  void loadTimezoneData() {
    tz.initializeTimeZones();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ReminderScreen(),
    );
  }
}

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({Key? key}) : super(key: key);

  @override
  _ReminderScreenState createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen> {
  bool isTimerRunning = false;
  int countdownSeconds = 0;
  int currentCountdown = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scheduleNotification();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder App'),
      ),
      body: Center(
        child: isTimerRunning ? buildCountdown() : buildSetReminderButton(),
      ),
    );
  }
Widget buildCountdown() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        formatDuration(Duration(seconds: currentCountdown)),
        style: const TextStyle(fontSize: 48),
      ),
      const SizedBox(height: 20),
      IconButton(
        onPressed: () => _selectTime(context),
        icon: Icon(Icons.edit),
      ),
      ElevatedButton(
        onPressed: () {
          setState(() {
            isTimerRunning = false;
            print('buildCountdown(): isTimerRunning = false');
          });
        },
        child: const Text('Return to Set Reminder'),
      ),
    ],
  );
}


Future<void> _selectTime(BuildContext context) async {
  final TimeOfDay? pickedTime = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.now(),
  );

  if (pickedTime != null) {
    final now = DateTime.now();
    final selectedDateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
    final countdownDuration = selectedDateTime.difference(now);

    setState(() {
      isTimerRunning = true;
      currentCountdown = countdownDuration.inSeconds;
      print('buildSetReminderButton(): isTimerRunning = true');
    });

    startCountdown();
  }
}

/*  Widget buildCountdown() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          formatDuration(Duration(seconds: currentCountdown)),
          style: const TextStyle(fontSize: 48),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isTimerRunning = false;
              print('buildCountdown(): isTimerRunning = false');
            });
          },
          child: const Text('Return to Set Reminder'),
        ),
      ],
    );
  }
*/
  Widget buildSetReminderButton() {
    currentCountdown = countdownSeconds;
    return ElevatedButton(
          onPressed: () {
            setState(() {
              isTimerRunning = true;
              print('buildSetReminderButton(): isTimerRunning = true');
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
    print('scheduleNotification(): startCountdown');
    const oneSecond = Duration(seconds: 1);
    Timer.periodic(oneSecond, (timer) {
      setState(() {
        print("scheduleNotification(): currentCountdown = " + currentCountdown.toString());
        currentCountdown--;
        if (currentCountdown <= 0) {
          timer.cancel();
          print('scheduleNotification(): Countdown completed');
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
