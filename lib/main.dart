import 'package:flutter/material.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/application/app.dart';
import 'package:sugar_sense/application/meals.dart';
import 'package:sugar_sense/login/signup/login.dart';
import 'package:sugar_sense/application/membership.dart';
import 'package:sugar_sense/login/signup/signup.dart';
import 'package:sugar_sense/application/splash.dart';
import 'package:sugar_sense/application/startpage.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final logger = Logger('MyLogger');

Future<void> main() async {
  Logger.root.level =
      Level.ALL; // Set this level to control which log messages are shown
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  logger.info('This is an info message');
  sqfliteFfiInit();

  // Use sqflite_common_ffi's database factory
  databaseFactory = databaseFactoryFfi;
  WidgetsFlutterBinding.ensureInitialized();
  await loadPreferences();
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
      '/meals': (context) => Meals(),
    });
  }
}
