import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:adapty_flutter/adapty_flutter.dart';
import 'package:flutter/widgets.dart';

class Membership extends StatefulWidget {
  final String username;
  const Membership({super.key, required this.username});

  @override
  State<Membership> createState() => _MembershipState();
}

class _MembershipState extends State<Membership> {
  int selectedPlanIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 38, 20, 84),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
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
                  height: 20,
                ),
                const Text(
                  'Welcome widget.username!', //${}
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
                      width: 350,
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
                Padding(
                  padding: const EdgeInsets.only(
                      top: 20, bottom: 20, left: 40, right: 40),
                  child: ListView.builder(
                    shrinkWrap:
                        true, // Add this line to allow ListView in a Column
                    itemCount: 2,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPlanIndex = index;
                          });
                        },
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  width: selectedPlanIndex == index
                                      ? MediaQuery.of(context).size.width * 0.8
                                      : MediaQuery.of(context).size.width * 0.7,
                                  height: selectedPlanIndex == index
                                      ? MediaQuery.of(context).size.height *
                                          0.11
                                      : MediaQuery.of(context).size.height *
                                          0.1,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: selectedPlanIndex == index
                                        ? const Color.fromARGB(255, 76, 57, 125)
                                        : const Color.fromARGB(
                                            255, 76, 57, 125),
                                    border: Border.all(
                                      color: selectedPlanIndex == index
                                          ? Colors.white
                                          : const Color.fromARGB(
                                              255, 100, 73, 152),
                                      width: 2,
                                    ),
                                  ),
                                  child:
                                      Center(child: Text('Box ${index + 1}')),
                                ),
                                Positioned(
                                  right: 15,
                                  bottom: -20,
                                  child: Container(
                                    width: selectedPlanIndex == index
                                        ? MediaQuery.of(context).size.width *
                                            0.06
                                        : MediaQuery.of(context).size.width *
                                            0.05,
                                    height: selectedPlanIndex == index
                                        ? MediaQuery.of(context).size.height *
                                            0.06
                                        : MediaQuery.of(context).size.height *
                                            0.05,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 49, 205, 215),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            index == 0
                                                ? 'assets/diamond.png'
                                                : 'assets/crown.png',
                                          ),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.04,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
