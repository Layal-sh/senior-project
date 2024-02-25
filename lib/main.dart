import 'package:flutter/material.dart';
import 'package:sugar_sense/app.dart';
import 'package:sugar_sense/login.dart';
import 'package:sugar_sense/membership.dart';
import 'package:sugar_sense/signup.dart';
import 'package:sugar_sense/splash.dart';
import 'package:sugar_sense/startpage.dart';

void main() {
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
