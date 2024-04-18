import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/application/app.dart';
import 'package:sugar_sense/login/signup/login.dart';
import 'package:sugar_sense/login/signup/signup.dart';
import 'package:sugar_sense/login/signup/splash.dart';
import 'package:sugar_sense/login/signup/startpage.dart';
import 'package:logging/logging.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

final logger = Logger('MyLogger');
bool isNotMobile = false;
String localhost = "";

Future<void> main() async {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  logger.info('This is an info message');

  isNotMobile = kIsWeb || (!Platform.isAndroid && !Platform.isIOS);
  localhost = !isNotMobile ? "10.0.2.2" : "localhost";
  if (isNotMobile) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  WidgetsFlutterBinding.ensureInitialized();
  await loadPreferences();
  if (!isSynced_) saveValues();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
