// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/login/signup/login.dart';
import 'package:sugar_sense/main.dart';
import 'package:http/http.dart' as http;

class Settings extends StatefulWidget {
  const Settings({super.key});
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Widget settingItem(String title, String value, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            color: Color.fromARGB(255, 38, 20, 84),
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit,
                  color: Color.fromARGB(255, 22, 161, 170)),
              onPressed: onTap,
            ),
          ],
        ),
      ],
    );
  }

  Widget unitChanger(
      int unit, String unit1, String unit2, Function(int) onUnitChanged) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                onUnitChanged(0);
              });
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.055,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                color: unit == 0
                    ? const Color.fromARGB(255, 22, 161, 170)
                    : const Color.fromARGB(255, 217, 217, 217),
                border: Border.all(
                  color: const Color.fromARGB(0, 101, 73, 152),
                  width: 0,
                ),
              ),
              child: Center(
                child: Text(
                  unit1,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
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
                onUnitChanged(1);
              });
            },
            child: Container(
              height: MediaQuery.of(context).size.height * 0.055,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(10),
                  bottomRight: Radius.circular(10),
                ),
                color: unit == 1
                    ? const Color.fromARGB(255, 22, 161, 170)
                    : const Color.fromARGB(255, 217, 217, 217),
                border: Border.all(
                  color: const Color.fromARGB(0, 101, 73, 152),
                  width: 0,
                ),
              ),
              child: Center(
                child: Text(
                  unit2,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Rubik',
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget carbRatioInputDialog(String title, double initialCarbs,
      double initialInsulin, VoidCallback? onDelete) {
    TextEditingController carbsController =
        TextEditingController(text: initialCarbs.toStringAsFixed(2));
    TextEditingController insulinController =
        TextEditingController(text: initialInsulin.toStringAsFixed(2));
    bool checkIfValuesExist(double carbs, double insulin) {
      if (carbUnit_ == 0) carbs /= 15;

      double curRatio = insulin / carbs;

      return (curRatio == carbRatio_ ||
          curRatio == carbRatio_2 ||
          curRatio == carbRatio_3);
    }

    List<Widget> actions = [
      TextButton(
        style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 22, 161, 170)),
        onPressed: () {
          Navigator.of(context).pop();
        },
        child: const Text('Cancel'),
      ),
      TextButton(
        style: TextButton.styleFrom(
            foregroundColor: const Color.fromARGB(255, 22, 161, 170)),
        onPressed: () {
          double carbs = double.parse(carbsController.text);
          double insulin = double.parse(insulinController.text);

          if (carbs <= 0 || insulin <= 0) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Values must be greater than zero'),
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
          } else if (checkIfValuesExist(carbs, insulin)) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Error'),
                  content: const Text('Values already exist'),
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
            Navigator.of(context).pop({
              'carbs': carbs,
              'insulin': insulin,
            });
          }
        },
        child: const Text('OK'),
      ),
    ];

    if (onDelete != null) {
      actions.insert(
        0,
        TextButton(
          style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 255, 53, 53)),
          onPressed: () {
            setState(() {
              onDelete();
            });
            Navigator.of(context).pop();
          },
          child: const Text('Delete'),
        ),
      );
    }

    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          TextField(
            controller: carbsController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              labelText: carbUnit_ == 0 ? 'Carbs' : 'Exchanges',
            ),
          ),
          TextField(
            controller: insulinController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: const InputDecoration(
              labelText: 'Insulin units',
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }

  Widget numberInputDialog(String title, double initialValue) {
    TextEditingController controller =
        TextEditingController(text: initialValue.toStringAsFixed(2));
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          color: Color.fromARGB(255, 0, 0, 0),
          fontWeight: FontWeight.w600,
        ),
      ),
      content: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
        ],
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 22, 161, 170)),
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          style: TextButton.styleFrom(
              foregroundColor: const Color.fromARGB(255, 22, 161, 170)),
          onPressed: () {
            Navigator.of(context).pop(double.parse(controller.text));
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  List<Widget> carbRatioSettings() {
    List<Function> carbRatios = [
      (value) => carbRatio_ = value,
      (value) => carbRatio_2 = value,
      (value) => carbRatio_3 = value,
    ];
    List<Function> carbs = [
      (value) => value != null ? carbs_ = value : carbs_,
      (value) => value != null ? carbs_2 = value : carbs_2,
      (value) => value != null ? carbs_3 = value : carbs_3,
    ];
    List<Function> insulins = [
      (value) => value != null ? insulin_ = value : insulin_,
      (value) => value != null ? insulin_2 = value : insulin_2,
      (value) => value != null ? insulin_3 = value : insulin_3,
    ];

    List<Widget> settings = [];

    for (int i = 0; i < numOfRatios_; i++) {
      settings.add(
        settingItem(
          'Carb Ratio ${i + 1}:',
          "${carbUnit_ == 0 ? (carbs[i](null)).toStringAsFixed(2) : (carbs[i](null) / 15).toStringAsFixed(2)}/${insulins[i](null)}",
          () async {
            Map<String, double>? newCarbRatio =
                await showDialog<Map<String, double>>(
              context: context,
              builder: (context) => carbRatioInputDialog(
                'Enter new carb ratio',
                carbUnit_ == 0 ? carbs[i](null) : carbs[i](null) / 15,
                insulins[i](null),
                i == numOfRatios_ - 1 && numOfRatios_ > 1
                    ? () async {
                        carbs[i](0.0);
                        insulins[i](0.0);
                        carbRatios[i](0.0);
                        numOfRatios_--;
                        saveCarbRatios();
                      }
                    : null,
              ),
            );
            if (newCarbRatio != null) {
              setState(() {
                carbs[i](carbUnit_ == 0
                    ? newCarbRatio['carbs']!
                    : newCarbRatio['carbs']! * 15);
                insulins[i](newCarbRatio['insulin']!);
                carbRatios[i](insulins[i](null) /
                    (carbUnit_ == 0
                        ? carbs[i](null) / 15
                        : newCarbRatio['carbs']!));
                saveCarbRatios();
              });
            }
          },
        ),
      );
      settings.add(const SizedBox(height: 20));
    }

    if (numOfRatios_ < 3) {
      settings.add(
        ElevatedButton.icon(
          onPressed: () async {
            Map<String, double>? newCarbRatio =
                await showDialog<Map<String, double>>(
              context: context,
              builder: (context) => carbRatioInputDialog(
                'Enter new carb ratio',
                0,
                0,
                null,
              ),
            );
            if (newCarbRatio != null) {
              setState(() {
                carbs[numOfRatios_](carbUnit_ == 0
                    ? newCarbRatio['carbs']!
                    : newCarbRatio['carbs']! * 15);
                insulins[numOfRatios_](newCarbRatio['insulin']!);
                carbRatios[numOfRatios_](insulins[numOfRatios_](null) /
                    (carbs[numOfRatios_](null) / 15));
                numOfRatios_++;
                saveCarbRatios();
              });
            }
          },
          icon: const Icon(
            Icons.add,
            color: Color.fromARGB(255, 22, 161, 170),
          ),
          label: const Text(
            'Add Carb Ratio',
            style: TextStyle(
              color: Color.fromARGB(255, 22, 161, 170),
            ),
          ),
          style: ButtonStyle(
            backgroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
            overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
            foregroundColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
            surfaceTintColor:
                MaterialStateProperty.all<Color>(Colors.transparent),
          ),
        ),
      );
    }

    return settings;
  }

  List<Widget> doctorConnection() {
    List<Widget> doctorCon = [];
    bool connected = doctorCode_ != "";
    if (!connected) {
      doctorCon.add(ElevatedButton.icon(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              final TextEditingController controller = TextEditingController();
              return AlertDialog(
                title: const Text('Connect to Doctor'),
                content: TextField(
                  controller: controller,
                  decoration:
                      const InputDecoration(hintText: "Enter doctor code"),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () async {
                      String doctorCode = controller.text;
                      bool result = await changeDoctor(doctorCode);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result
                              ? 'Connected successfully'
                              : 'Failed to connect'),
                        ),
                      );
                      if (result) {
                        setState(() {
                          // Update your state here if necessary
                        });
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        label: const Text(
          'Connect to Doctor',
          style: TextStyle(
            color: Color.fromARGB(255, 22, 161, 170),
          ),
        ),
        icon: const Icon(
          Icons.link,
          color: Color.fromARGB(255, 22, 161, 170),
        ),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
          overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
          surfaceTintColor:
              MaterialStateProperty.all<Color>(Colors.transparent),
        ),
      ));
    } else {
      doctorCon.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Connected to:',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 38, 20, 84),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Dr. $doctorName_',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 22, 161, 170),
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.link_off,
                    color: Color.fromARGB(255, 255, 53, 53)),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Disconnect from Doctor'),
                        content:
                            const Text('Are you sure you want to disconnect?'),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('No'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: const Text('Yes'),
                            onPressed: () async {
                              bool result = await changeDoctor("None");
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(result
                                      ? 'Disconnected successfully'
                                      : 'Failed to disconnect'),
                                ),
                              );
                              if (result) {
                                setState(() {
                                  doctorCode_ = "";
                                });
                              }
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      );
      doctorCon.add(const SizedBox(height: 20));
      doctorCon.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text(
                'Appointment:',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 38, 20, 84),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nextAppointment_ == "" ? "No appointments" : nextAppointment_,
                style: const TextStyle(
                  fontSize: 18,
                  color: Color.fromARGB(255, 22, 161, 170),
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh,
                    color: Color.fromARGB(255, 22, 161, 170)),
                onPressed: () async {
                  await refreshNextAppointment();
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      );
    }

    return doctorCon;
  }

  Widget settingsTitle(String text) {
    return Container(
      color: Colors.grey[200], // adjust the shade of gray as needed
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 24,
          color: Color.fromARGB(255, 38, 20, 84),
        ),
      ),
    );
  }

  Widget privacyCheckbox(int index, String title) {
    if (privacy_.length < 3) {
      privacy_ = "000";
      savePrivacy();
    }
    return CheckboxListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          color: Color.fromARGB(255, 38, 20, 84),
          fontWeight: FontWeight.bold,
        ),
      ),
      value: privacy_[index] == '1',
      onChanged: (bool? value) {
        if (value != null) {
          setState(() {
            privacy_ = privacy_.substring(0, index) +
                (value ? '1' : '0') +
                privacy_.substring(index + 1);
            savePrivacy();
          });
        }
      },
      activeColor: const Color.fromARGB(255, 22, 161, 170),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text(
              'Sugar',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 249, 254),
                fontSize: 21,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Sense',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 249, 254),
                fontSize: 21,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: ListView(
        children: <Widget>[
          settingsTitle("Units:"),
          //const Divider(color: Colors.grey, height: 2.0),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Glucose Unit:',
                    style: TextStyle(
                      color: Color.fromARGB(255, 38, 20, 84),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child:
                      unitChanger(glucoseUnit_, 'mmol/L', 'mg/dL', (newUnit) {
                    glucoseUnit_ = newUnit;
                    saveUnits();
                  }),
                ),
              ],
            ),
          ),
          //const Divider(color: Colors.grey, height: 20.0),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  flex: 2,
                  child: Text(
                    'Carb Unit:',
                    style: TextStyle(
                      color: Color.fromARGB(255, 38, 20, 84),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: unitChanger(carbUnit_, 'Carbs', 'Exchange', (newUnit) {
                    carbUnit_ = newUnit;
                    saveUnits();
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          settingsTitle("Values:"),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              //crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                settingItem(
                    'Target Glucose:',
                    (glucoseUnit_ == 1
                            ? targetBloodSugar_
                            : targetBloodSugar_ / 18.0156)
                        .toStringAsFixed(glucoseUnit_ == 0 ? 2 : 0), () async {
                  double? newTargetBloodSugar = await showDialog(
                    context: context,
                    builder: (context) => numberInputDialog(
                        'Enter new target glucose',
                        (glucoseUnit_ == 1
                                ? targetBloodSugar_
                                : targetBloodSugar_ / 18.0156)
                            .toDouble()),
                  );
                  if (newTargetBloodSugar != null) {
                    setState(() {
                      targetBloodSugar_ = glucoseUnit_ == 1
                          ? (newTargetBloodSugar).toInt()
                          : (newTargetBloodSugar * 18.0156).toInt();
                      saveTarget();
                    });
                  }
                }),
                const SizedBox(height: 20),
                settingItem(
                    'Insulin Sensitivity:',
                    (glucoseUnit_ == 1
                            ? insulinSensitivity_
                            : insulinSensitivity_ / 18.0156)
                        .toStringAsFixed(glucoseUnit_ == 0 ? 2 : 0), () async {
                  double? newInsulinSensitivity = await showDialog(
                    context: context,
                    builder: (context) => numberInputDialog(
                        'Enter new insulin sensitivity',
                        (glucoseUnit_ == 1
                                ? insulinSensitivity_
                                : insulinSensitivity_ / 18.0156)
                            .toDouble()),
                  );
                  if (newInsulinSensitivity != null) {
                    setState(() {
                      insulinSensitivity_ = glucoseUnit_ == 1
                          ? (newInsulinSensitivity).toInt()
                          : (newInsulinSensitivity * 18.0156).toInt();
                      saveInsulinSensitivity();
                    });
                  }
                }),
                const SizedBox(height: 20),
                ...carbRatioSettings(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.grey[200],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                settingsTitle("Privacy:"),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: IconButton(
                        icon: const Icon(Icons.info_outline,
                            //color: Color.fromARGB(255, 22, 161, 170)
                            color: Color.fromARGB(255, 38, 20, 84)),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text(
                                  'Privacy Settings',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: const Text(
                                  'Choose what your doctor will have access to.',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 22, 161, 170),
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color.fromARGB(
                                          255, 22, 161, 170),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          privacyCheckbox(0, 'Glucose levels'),
          privacyCheckbox(1, 'Insulin intake'),
          privacyCheckbox(2, 'Meals'),
          const SizedBox(height: 20),
          settingsTitle("Doctor Connection"),
          const SizedBox(height: 20),
          ...doctorConnection(),
          const SizedBox(height: 20),
          settingsTitle("Account"),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              String pass = "";
              String confirmationString = "";
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Account'),
                    content: SingleChildScrollView(
                      child: SizedBox(
                        height: 200,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Text(
                                'Please enter your password and type "I want to delete my account" to confirm.'),
                            TextField(
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                              ),
                              onChanged: (value) {
                                pass = value;
                              },
                            ),
                            TextField(
                              decoration: const InputDecoration(
                                labelText: 'Confirmation Phrase',
                              ),
                              onChanged: (value) {
                                confirmationString = value;
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: const Text('Confirm'),
                        onPressed: () async {
                          if (confirmationString ==
                              'I want to delete my account') {
                            final response = await http
                                .post(
                                  Uri.parse(
                                      'http://$localhost:8000/deleteAccount'),
                                  headers: <String, String>{
                                    'Content-Type':
                                        'application/json; charset=UTF-8',
                                  },
                                  body: jsonEncode(<String, String>{
                                    'username': username_,
                                    'password': pass,
                                  }),
                                )
                                .timeout(const Duration(seconds: 10));
                            if (response.statusCode == 200) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Login(),
                                  ));
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Error'),
                                    content:
                                        const Text("Couldn't delete account"),
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
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      "Confirmation string is incorrect"),
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
                        },
                      ),
                    ],
                  );
                },
              );
            },
            label: const Text(
              'Delete Account',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 53, 53),
              ),
            ),
            icon: const Icon(
              Icons.delete,
              color: Color.fromARGB(255, 255, 53, 53),
            ),
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
              shadowColor: MaterialStateProperty.all<Color>(Colors.transparent),
              overlayColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
              foregroundColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
              surfaceTintColor:
                  MaterialStateProperty.all<Color>(Colors.transparent),
            ),
          )
          // Padding(
          //   padding: const EdgeInsets.only(
          //     left: 10,
          //     right: 10,
          //   ),
          //   child: TextButton(
          //     onPressed: () {
          //       showDialog(
          //         context: context,
          //         builder: (BuildContext context) {
          //           return AlertDialog(
          //             title: const Text('Delete Account'),
          //             content: const Text(
          //                 'Are you sure you want to delete your account?'),
          //             actions: <Widget>[
          //               TextButton(
          //                 child: const Text('No'),
          //                 onPressed: () {
          //                   Navigator.of(context).pop();
          //                 },
          //               ),
          //               TextButton(
          //                 child: const Text('Yes'),
          //                 onPressed: () async {
          //                   await deleteAccount();
          //                   Navigator.push(
          //                     context,
          //                     MaterialPageRoute(
          //                       builder: (context) => const Login(),
          //                     ),
          //                   );
          //                 },
          //               ),
          //             ],
          //           );
          //         },
          //       );
          //     },
          //     child: const Row(
          //       children: <Widget>[
          //         Icon(
          //           Icons.delete,
          //           color: Colors.red,
          //           size: 30,
          //         ),
          //         SizedBox(
          //             width:
          //                 15.0), // Add some space between the icon and the text
          //         Text(
          //           'Delete Account',
          //           style: TextStyle(
          //             color: Colors.red,
          //             fontSize: 18,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 20),
          // settingsTitle(
          //     "FOR TESTING SAKE PLEASE DONT FORGET TO REMOVE BEFORE PRODUCTION"),
          // TextButton(
          //     onPressed: () {
          //       DBHelper dbHelper = DBHelper.instance;
          //       dbHelper.getMealsFromEntryID(7);
          //     },
          //     child: const Text("hehe")),
        ],
      ),
    );
  }
}

deleteAccount() async {
  DBHelper dbHelper = DBHelper.instance;
  await dbHelper.reset();
  logger.info('local DB has been reset');

  final response =
      await http.get(Uri.parse('http://$localhost:8000/deleteAccount/$pid_'));
  if (response.statusCode == 200) {
    logger.info('account has been deleted');
  } else {
    logger.warning('Failed to delete account');
  }
}

refreshNextAppointment() async {
  final responseAppointment =
      await http.get(Uri.parse("http://$localhost:8000/getAppointment/$pid_"));
  if (responseAppointment.statusCode == 200) {
    logger.info(responseAppointment.body);
    dynamic appointmentDetails = jsonDecode(responseAppointment.body);
    appointmentDetails = jsonDecode(appointmentDetails);
    logger.info('appointments body: $appointmentDetails');
    if (appointmentDetails != null) {
      nextAppointment_ = appointmentDetails['startDay'];
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'nextAppointment',
      nextAppointment_,
    );
    logger.info('bro worked: $nextAppointment_');
  } else if (responseAppointment.statusCode == 404) {
    logger.info('No appointments available for this user');
  } else {
    logger.warning('Failed to get appointments for this user');
  }
}
