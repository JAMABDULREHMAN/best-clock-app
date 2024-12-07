import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clock App with Alarm',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const ClockScreen(),
    );
  }
}

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  _ClockScreenState createState() => _ClockScreenState();
}

class _ClockScreenState extends State<ClockScreen> {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  TimeOfDay _alarmTime = const TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _updateTime();
  }

  // Initialize notifications
  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  // Update current time every second
  void _updateTime() {
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        // Redraw the clocks
      });
      _updateTime();
    });
  }

  // Show notification
  Future<void> _showNotification(String message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      0,
      'Alarm',
      message,
      platformDetails,
    );
  }

  // Set alarm using time picker
  Future<void> _setAlarm() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _alarmTime,
    );

    if (pickedTime != null && pickedTime != _alarmTime) {
      setState(() {
        _alarmTime = pickedTime;
      });
      _scheduleAlarm(pickedTime);
    }
  }

  // Schedule alarm notification
  Future<void> _scheduleAlarm(TimeOfDay time) async {
    final DateTime now = DateTime.now();
    final DateTime alarmTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    if (alarmTime.isBefore(now)) {
      // If the selected time is in the past, schedule it for the next day
      alarmTime.add(const Duration(days: 1));
    }

    final duration = alarmTime.difference(now);
    await Future.delayed(duration);

    _showNotification('Time to wake up!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analog and Digital Clock with Alarm')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Analog Clock
            Container(
              height: 300,
              width: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 5),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ClockPainter(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Digital Clock
            Text(
              DateFormat('HH:mm:ss').format(DateTime.now()), // Digital format
              style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Alarm time display
            Text(
              'Alarm set for: ${_alarmTime.format(context)}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),

            // Set Alarm Button
            ElevatedButton(
              onPressed: _setAlarm,
              child: const Text('Set Alarm'),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for the analog clock
class ClockPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;

    final Paint hourHandPaint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 6;

    final Paint minuteHandPaint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    final Paint secondHandPaint = Paint()
      ..color = Colors.red
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2;

    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);
    final DateTime now = DateTime.now();

    // Draw the clock face
    canvas.drawCircle(center, radius, paint);

    // Draw the hour hand
    double hour = now.hour % 12;
    double hourAngle = (hour + now.minute / 60) * 30; // 30 degrees per hour
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(hourAngle * (3.141592653589793 / 180)); // Convert to radians
    canvas.drawLine(
        const Offset(0, 0), Offset(0, -radius * 0.5), hourHandPaint);
    canvas.restore();

    // Draw the minute hand
    double minuteAngle =
        (now.minute + now.second / 60) * 6; // 6 degrees per minute
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(minuteAngle * (3.141592653589793 / 180));
    canvas.drawLine(
        const Offset(0, 0), Offset(0, -radius * 0.7), minuteHandPaint);
    canvas.restore();

    // Draw the second hand
    double secondAngle = now.second * 6; // 6 degrees per second
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(secondAngle * (3.141592653589793 / 180));
    canvas.drawLine(
        const Offset(0, 0), Offset(0, -radius * 0.8), secondHandPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
