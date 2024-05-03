// ignore_for_file: unused_local_variable, library_private_types_in_public_api, use_build_context_synchronously, file_names

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:sugar_sense/AI/ai_functions.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/application/meals/meals.dart';
import 'package:sugar_sense/main.dart';

class AddInput extends StatefulWidget {
  final Function changeTab;
  const AddInput({super.key, required this.changeTab});

  @override
  _AddInputState createState() => _AddInputState();
}

Timer? _timer;

class _AddInputState extends State<AddInput> {
  //const Settings({Key? key}) : super(key: key);
  void refresh() {
    setState(() {});
  }

  // ignore: non_constant_identifier_names
  final TextEditingController _GlucoseController = TextEditingController();
  String? carbRatioSelected = carbRatio_.toString();
  ValueNotifier<double> glucoseLevelNotifier = ValueNotifier<double>(0.0);
  ValueNotifier<double> carbsTotalNotifier = ValueNotifier<double>(0.0);
  ValueNotifier<int> bolusCalculation = ValueNotifier<int>(0);
  double glucoseLevel = 0.0;
  List<Map> meals = [];
  String date = "";
  int bolusCalculationResult = 0;
  double totalCarbs = 0;
  void updateBolusCalculation() {
    if (_GlucoseController.text.isNotEmpty && showTotalCarbs == true) {
      glucoseLevel = double.parse(_GlucoseController.text);

      int bolusCalculationResult = calculateDosage(
          totalCarbs, glucoseLevel, double.parse(carbRatioSelected!));
      bolusCalculation.value = bolusCalculationResult + 0;
      DBHelper dbHelper = DBHelper.instance;
      DateTime now = DateTime.now();
      date = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(now);
    } else {
      bolusCalculation.value = 0;
    }
  }

  @override
  void initState() {
    super.initState();

    _GlucoseController.addListener(updateBolusCalculation);
    //_CarbController.addListener(updateBolusCalculation);
  }

  @override
  void dispose() {
    _GlucoseController.removeListener(updateBolusCalculation);
    //_CarbController.removeListener(updateBolusCalculation);
    chosenMeals.clear();
    _timer?.cancel();
    super.dispose();
  }

