import 'package:flutter/material.dart';
import 'package:sugar_sense/app.dart';
import 'package:sugar_sense/login.dart';
import 'package:sugar_sense/membership.dart';
import 'package:sugar_sense/signup.dart';
import 'package:sugar_sense/splash.dart';
import 'package:sugar_sense/startpage.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final logger = Logger('MyLogger');

void main() {
  Logger.root.level =
      Level.ALL; // Set this level to control which log messages are shown
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  logger.info('This is an info message');
  sqfliteFfiInit();

  // Use sqflite_common_ffi's database factory
  databaseFactory = databaseFactoryFfi;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, routes: {
      "/": (context) => Splash(),
      '/start': (context) => Start(),
      '/login': (context) => Login(),
      '/signup': (context) => SignUp(),
      '/app': (context) => App(),
      '/membership': (context) => Membership(),
    });
  }
}
