import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/application/addInput.dart';
import 'package:sugar_sense/application/articles.dart';
import 'package:sugar_sense/application/dashboard.dart';
import 'package:sugar_sense/application/meals.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sugar_sense/application/profile.dart';
import 'package:sugar_sense/login/signup/signup.dart';
import 'package:sugar_sense/main.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

Timer? _timer;
var selectedIndex = 0;
List articles = [];
List<bool>? starred;
late List filteredArticles;
late List restArticles;
late List finalList;

isValidPhoneNumber(String phone) {
  final RegExp regex = RegExp(r'^\d{8}$');
  return regex.hasMatch(phone);
}

int id = pid_;

// in the update functions
/*
if evrything correct or user didn't change anything functions return 1
if email/username/phone already exists functions return 0
if email/phone is invalid functions return 2
if a a random error(won't happen bc we made sure of it) occured it returns -1
*/
userNameUpdate(String username) async {
  if (username != username_) {
    try {
      final name = await http.get(
          Uri.parse('http://$localhost:8000/changeUsername/$username/$id'));
      if (name.statusCode == 200) {
        username_ = username;
        return 1;
      } else if (name.statusCode == 401) {
        //display snackbar thingy with username already exists
        return 0;
      } else {
        //display snackbar thingy random error occured
        return -1;
      }
    } catch (e) {
      print('Network request failed: $e');
      return -1;
    }
  } else {
    return 1;
  }
}

emailUpdate(String email) async {
  if (!isValidEmail(email)) {
    return 2;
  }
  if (email != email_) {
    final name = await http
        .get(Uri.parse('http://$localhost:8000/changeEmail/$email/$id'));
    if (name.statusCode == 200) {
      email_ = email;
      return 1;
    } else if (name.statusCode == 401) {
      //display snackbar thingy with username already exists
      return 0;
    } else {
      //display snackbar thingy random error occured
      return -1;
    }
  } else {
    return 1;
  }
}

phoneUpdate(String phone) async {
  if (phone != phoneNumber_) {
    if (!isValidPhoneNumber(phone)) {
      return 2;
    }
    final name = await http
        .get(Uri.parse('http://$localhost:8000/changePhone/$phone/$id'));
    if (name.statusCode == 200) {
      phoneNumber_ = phone;
      return 1;
    } else if (name.statusCode == 401) {
      //display snackbar thingy with username already exists
      return 0;
    } else {
      //display snackbar thingy random error occured
      return -1;
    }
  } else {
    return 1;
  }
}

