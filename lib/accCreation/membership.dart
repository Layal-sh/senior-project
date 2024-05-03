import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/accCreation/thanks.dart';
import 'package:sugar_sense/accCreation/underTwentyTwo.dart';
import 'package:http/http.dart' as http;
import 'package:sugar_sense/main.dart';

class Membership extends StatefulWidget {
  final String username;
  final int index;
  const Membership({super.key, required this.username, required this.index});

  @override
  State<Membership> createState() => _MembershipState();
}

int selectedPlanIndex = -1;

class _MembershipState extends State<Membership> {
  @override
  Widget build(BuildContext context) {
    logger.info("username inside of the membershit: $username_");
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 38, 20, 84),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: widget.index == 1
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () async {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pop();
                  })
              : Container(),
          title: widget.index == 1
              ? Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: min(MediaQuery.of(context).size.width,
                            MediaQuery.of(context).size.height) *
                        0.035,
                    color: Colors.white,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                  ),
                )
              : Container(),
          backgroundColor: const Color.fromARGB(255, 38, 20, 84),
          //centerTitle: true,
          iconTheme: const IconThemeData(
            color: Color.fromARGB(255, 255, 255, 255),
            size: 25.0,
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
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
                Text(
                  'Welcome $username_!', //${}
                  style: const TextStyle(
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
                    letterSpacing: 1,
                  ),
                ),
                const Text(
                  'standard plan then upgrade',
                  style: TextStyle(
                    color: Color.fromARGB(255, 156, 130, 224),
                    fontSize: 14,
                    fontFamily: 'Rubik',
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(
                  height: 10,
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
                        color: const Color.fromARGB(255, 76, 57, 125),
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
                  padding: const EdgeInsets.only(top: 20, left: 40, right: 40),
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
                                        ? MediaQuery.of(context).size.width *
                                            0.8
                                        : MediaQuery.of(context).size.width *
                                            0.7,
                                    height: selectedPlanIndex == index
                                        ? MediaQuery.of(context).size.height *
                                            0.11
                                        : MediaQuery.of(context).size.height *
                                            0.1,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15),
                                      color: selectedPlanIndex == index
                                          ? const Color.fromARGB(
                                              255, 76, 57, 125)
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
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.018,
                                          ),
                                          Row(
                                            children: [
                                              const Text(
                                                '* ',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 49, 205, 215),
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                              Text(
                                                index == 0
                                                    ? 'Standard Plan'
                                                    : 'Premium Plan',
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 156, 130, 224),
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: 'Rubik',
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            index == 0
                                                ? '\$1 / Month'
                                                : '\$80 Lifetime',
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 255, 255, 255),
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'sarabun',
                                              letterSpacing: 2,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )),
                                Positioned(
                                  right: 15,
                                  bottom: -20,
                                  child: Container(
                                    width: selectedPlanIndex == index
                                        ? MediaQuery.of(context).size.width *
                                            0.07
                                        : MediaQuery.of(context).size.width *
                                            0.06,
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
                Padding(
                  padding: const EdgeInsets.only(
                    left: 30,
                    right: 30,
                    top: 5,
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 49, 205, 215),
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      if (selectedPlanIndex == -1 && widget.index == 0) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('No plan is selected'),
                              content: const Text('Please select a plan.'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        if (widget.index == 0) {
                          selectedPlan_ = selectedPlanIndex;
                          int n = 1;
                          if (selectedPlanIndex == 1 ||
                              selectedPlanIndex == 2) {
                            final IDresponse = await http.get(Uri.parse(
                                'http://$localhost:8000/getUserId/$username_'));
                            if (IDresponse.statusCode == 200) {
                              pid_ = jsonDecode(IDresponse.body);
                            }
                            final response2 = await http.get(Uri.parse(
                                'http://$localhost:8000/updateSubscription/$pid_/$n'));
                            if (response2.statusCode == 200) {
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ThankYou(),
                                ),
                              );
                            }
                          }
                        } else {
                          if (selectedPlan_ == selectedPlanIndex) {
                            if (selectedPlanIndex == 1) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'You can no longer upgrade your membership'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'This Plan is already active'),
                                    //content: const Text('Please select a plan.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          } else {
                            selectedPlan_ = selectedPlanIndex;
                            Navigator.of(context).pop();
                          }
                        }
                      }
                    },
                    child: const Text(
                      "Get Now",
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 25,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Under 22? ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 255, 255),
                        fontSize: 12,
                        fontFamily: 'Sarabun',
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const UnderTwentyTwo()),
                        );
                      },
                      child: Stack(
                        children: [
                          const Text(
                            'Apply for a free',
                            style: TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 12,
                              fontFamily: 'Sarabun',
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 0.75,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => UnderTwentyTwo()),
                    );
                  },
                  child: Stack(
                    children: [
                      const Text(
                        'membership',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontSize: 12,
                          fontFamily: 'Sarabun',
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 0.75,
                          color: Colors.white,
                        ),
                      ),
                    ],
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
