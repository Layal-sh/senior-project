// ignore_for_file: use_build_context_synchronously, duplicate_ignore, deprecated_member_use

import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:sugar_sense/Database/db.dart';
import 'dart:math';

import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/main.dart';

class UserInfo extends StatefulWidget {
  const UserInfo({super.key});

  @override
  State<UserInfo> createState() => _UserInfoState();
}

class _UserInfoState extends State<UserInfo> {
  final controller = PageController();

  List<bool> isVisible = List.generate(2, (index) => false);
  bool add = true;

  int clicked = 0;
  final questions = [
    'What\'s Your Carbohydrates Ratio?',
    'What\'s Your Insulin Sensitivity?',
    'What\'s Your Target Glucose Level?',
    'Choose What You Would Like Your Doctor To Have Access To'
  ];
  List<GlobalKey<FormState>> formKeys = List.generate(
    3,
    (index) => GlobalKey<FormState>(),
  );
  //final carbohydratesController = TextEditingController();
  //final unitController = TextEditingController();
  final insulinController = TextEditingController();
  final glucoseController = TextEditingController();
  List<TextEditingController> carbohydratesController =
      List.generate(3, (index) => TextEditingController());
  List<TextEditingController> unitController =
      List.generate(3, (index) => TextEditingController());
  List<double> core = List.generate(3, (index) => 1.0);
  List<double> units = List.generate(3, (index) => 0.0);

  void updateControllers() {
    for (int i = 0; i < 3; i++) {
      carbohydratesController[i].text = core[i].toString();
      unitController[i].text = units[i].toString();
    }
  }

