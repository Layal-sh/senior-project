import 'package:flutter/material.dart';
import 'package:sugar_sense/login/signup/login.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 249, 254),
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
            bottom: 20, // Adjust this value as needed
            right: 0,
            left: 0,
            // Adjust this value as needed
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                      "Welcome to SugarSense",
                      style: TextStyle(
                        fontSize: 19,
                        fontFamily: 'Inter',
                        color: Color.fromARGB(255, 80, 80, 80),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    const Text(
                      "Your path to balanced",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Inter',
                        color: Color.fromARGB(255, 80, 80, 80),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      "blood sugar levels.",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'Inter',
                        color: Color.fromARGB(255, 80, 80, 80),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Login()),
                        );
                      },
                      child: const Text(
                        "GET STARTED",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 249, 254),
                          fontSize: 24,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
