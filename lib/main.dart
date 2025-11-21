import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/auth_wrapper.dart';
import 'services/local_notification_service.dart';
import 'services/reminder_scheduler_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Android 13+ Ask Notification Permission
  await Permission.notification.request();

  // Initialize timezones
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Manila'));

  await LocalNotificationService.initializeNotifications();

  // TEST: Schedule a notification 5 seconds after app launch
  final testTime = DateTime.now().add(const Duration(seconds: 5));
  await LocalNotificationService.scheduleNotification(
    id: 0,
    title: "Test Notification",
    body: "If you see this, notifications are working!",
    scheduledTime: testTime,
  );

  runApp(const BazarioApp());
}

class BazarioApp extends StatelessWidget {
  const BazarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bazario - The Neighbor Goods',
      theme: ThemeData(primarySwatch: Colors.green, useMaterial3: true),
      home: const AuthWrapperWithReminders(),
    );
  }
}

class AuthWrapperWithReminders extends StatefulWidget {
  const AuthWrapperWithReminders({super.key});

  @override
  State<AuthWrapperWithReminders> createState() =>
      _AuthWrapperWithRemindersState();
}

class _AuthWrapperWithRemindersState extends State<AuthWrapperWithReminders> {
  @override
  void initState() {
    super.initState();
    // Start the reminder scheduler
    ReminderSchedulerService().startReminderChecker();
  }

  @override
  void dispose() {
    ReminderSchedulerService().stopReminderChecker();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const AuthWrapper();
  }
}