  List<Widget> forms = [];
  //int core = 0;
  //int units = 1;
  //List<Form> forms = [Form(child: MyCustomForm(0, 1))];
  List<Option> options = [
    Option(title: 'Glucose Levels'),
    Option(title: 'Insulin Intake'),
    Option(title: 'Meals'),
  ];
  bool _isLoading = false;
  var currentPage = 0;
  int unit1 = 0;
  int unit2 = 0;
  int unit3 = 0;
  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 3; i++) {
      carbohydratesController[i].addListener(() {
        double? doubleValue = double.tryParse(carbohydratesController[i].text);
        if (doubleValue != null) {
          core[i] = doubleValue;
        }
      });
      unitController[i].addListener(() {
        double? doubleValue = double.tryParse(unitController[i].text);
        if (doubleValue != null) {
          units[i] = doubleValue;
        }
      });
    }

    insulinController.addListener(() {
      int? intValue = int.tryParse(insulinController.text);
      if (intValue != null) {
        answers[currentPage] = intValue;
      }
    });
    glucoseController.addListener(() {
      int? intValue = int.tryParse(glucoseController.text);

      if (intValue != null) {
        answers[currentPage] = intValue;
      }
    });
  }

  final answers = [0.0, 0, 0, ''];
  void updatelastAnswers() {
    // Get the selected options
    List<Option> selectedOptions =
        options.where((option) => option.isSelected).toList();

    // Convert the selected options to a list of titles
    List<String> selectedTitles =
        selectedOptions.map((option) => option.title).toList();

    // Update the last item in the answers list
    answers[answers.length - 1] = selectedTitles;
  }

  void updatefirstAnswer() {
    List<double> coreUnitsValues = List.filled(3, 0.0);
    for (int i = 0; i < 3; i++) {
      coreUnitsValues[i] = units[i] / (unit1 == 0 ? core[i] / 15 : core[i]);
    }

    answers[0] = coreUnitsValues;
  }

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
                              duration: const Duration(milliseconds: 500),
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
            physics: const NeverScrollableScrollPhysics(),
            controller: controller,
            itemCount: questions.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(
                  left: 30.0,
                  right: 20.0,
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
                                            carbUnit_ = 0;
                                            saveUnits();
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
                                            carbUnit_ = 1;
                                            saveUnits();
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
                                height: 10,
                              ),
                              Form(
                                key: formKeys[0],
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: (MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  100) /
                                              2,
                                          child: TextFormField(
                                            controller:
                                                carbohydratesController[0],
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(
                                                      r'^\d+\.?\d*')), // Allow digits and decimal point
                                            ],
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              hintText: unit1 == 0
                                                  ? 'Carbs'
                                                  : "Exchange",
                                            ),
                                            onChanged: (text) {
                                              if (text.isEmpty) {
                                                core[0] = 0;
                                                answers[currentPage] = 0.0;
                                              }
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter a value';
                                              }
                                              return null;
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
                                          width: (MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  100) /
                                              2,
                                          child: TextFormField(
                                            controller: unitController[0],
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            inputFormatters: <TextInputFormatter>[
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(
                                                      r'^\d+\.?\d*')), // Allow digits and decimal point
                                            ],
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              hintText: 'Unit',
                                            ),
                                            onChanged: (text) {
                                              if (text.isEmpty) {
                                                units[0] = 1;
                                                answers[currentPage] = 0.0;
                                              }
                                            },
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter a value';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Column(
                                      children: [
                                        Visibility(
                                          visible: isVisible[0],
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                135) /
                                                            2,
                                                    child: TextFormField(
                                                      controller:
                                                          carbohydratesController[
                                                              1],
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true),
                                                      inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'^\d+\.?\d*')), // Allow digits and decimal point
                                                      ],
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        hintText: unit1 == 0
                                                            ? 'Carbs'
                                                            : "Exchange",
                                                      ),
                                                      onChanged: (text) {
                                                        if (text.isEmpty) {
                                                          core[1] = 0;
                                                          //answers[currentPage] = 0.0;
                                                        }
                                                      },
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please enter a value';
                                                        }
                                                        return null;
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
                                                      color: Color.fromARGB(
                                                          255, 0, 0, 0),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                135) /
                                                            2,
                                                    child: TextFormField(
                                                      controller:
                                                          unitController[1],
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true),
                                                      inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'^\d+\.?\d*')), // Allow digits and decimal point
                                                      ],
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        hintText: 'Unit',
                                                      ),
                                                      onChanged: (text) {
                                                        if (text.isEmpty) {
                                                          units[1] = 1;
                                                          //answers[currentPage] = 0.0;
                                                        }
                                                      },
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please enter a value';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      logger.info(
                                                          "before setState core[1] = ${core[1]} and unit[1] = ${units[1]}");
                                                      setState(() {
                                                        clicked--;
                                                        isVisible[clicked] =
                                                            false;
                                                        core[1] = core[2];
                                                        units[1] = units[2];
                                                        core[clicked + 1] = 1;
                                                        units[clicked + 1] = 0;
                                                        add = true;
                                                        carbohydratesController[
                                                                    1]
                                                                .text =
                                                            carbohydratesController[
                                                                    2]
                                                                .text;
                                                        unitController[1].text =
                                                            unitController[2]
                                                                .text;
                                                        carbohydratesController[
                                                                clicked + 1]
                                                            .text = "";
                                                        unitController[
                                                                clicked + 1]
                                                            .text = "";
                                                      });
                                                      logger.info(
                                                          "after setState core[1] = ${core[1]} and unit[1] = ${units[1]}");
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: isVisible[1],
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                135) /
                                                            2,
                                                    child: TextFormField(
                                                      controller:
                                                          carbohydratesController[
                                                              2],
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true),
                                                      inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'^\d+\.?\d*')), // Allow digits and decimal point
                                                      ],
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        hintText: unit1 == 0
                                                            ? 'Carbs'
                                                            : "Exchange",
                                                      ),
                                                      onChanged: (text) {
                                                        if (text.isEmpty) {
                                                          core[2] = 0;
                                                          //answers[currentPage] = 0.0;
                                                        }
                                                      },
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please enter a value';
                                                        }
                                                        return null;
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
                                                      color: Color.fromARGB(
                                                          255, 0, 0, 0),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width -
                                                                135) /
                                                            2,
                                                    child: TextFormField(
                                                      controller:
                                                          unitController[2],
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true),
                                                      inputFormatters: <TextInputFormatter>[
                                                        FilteringTextInputFormatter
                                                            .allow(RegExp(
                                                                r'^\d+\.?\d*')), // Allow digits and decimal point
                                                      ],
                                                      decoration:
                                                          InputDecoration(
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(20),
                                                        ),
                                                        hintText: 'Unit',
                                                      ),
                                                      onChanged: (text) {
                                                        if (text.isEmpty) {
                                                          units[2] = 1;
                                                          //answers[currentPage] = 0.0;
                                                        }
                                                      },
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Please enter a value';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(
                                                      Icons.delete,
                                                      size: 20,
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        clicked--;
                                                        core[2] = 1;
                                                        units[2] = 0;
                                                        add = true;
                                                        isVisible[1] = false;
                                                        carbohydratesController[
                                                                2]
                                                            .text = "";
                                                        unitController[2].text =
                                                            "";
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Visibility(
                                          visible: add,
                                          child: ElevatedButton.icon(
                                            onPressed: () {
                                              setState(() {
                                                if (clicked < 3) {
                                                  clicked++;
                                                  if (clicked == 1) {
                                                    isVisible[0] =
                                                        !isVisible[0];
                                                  }
                                                  if (clicked == 2) {
                                                    isVisible[1] =
                                                        !isVisible[1];
                                                  }
                                                }
                                                if (clicked == 2) {
                                                  add = false;
                                                }
                                                //isVisible = !isVisible;
                                              });
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent),
                                              shadowColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent),
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent),
                                              overlayColor:
                                                  MaterialStateProperty
                                                      .resolveWith((states) {
                                                if (states.contains(
                                                    MaterialState.pressed)) {
                                                  return const Color.fromARGB(
                                                          255, 212, 242, 245)
                                                      .withOpacity(
                                                          0.5); // Change this color to your desired color
                                                }
                                                return null; // Use the default value for other states
                                              }),
                                              surfaceTintColor:
                                                  MaterialStateProperty.all(
                                                      Colors.transparent),
                                            ),
                                            icon: const Icon(
                                              Icons.add,
                                              color: Color.fromARGB(
                                                  255, 22, 161, 170),
                                            ), // Provide your icon here
                                            label: const Text(
                                              'Add Another',
                                              style: TextStyle(
                                                color: Color.fromARGB(
                                                    255, 22, 161, 170),
                                              ),
                                            ), // Provide your text here
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
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
                                            unit3 = 0;
                                            glucoseUnit_ = 0;
                                            saveUnits();
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
                                            unit3 = 1;
                                            glucoseUnit_ = 1;
                                            saveUnits();
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
                              Form(
                                key: formKeys[1],
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 60,
                                  child: TextFormField(
                                    controller: insulinController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      hintText:
                                          'Enter your insulin sensitivity',
                                    ),
                                    onChanged: (text) {
                                      if (text.isEmpty) {
                                        answers[currentPage] = 0;
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a value';
                                      }
                                      return null;
                                    },
                                  ),
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
                                            glucoseUnit_ = 0;
                                            saveUnits();
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
                                            glucoseUnit_ = 1;
                                            saveUnits();
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
                              Form(
                                key: formKeys[2],
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width - 60,
                                  child: TextFormField(
                                    controller: glucoseController,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    inputFormatters: <TextInputFormatter>[
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      hintText:
                                          'Enter your target glucose level',
                                    ),
                                    onChanged: (text) {
                                      if (text.isEmpty) {
                                        answers[currentPage] = 0;
                                      }
                                    },
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a value';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        if (index == 3)
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
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
                                                    : const Color.fromARGB(
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
                  if (currentPage == 0) {
                    if (formKeys[currentPage].currentState!.validate()) {
                      setState(() {
                        updatefirstAnswer();
                        if ((answers[0] as List)[0] != 0.0) {
                          updatefirstAnswer();
                          currentPage = controller.page!.round() + 1;
                          if (currentPage < questions.length) {
                            controller.nextPage(
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.ease,
                            );
                          }
                        }
                      });
                    }
                  } else if (formKeys[currentPage].currentState!.validate()) {
                    setState(() {
                      if (answers[currentPage] != 0.0 ||
                          answers[currentPage] != 0) {
                        currentPage = controller.page!.round() + 1;
                        if (currentPage < questions.length) {
                          controller.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        }
                      }
                    });
                  }
                  // ignore: avoid_print
                  print(answers);
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
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  if (await isConnectedToWifi()) {
                    setState(
                      () {
                        updatelastAnswers();
                      },
                    );
                    //final response = await registerPatient();
                    //if (response.statusCode == 200) {
                    logger.info("registered patient successfully");
                    showDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return Dialog(
                          //Navigator.of(context).pop();
                          //Navigator.of(context).pushReplacementNamed('/login');
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width * 0.8,
                            height: MediaQuery.of(context).size.height * 0.6,
                            child: AlertDialog(
                              insetPadding: const EdgeInsets.only(
                                left: 10,
                                right: 10,
                                top: 20,
                                bottom: 20,
                              ),
                              backgroundColor: Colors.white,
                              content: Column(
                                children: [
                                  Image.asset(
                                      'assets/completed.png'), // Replace with your image path
                                  const SizedBox(
                                    height: 30,
                                  ),
                                  const Text(
                                    'Congratulations!',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Inter',
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  const Text(
                                    'Your account is ready to use. You will be redirected to the Home Page in a few seconds...',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      color: Color.fromARGB(255, 107, 114, 128),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  _isLoading
                                      ? const CustomLoading()
                                      : Container(),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                    // ignore: unused_local_variable
                    final response = await registerPatient();
                    AwesomeNotifications().createNotification(
                        content: NotificationContent(
                            id: 10,
                            channelKey: 'basic_channel',
                            title: 'Sign Up Successful',
                            body: 'Welcome To SugarSense.'));
                  } else {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('Please connect to the internet to sign up!'),
                      ),
                    );
                  }
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

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    for (int i = 0; i < 3; i++) {
      carbohydratesController[i].dispose();
      unitController[i].dispose();
    }
    insulinController.dispose();
    glucoseController.dispose();
    super.dispose();
  }

  Future<http.Response> registerPatient() async {
    double insulinSensitivity = (answers[1] as num).toDouble();
    double targetGlucosed = (answers[2] as num).toDouble();

    List<dynamic> carbRatios = answers[0] as List<dynamic>;
    double carbRatio1 = carbRatios[0];
    double carbRatio2 = carbRatios[1];
    double carbRatio3 = carbRatios[2];

    // if (unit1 == 0) {
    //   carbRatio1 /= 15;
    //   carbRatio2 /= 15;
    //   carbRatio3 /= 15;
    // }
    if (unit2 == 0) insulinSensitivity *= 18.018;
    if (unit3 == 0) targetGlucosed *= 18.018;

    //double carbRatio = insUnit / exchange;
    int targetGlucose = targetGlucosed.round();

    String privacy = "";
    for (var option in options) {
      if (option.isSelected) {
        privacy += "1";
      } else {
        privacy += "0";
      }
    }

    final response = await http
        .post(
          Uri.parse('http://$localhost:8000/regPatient'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, dynamic>{
            'username': username_,
            'doctorID': doctorCode_,
            'insulinSensivity': insulinSensitivity,
            'targetBloodGlucose': targetGlucose,
            'carbRatio1': carbRatio1,
            'carbRatio2': carbRatio2,
            'carbRatio3': carbRatio3,
            'privacy': privacy
          }),
        )
        .timeout(const Duration(seconds: 10));
    DBHelper dbHelper = DBHelper.instance;
    await dbHelper.syncMeals();
    logger.info("synced meals successfully");
    await dbHelper.syncMealComposition();
    logger.info("synced meal compositions successfully");
    _isLoading = false;
    Navigator.of(context).pop();
    Navigator.of(context).pushReplacementNamed('/login');
    return response;
  }
}

class Option {
  bool isSelected;
  final String title;

  Option({required this.title, this.isSelected = false});
}

class CustomLoading extends StatefulWidget {
  const CustomLoading({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CustomLoadingState createState() => _CustomLoadingState();
}

class _CustomLoadingState extends State<CustomLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 75,
      height: 75,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * pi,
            child: child,
          );
        },
        child: Stack(
          children: List.generate(8, (index) {
            return Positioned(
              left: 25,
              top: 0,
              child: Transform.rotate(
                angle: (2 * pi / 8) * index,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromARGB(255, 22, 161, 170),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