class _AppState extends State<App> {
  void fetchArticles() async {
    List<String> searches = [
      'diabetes type 1',
      'diabetes lifestyle',
      'diabetes article',
      'diabetes insulin'
    ];

    for (String s in searches) {
      logger.info("getting $s");
      final response =
          await http.get(Uri.parse('http://$localhost:8000/News/$s'));
      logger.info("got $s");
      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        DBHelper dbHelper = DBHelper.instance;
        for (var article in responseData) {
          List<Map> result = await dbHelper.checkArticle(article['link']);
          starred!.add(result.isNotEmpty);
        }
        responseData.sort((a, b) {
          if (a['date'] != null && b['date'] != null) {
            try {
              DateFormat format = DateFormat("MMM dd, yyyy");
              DateTime dateA = format.parse(a['date']);
              DateTime dateB = format.parse(b['date']);
              return dateB.compareTo(dateA);
            } catch (e) {
              return 0;
            }
          }
          return 0;
        });

        if (mounted) {
          setState(() {
            articles.addAll(responseData);
          });
        }
      }
    }
    filtered();
    //print(articles);
    logger.info(articles);
  }

  void filtered() {
    filteredArticles =
        articles.where((article) => article['thumbnail'] != null).toList();
    filteredArticles.sort((a, b) {
      if (a['date'] != null && b['date'] != null) {
        try {
          DateFormat format = DateFormat("MMM dd, yyyy");
          DateTime dateA = format.parse(a['date']);
          DateTime dateB = format.parse(b['date']);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      }
      return 0;
    });
    filteredArticles = filteredArticles.take(5).toList();
    restArticles = articles
        .where((article) => !filteredArticles.any(
            (filteredArticle) => filteredArticle['title'] == article['title']))
        .toList();
    finalList = [...filteredArticles, ...restArticles];
    //print(restArticles);
    logger.info(restArticles);
  }

  @override
  void initState() {
    super.initState();
    TotalCarbs();
    selectedIndex = 0;
    filteredArticles = [];
    restArticles = [];
    finalList = [];
    starred = [];
    fetchArticles();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget page = Dashboard(
      changeTab: onTabTapped,
    );

    switch (selectedIndex) {
      case 0:
        page = Dashboard(
          changeTab: onTabTapped,
        );
        _timer?.cancel();
        break;
      case 1:
        page = const Articles();

        _timer?.cancel();
        break;
      case 2:
        page = AddInput(
          changeTab: onTabTapped,
        );
        break;
      case 3:
        page = const Profile();
        _timer?.cancel();
        break;
      case 4:
        page = const Settings();

        _timer?.cancel();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    var mainArea = ColoredBox(
      color: const Color.fromARGB(255, 255, 249, 254),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: page,
      ),
    );
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            children: [
              Expanded(child: mainArea),
              SafeArea(
                child: BottomNavigationBar(
                  //backgroundColor: Color.fromARGB(255, 0, 0, 0),
                  unselectedItemColor: const Color.fromARGB(255, 38, 20, 84),
                  selectedItemColor: const Color.fromARGB(255, 38, 20, 84),
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  selectedLabelStyle:
                      const TextStyle(fontWeight: FontWeight.w900),
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined, size: 30),
                      activeIcon: Icon(Icons.home_filled, size: 30),
                      label: 'Home',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.newspaper_rounded, size: 30),
                      activeIcon: Icon(Icons.newspaper_rounded, size: 30),
                      label: 'Articles',
                    ),
                    BottomNavigationBarItem(
                      icon: CircleAvatar(
                        radius: 25, // Half of your icon size
                        backgroundColor: Color.fromARGB(255, 38, 20,
                            84), // Replace with your desired background color
                        child: Icon(
                          Icons.add,
                          size: 50,
                          color: Color.fromARGB(255, 255, 249, 254),
                        ),
                      ),
                      activeIcon: CircleAvatar(
                        radius: 25, // Half of your icon size
                        backgroundColor: Color.fromARGB(255, 38, 20,
                            84), // Replace with your desired background color
                        child: Icon(
                          Icons.add_outlined,
                          size: 50,
                          color: Color.fromARGB(255, 255, 249, 254),
                        ),
                      ),
                      label: 'Add Input',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outlined, size: 30),
                      activeIcon: Icon(Icons.person, size: 30),
                      label: 'Profile',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings_outlined, size: 30),
                      activeIcon: Icon(Icons.settings, size: 30),
                      label: 'Settings',
                    ),
                  ],
                  currentIndex: selectedIndex,
                  onTap: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

// class Settings extends StatelessWidget {
//   //const Settings({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         title: const Row(
//           children: [
//             Text(
//               'Sugar',
//               style: TextStyle(
//                 color: Color.fromARGB(255, 255, 249, 254),
//                 fontSize: 21,
//                 fontFamily: 'Inter',
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             Text(
//               'Sense',
//               style: TextStyle(
//                 color: Color.fromARGB(255, 255, 249, 254),
//                 fontSize: 21,
//                 fontFamily: 'Inter',
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//         backgroundColor: const Color.fromARGB(255, 38, 20, 84),
//       ),
//       body: const SingleChildScrollView(
//         child: Center(
//           child: Text('Setting!'), // Replace with your desired text
//         ),
//       ),
//     );
//   }
// }

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
          Navigator.of(context).pop({
            'carbs': double.parse(carbsController.text),
            'insulin': double.parse(insulinController.text),
          });
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
          "${carbUnit_ == 0 ? (carbs[i](null)).toString() : (carbs[i](null) / 15).toString()}/${insulins[i](null)}",
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
                        saveValues();
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
                saveValues();
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
          onPressed: () => setState(() => numOfRatios_++),
          icon: const Icon(Icons.add),
          label: const Text('Add Carb Ratio'),
        ),
      );
    }

    return settings;
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
                      saveValues();
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
                      saveValues();
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
          ElevatedButton.icon(
            onPressed: () => int, // replace with your function
            icon: const Icon(Icons.link),
            label: const Text('Connect to Doctor'),
          ),
        ],
      ),
    );
  }
}
