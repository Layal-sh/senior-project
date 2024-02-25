import 'package:flutter/material.dart';

class Membership extends StatefulWidget {
  const Membership({super.key});

  @override
  State<Membership> createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  int? selectedPlanIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 38, 20, 84),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 70,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 93, // Width of the outer circle
                    height: 93, // Height of the outer circle
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          Color.fromARGB(0, 33, 149, 243),
                          Color.fromARGB(0, 33, 149, 243),
                          Color.fromARGB(255, 255, 255, 255)
                        ], // Specify your gradient colors here
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color.fromARGB(255, 76, 57, 125),
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.asset(
                          'assets/badge.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                'CHOOSE YOUR PLAN',
                style: TextStyle(
                  color: Color.fromARGB(255, 255, 249, 254),
                  fontSize: 23,
                  fontFamily: 'Ruda',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              const Text(
                'Welcome ' 'Mariam' '!',
                style: TextStyle(
                  color: Color.fromARGB(255, 49, 205, 215),
                  fontSize: 21,
                  fontFamily: 'Ruda',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Text(
                'You can always start with a',
                style: TextStyle(
                  color: Color.fromARGB(255, 156, 130, 224),
                  fontSize: 14,
                  fontFamily: 'Rubik',
                  letterSpacing: 1.25,
                ),
              ),
              const Text(
                'standard plan then upgrade',
                style: TextStyle(
                  color: Color.fromARGB(255, 156, 130, 224),
                  fontSize: 14,
                  fontFamily: 'Rubik',
                  letterSpacing: 1.25,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 300,
                    child: Divider(
                      color: Color.fromARGB(255, 76, 57, 125),
                      thickness: 2,
                    ),
                  ),
                  Container(
                    width: 100,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color.fromARGB(255, 76, 57, 125),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  const Text(
                    'PLANS',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontSize: 17,
                      fontFamily: 'Ruda',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
