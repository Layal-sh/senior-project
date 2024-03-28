import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final controller = PageController();
  final questions = [
    'What\'s Your Carbohydrates Ratio?',
    'What\'s Your Insulin Sensitivity?',
    'What\'s Your Target Glucose Level?',
    'Choose What You Would Like Your Doctor To Have Access To'
  ];
  int core = 0;
  int units = 1;
  final answers = [0.0, 0.0, 0.0, ''];

  var currentPage = 0;
  int unit1 = 0;
  int unit2 = 0;
  int unit3 = 0;
  List<Option> options = [
    Option(title: 'Glucose Levels'),
    Option(title: 'Insulin Intake'),
    Option(title: 'Meals'),
  ];
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 38, 20, 84), // top bar color
      statusBarIconBrightness: Brightness.light, // top bar icons
    ));
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 249, 254),
      body: Column(
        children: [
          const SizedBox(
            height: 50,
          ),
          if (currentPage !=
              0) // If it's not the first question, add a back button
            Padding(
              padding: const EdgeInsets.only(left: 20.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const IconTheme(
                      data: IconThemeData(
                        opacity: 1, // Adjust as needed, 1 is fully opaque
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        size: 34.0,
                      ),
                    ),
                    onPressed: () {
                      setState(
                        () {
                          if (currentPage > 0) {
                            currentPage--;
                            controller.previousPage(
                              duration: Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          if (currentPage == 0) // If it's the first question, add a SizedBox
            const SizedBox(
              height:
                  48.0, // Adjust as needed to match the height of the IconButton
            ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 30.0), // Adjust as needed
            child: ClipRRect(
              borderRadius: const BorderRadius.all(
                  Radius.circular(10.0)), // Adjust as needed
              child: LinearProgressIndicator(
                color: const Color.fromARGB(255, 22, 161, 170),
                value: (currentPage + 1) / questions.length,
                minHeight: 12.0, // Adjust as needed
              ),
            ),
          ),
          Expanded(
              child: PageView.builder(
            controller: controller,
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: 30.0,
                  right: 30.0,
                  top: 45,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 40,
                      ),
                      child: Text(
                        questions[index],
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Inter',
                          height: 1.1,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        if (index ==
                            0) // If it's the first question, add an additional TextField
                          Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.3,
                                  right: 5,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            unit1 = 0;
                                          });
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.055,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                            color: unit1 == 0
                                                ? const Color.fromARGB(
                                                    255, 22, 161, 170)
                                                : const Color.fromARGB(
                                                    255, 217, 217, 217),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  0, 101, 73, 152),
                                              width: 0,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Carbs/Unit',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            unit1 = 1;
                                          });
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.055,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                            color: unit1 == 1
                                                ? const Color.fromARGB(
                                                    255, 22, 161, 170)
                                                : const Color.fromARGB(
                                                    255, 217, 217, 217),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  0, 101, 73, 152),
                                              width: 0,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'Exchange/Unit',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              Row(
                                children: [
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width -
                                            100) /
                                        2,
                                    child: TextField(
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: false),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        hintText:
                                            unit1 == 0 ? 'Carbs' : "Exchange",
                                      ),
                                      onSubmitted: (value) {
                                        setState(() {
                                          core = value
                                              as int; // You need to create a secondAnswers list
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  const Text(
                                    "/",
                                    style: TextStyle(
                                      fontSize: 36,
                                      //fontWeight: FontWeight.w300,
                                      fontFamily: 'Inter',
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  SizedBox(
                                    width: (MediaQuery.of(context).size.width -
                                            100) /
                                        2,
                                    child: TextField(
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                              decimal: false),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        hintText: 'Unit',
                                      ),
                                      onSubmitted: (value) {
                                        setState(() {
                                          units = value as int;
                                          answers[index] = core / units;
                                          currentPage =
                                              controller.page!.round() + 1;
                                          if (currentPage < questions.length) {
                                            controller.nextPage(
                                              duration:
                                                  Duration(milliseconds: 500),
                                              curve: Curves.ease,
                                            );
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        if (index == 1)
                          Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.3,
                                  right: 5,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            unit2 = 0;
                                          });
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.055,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                            color: unit2 == 0
                                                ? const Color.fromARGB(
                                                    255, 22, 161, 170)
                                                : const Color.fromARGB(
                                                    255, 217, 217, 217),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  0, 101, 73, 152),
                                              width: 0,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'mmol/L',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            unit2 = 1;
                                          });
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.055,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                            color: unit2 == 1
                                                ? const Color.fromARGB(
                                                    255, 22, 161, 170)
                                                : const Color.fromARGB(
                                                    255, 217, 217, 217),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  0, 101, 73, 152),
                                              width: 0,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'mg/dL',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 60,
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    hintText: 'Enter your insulin sensitivity',
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      answers[index] = value;
                                      currentPage =
                                          controller.page!.round() + 1;
                                      if (currentPage < questions.length) {
                                        controller.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        if (index == 2)
                          Column(
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width * 0.3,
                                  right: 5,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            unit3 = 0;
                                          });
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.055,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              bottomLeft: Radius.circular(10),
                                            ),
                                            color: unit3 == 0
                                                ? const Color.fromARGB(
                                                    255, 22, 161, 170)
                                                : const Color.fromARGB(
                                                    255, 217, 217, 217),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  0, 101, 73, 152),
                                              width: 0,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'mmol/L',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            unit3 = 1;
                                          });
                                        },
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.055,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              bottomRight: Radius.circular(10),
                                            ),
                                            color: unit3 == 1
                                                ? const Color.fromARGB(
                                                    255, 22, 161, 170)
                                                : const Color.fromARGB(
                                                    255, 217, 217, 217),
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  0, 101, 73, 152),
                                              width: 0,
                                            ),
                                          ),
                                          child: const Center(
                                            child: Text(
                                              'mg/dL',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                fontWeight: FontWeight.w900,
                                                fontFamily: 'Rubik',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width - 60,
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    hintText: 'Enter your target glucose level',
                                  ),
                                  onSubmitted: (value) {
                                    setState(() {
                                      answers[index] = value;
                                      currentPage =
                                          controller.page!.round() + 1;
                                      if (currentPage < questions.length) {
                                        controller.nextPage(
                                          duration: Duration(milliseconds: 500),
                                          curve: Curves.ease,
                                        );
                                      }
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        if (index == 3)
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    ListTile(
                                      title: Text(
                                        options[index].title,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: 'Inter',
                                          color:
                                              Color.fromARGB(255, 84, 84, 84),
                                        ),
                                      ),
                                      trailing: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            options[index].isSelected =
                                                !options[index].isSelected;
                                          });
                                        },
                                        child: Container(
                                          width: 20, // Adjust as needed
                                          height: 20, // Adjust as needed
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color.fromARGB(
                                                  255,
                                                  22,
                                                  161,
                                                  170), // Change this to your desired border color
                                              width:
                                                  2, // Change this to your desired border width
                                            ),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(
                                                1.5), // Adjust as needed
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: options[index].isSelected
                                                    ? const Color.fromARGB(
                                                        255, 22, 161, 170)
                                                    : Color.fromARGB(
                                                        0, 255, 255, 255),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          )),
        ],
      ),
      bottomNavigationBar: currentPage < questions.length - 1
          ? Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 50,
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
                  setState(() {
                    currentPage++;
                    if (currentPage < questions.length) {
                      controller.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  });
                },
                child: const Text(
                  "Next",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 249, 254),
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 50,
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
                  setState(() {});
                },
                child: const Text(
                  "Finish",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 249, 254),
                    fontSize: 22,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
    );
  }
}

class Option {
  bool isSelected;
  final String title;

  Option({required this.title, this.isSelected = false});
}
