import 'package:flutter/material.dart';
import 'package:sugar_sense/accCreation/userinfo.dart';

class ThankYou extends StatefulWidget {
  const ThankYou({super.key});

  @override
  State<ThankYou> createState() => _ThankYouState();
}

class _ThankYouState extends State<ThankYou> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/letsgo.png"), // replace with your image
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Thank you for',
                style: TextStyle(
                  fontFamily: 'Inder',
                  fontSize: 28,
                ),
              ),
              const Text(
                'your patience',
                style: TextStyle(
                  fontFamily: 'Inder',
                  fontSize: 28,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'We have few more questions',
                style: TextStyle(
                  fontFamily: 'Inder',
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 55,
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 40,
                ),
                child: ElevatedButton(
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
                      MaterialPageRoute(builder: (context) => const UserInfo()),
                    );
                  },
                  child: const Text(
                    'Let\'s Go',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