  bool showTotalCarbs = false;
  void addMeal() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
    setState(() {
      showTotalCarbs = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Add Input',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 249, 254),
            fontSize: 17,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: SingleChildScrollView(
        child: Form(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            ValueListenableBuilder<int>(
                              valueListenable: bolusCalculation,
                              builder: (context, value, child) {
                                return Text(
                                  value.toString(),
                                  style: const TextStyle(
                                    fontSize: 35,
                                    fontFamily: "Inter",
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            );

                            if (getChosenMeals().isNotEmpty &&
                                _GlucoseController.text.isNotEmpty) {
                              /*bolusCalculation =
                                  calculateDosage(totalCarbs, glucoseLevel);
*/
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'Are you sure you want to save the input?'),
                                    actions: <Widget>[
                                      Row(
                                        children: [
                                          TextButton(
                                            child: const Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: const Text('Yes'),
                                            onPressed: () async {
                                              double glucoseLevel =
                                                  double.parse(
                                                      _GlucoseController.text);
                                              DBHelper dbHelper =
                                                  DBHelper.instance;
                                              await dbHelper.createEntry(
                                                  glucoseLevel,
                                                  bolusCalculation.value,
                                                  date,
                                                  chosenMeals,
                                                  glucoseUnit_,
                                                  totalCarbs);
                                              syncEntries();
                                              // print('Chosen Meals:');
                                              // print(chosenMeals);
                                              // print('Total Carbs:');
                                              // print(calculateTotalCarbs(
                                              //     getChosenMeals()));

                                              logger.info('Chosen Meals:');
                                              logger.info(chosenMeals);
                                              logger.info('Total Carbs:');
                                              logger.info(calculateTotalCarbs(
                                                  getChosenMeals()));

                                              Navigator.of(context).pop();
                                              setState(() {
                                                widget.changeTab(0);
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  );
                                },
                              );

                              //refresh the page after pressing the save button or go back to dashboard idk
                            } else if (getChosenMeals().isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('No Meals Chosen'),
                                    content: const Text(
                                        'Please add your meals and press on calculate'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else if (_GlucoseController.text.isEmpty) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Invalid Glucose input'),
                                    content: const Text(
                                        'Please enter your glucose levels'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Close'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: Color.fromARGB(255, 38, 20, 84),
                              fontSize: 18,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 50,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      color: const Color.fromARGB(255, 232, 232, 232),
                      child: SizedBox(
                        //height: 100,
                        width: double.infinity,

                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20.0, top: 10, bottom: 10, right: 30.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Bolus',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (BuildContext context) {
                                          return SizedBox(
                                            height: MediaQuery.of(context)
                                                .size
                                                .height,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: calc(),
                                          );
                                        },
                                      );
                                    },
                                    child: const Text(
                                      'CALCULATIONS',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color:
                                            Color.fromARGB(255, 116, 97, 164),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Column(
                                    children: [
                                      ValueListenableBuilder<int>(
                                        valueListenable: bolusCalculation,
                                        builder: (context, value, child) {
                                          return Text(
                                            value.toString(),
                                            style: const TextStyle(
                                              fontSize: 35,
                                              fontFamily: "Inter",
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  const Column(
                                    children: [
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "units",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: "Inter",
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Selected Carb Ratio',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          (carbRatio_2 == 0.0 && carbRatio_3 == 0.0)
                              ? Text(
                                  "$carbRatio_",
                                  style: const TextStyle(
                                      fontSize: 18,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontWeight: FontWeight.w500),
                                )
                              : DropdownButton(
                                  hint: Text("$carbRatio_"),
                                  value: carbRatioSelected,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      carbRatioSelected = newValue;
                                    });
                                  },
                                  items: <String>[
                                    carbRatio_.toString(),
                                    carbRatio_2.toStringAsFixed(2),
                                    carbRatio_3.toStringAsFixed(2)
                                  ]
                                      .where((String value) =>
                                          value != '0.00' && value != '0')
                                      //.toSet()
                                      .toList()
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 215, 215, 215),
                      //height: 10,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Glucose',
                            style: TextStyle(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 7,
                                height: 30,
                                child: TextFormField(
                                  controller: _GlucoseController,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: false),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.]')),
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: '0',
                                    border: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        width: 100,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                glucoseUnit_ == 0 ? "mmol/L" : "mg/dL",
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.w300),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              /*const Icon(
                                Icons.link_off,
                                color: Color.fromARGB(255, 38, 20, 84),
                              ),*/
                            ],
                          ),
                          /*IconButton(
                            icon: Icons.link_off,
                            color: const Color.fromARGB(255, 107, 100, 126),
                            onPressed: () {
                                
                                  
                                
                            },
                              
                            /*icon: _obscurePassword
                              ? const Icon(Icons.link)
                              : const Icon(Icons.link_off),*/
                          ),*/
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 215, 215, 215),
                      //height: 10,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0, right: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Carbs',
                            style: TextStyle(
                                fontSize: 19,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                //height: 20,
                                child: Column(
                                  children: <Widget>[
                                    if (!showTotalCarbs)
                                      ElevatedButton(
                                        onPressed: () {
                                          _timer?.cancel();
                                          totalCarbs =
                                              calculateTotalCarbs(chosenMeals);
                                          setState(
                                            () {
                                              showTotalCarbs = true;
                                              updateBolusCalculation();
                                            },
                                          );
                                        },
                                        child: const Text('Calculate'),
                                      ),
                                    if (showTotalCarbs)
                                      Text(
                                        '${carbUnit_ == 0 ? totalCarbs : totalCarbs ~/ 15}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                width: 0,
                              ),
                              Text(
                                carbUnit_ == 0 ? "carbs" : "exchanges",
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(
                      color: Color.fromARGB(255, 215, 215, 215),
                      //height: 10,
                      thickness: 1,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: chosenMeals.isEmpty
                            ? WrapAlignment.center
                            : WrapAlignment.start,
                        spacing: 10,
                        children: <Widget>[
                          for (var meal in chosenMeals)
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: SizedBox(
                                    width: 80,
                                    height: 80,
                                    child: Image.asset(
                                      '${meal['imageUrl']}',
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      _timer?.cancel();
                                      totalCarbs =
                                          calculateTotalCarbs(chosenMeals) -
                                              (meal["carbohydrates"] *
                                                  meal['quantity']);
                                      setState(() {
                                        chosenMeals.remove(meal);
                                        totalCCarbs =
                                            calculateTotalCarbs(meals);
                                        //showTotalCarbs = false;
                                      });
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50),
                                      child: Container(
                                        width: 30,
                                        height: 30,
                                        color: const Color.fromARGB(
                                            255, 49, 205, 215),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          InkWell(
                            onTap: () async {
                              var result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const Meals(Index: 0)),
                              );
                              if (result == 'refresh') {
                                refresh();
                              }
                              _timer = Timer.periodic(
                                  const Duration(seconds: 1), (timer) {
                                if (mounted) {
                                  // Check if the widget is still in the tree
                                  setState(() {});
                                }
                              });
                              setState(() {
                                showTotalCarbs = false;
                              });
                            },
                            child: Column(
                              children: [
                                SizedBox(
                                  width: chosenMeals.isEmpty ? 90 : 80,
                                  height: chosenMeals.isEmpty ? 90 : 80,
                                  child: Image.asset('assets/AddDish.png'),
                                ),
                                Text(
                                  'Add Meals',
                                  style: TextStyle(
                                    color:
                                        const Color.fromARGB(255, 38, 20, 84),
                                    fontSize: chosenMeals.isEmpty ? 20 : 17,
                                    fontFamily: 'Ruda',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget calc() {
    return Container(
      //height: MediaQuery.of(context).size.height,
      color: const Color.fromARGB(255, 255, 249, 254),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(255, 219, 219, 219),
            child: const Padding(
              padding: EdgeInsets.only(
                left: 10.0,
                top: 10,
                bottom: 10,
              ),
              child: Text(
                'Input Data',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Inter',
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: 10.0,
              top: 10,
              bottom: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Bolus Intake = 0 U',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 23, 128, 136),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  carbRatio_2 != 0
                      ? 'Carb Ratio 1 = $carbRatio_'
                      : 'Carb Ratio = $carbRatio_',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 23, 128, 136),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                carbRatio_2 != 0
                    ? Text(
                        'Carb Ratio 2 = $carbRatio_2',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Inter',
                          color: Color.fromARGB(255, 23, 128, 136),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Container(),
                carbRatio_2 != 0
                    ? const SizedBox(
                        height: 10,
                      )
                    : Container(),
                carbRatio_3 != 0
                    ? Text(
                        'Carb Ratio 3 = $carbRatio_3',
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Inter',
                          color: Color.fromARGB(255, 23, 128, 136),
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    : Container(),
                carbRatio_3 != 0
                    ? const SizedBox(
                        height: 10,
                      )
                    : Container(),
                Text(
                  'Insulin Sensitivity = $insulinSensitivity_',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 23, 128, 136),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  'Target = $targetBloodSugar_',
                  style: const TextStyle(
                    fontSize: 13,
                    fontFamily: 'Inter',
                    color: Color.fromARGB(255, 23, 128, 136),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Glucose = N/A',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 23, 128, 136),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  'Carbohydrates = N/A',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color.fromARGB(255, 23, 128, 136),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            color: const Color.fromARGB(255, 219, 219, 219),
            child: const Padding(
              padding: EdgeInsets.only(
                left: 10.0,
                top: 10,
                bottom: 10,
              ),
              child: Text(
                'Algorithm',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Inter',
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: 10.0,
              top: 10,
              bottom: 10,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'Correction =  ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 23, 128, 136),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Glucose - Target',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 23, 128, 136),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: Divider(
                            color: Color.fromARGB(255, 23, 128, 136),
                            thickness: 1,
                          ),
                        ), // Add this line

                        Text(
                          'Insulin Sensitivity',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 23, 128, 136),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'Bolus =  ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 23, 128, 136),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Correction + (  ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 23, 128, 136),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          'Carbohydrates',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 23, 128, 136),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(
                          width: 100,
                          child: Divider(
                            color: Color.fromARGB(255, 23, 128, 136),
                            thickness: 1,
                          ),
                        ),
                        Text(
                          '15',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color.fromARGB(255, 23, 128, 136),
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      ' * Carb Ratio )',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 23, 128, 136),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 255, 249, 254),
                    ),
                    shadowColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 255, 249, 254),
                    ),
                    overlayColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 255, 249, 254),
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 255, 249, 254),
                    ),
                    surfaceTintColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 255, 249, 254),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 23, 128, 136),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
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
