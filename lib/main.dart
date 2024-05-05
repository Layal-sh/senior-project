// ignore_for_file: avoid_print

import 'dart:io';

//import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_sense/Database/db.dart';
//import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/application/app.dart';
import 'package:sugar_sense/login/signup/login.dart';
import 'package:sugar_sense/login/signup/signup.dart';
import 'package:sugar_sense/login/signup/splash.dart';
import 'package:sugar_sense/login/signup/startpage.dart';
import 'package:logging/logging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final logger = Logger('MyLogger');
bool isNotMobile = false;
String localhost = "";
DBHelper db = DBHelper.instance;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  logger.info('This is an info message');
  logger.info("privacy: $privacy_");

  isNotMobile = kIsWeb || (!Platform.isAndroid && !Platform.isIOS);
  localhost = !isNotMobile ? "10.0.2.2" : "localhost";
  if (isNotMobile) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await loadPreferences();
  if (pid_ != -1) {
    if (!syncedInsulin_) saveInsulinSensitivity();
    if (!syncedRatios_) saveCarbRatios();
    if (!syncedTarget_) saveTarget();
    if (!syncedPrivacy_) savePrivacy();
  }

  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: Colors.teal,
        importance: NotificationImportance.High,
        channelShowBadge: true),

    /*
    NotificationChannel(
      channelKey: 'scheduled_channel',
      channelName: 'Scheduled Notifications',
      defaultColor: Colors.teal,
      locked: true,
      importance: NotificationImportance.High,
      soundSource: 'resource://raw/res_custom_notification',
      channelDescription: 'Notification channel for Scheduled tests',
    ),
  */
  ]);
  runApp(const MyApp());
  /*BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15, // Fetch interval in minutes
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,
      ), (String taskId) async {
    // This is the fetch-event callback.
    print('[BackgroundFetch] Event received: $taskId');
    checkLatestEntryDateAndShowNotification();
    BackgroundFetch.finish(taskId);
  }).then((int status) {
    print('[BackgroundFetch] SUCCESS: $status');
  }).catchError((e) {
    print('[BackgroundFetch] ERROR: $e');
  });

  // Optionally query the current BackgroundFetch status.
  BackgroundFetch.status.then((int status) {
    print('[BackgroundFetch] STATUS: $status');
  });
*/
}

void checkLatestEntryDateAndShowNotification() async {
  // Fetch the latest entry date from the database
  DateTime latestEntryDate = await db.getLatestEntry();

  // Get the current date and time
  DateTime now = DateTime.now();

  // Define the notification times
  List<DateTime> notificationTimes = [
    DateTime(now.year, now.month, now.day, 10),
    DateTime(now.year, now.month, now.day, 17),
    DateTime(now.year, now.month, now.day, 21),
  ];

  int notificationId = 0;
  for (DateTime notificationTime in notificationTimes) {
    // If the latest entry date is not between the current time and the next notification time
    if (!(latestEntryDate.isAfter(now) &&
        latestEntryDate.isBefore(notificationTime))) {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: notificationId,
              channelKey: 'scheduled_channel',
              title: 'Daily Reminder',
              body: 'Dont Forget to take your insulin.'),
          schedule: NotificationCalendar(
              hour: notificationTime.hour,
              minute: 0,
              second: 0,
              repeats: true));
    }
    notificationId += 1;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 38, 20, 84),
      statusBarIconBrightness: Brightness.light,
    ));
    return MaterialApp(debugShowCheckedModeBanner: false, routes: {
      "/": (context) => const Splash(),
      '/start': (context) => const Start(),
      '/login': (context) => const Login(),
      '/signup': (context) => const SignUp(),
      '/app': (context) => const App(),
    });
  }
}
