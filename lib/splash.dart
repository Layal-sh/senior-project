import 'dart:async';

import 'package:flutter/material.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    startTimer();
    super.initState();
  }

  startTimer() {
    var duration = const Duration(seconds: 3);
    return Timer(duration, route);
  }

  route() {
    Navigator.of(context).pushReplacementNamed('/start');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/splash.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: 100, // Adjust this value as needed
            right: 40, // Adjust this value as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Sugar',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontFamily: 'fonts/Inter-Bold.ttf',
                          fontSize: 32,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: 'Sense\n',
                        style: TextStyle(
                          fontSize: 32,
                          fontFamily: 'Inter',
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "Simplify   Optimize    Thrive",
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: 'Italiana',
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
