import 'package:flutter/material.dart';
import 'package:sugar_sense/application/app.dart';
import 'package:sugar_sense/application/meals.dart';
import 'package:sugar_sense/login/signup/login.dart';
import 'package:sugar_sense/application/membership.dart';
import 'package:sugar_sense/login/signup/signup.dart';
import 'package:sugar_sense/application/splash.dart';
import 'package:sugar_sense/application/startpage.dart';

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
      '/meals': (context) => Meals(),
    });
  }
}
