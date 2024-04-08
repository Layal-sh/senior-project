import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
//import 'package:flutter/widgets.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/application/meals.dart';
import 'package:sugar_sense/AI/ai_functions.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sugar_sense/main.dart';
import 'package:url_launcher/url_launcher.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

Timer? _timer;

class _AppState extends State<App> {
  var selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    TotalCarbs();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget page = Dashboard();

    switch (selectedIndex) {
      case 0:
        page = Dashboard();
        _timer?.cancel();
        break;
      case 1:
        page = const Articles();

        _timer?.cancel();
        break;
      case 2:
        page = const AddInput();
        break;
      case 3:
        page = Profile();
        _timer?.cancel();
        break;
      case 4:
        page = Settings();

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

class Dashboard extends StatelessWidget {
  //const Dashboard({Key? key}) : super(key: key);

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
      body: SingleChildScrollView(
        child: Center(
          child: Text('Home!'), // Replace with your desired text
        ),
      ),
    );
  }
}

class Settings extends StatelessWidget {
  //const Settings({Key? key}) : super(key: key);

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
      body: const SingleChildScrollView(
        child: Center(
          child: Text('Setting!'), // Replace with your desired text
        ),
      ),
    );
  }
}

class AddInput extends StatefulWidget {
  const AddInput({super.key});

  @override
  _AddInputState createState() => _AddInputState();
}

class _AddInputState extends State<AddInput> {
  //const Settings({Key? key}) : super(key: key);
  void refresh() {
    setState(() {});
  }

  final TextEditingController _GlucoseController = TextEditingController();
  //final TextEditingController _CarbController = TextEditingController();
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

      int bolusCalculationResult = calculateDosage(totalCarbs, glucoseLevel);
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
                            double glucoseLevel =
                                double.parse(_GlucoseController.text);
                            if (getChosenMeals().isNotEmpty &&
                                _GlucoseController.text.isNotEmpty) {
                              /*bolusCalculation =
                                  calculateDosage(totalCarbs, glucoseLevel);
*/
                              DBHelper dbHelper = DBHelper.instance;
                              dbHelper.createEntry(glucoseLevel,
                                  bolusCalculationResult, date, chosenMeals);
                              print('Chosen Meals:');
                              print(chosenMeals);
                              print('Total Carbs:');
                              print(calculateTotalCarbs(getChosenMeals()));
                              //refresh the page after pressing the save button or go back to dashboard idk
                            } else {
                              print("NO WORKY");
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
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Total Bolus',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    'CALCULATIONS',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color.fromARGB(255, 116, 97, 164),
                                      fontWeight: FontWeight.w500,
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
                                    carbRatio_2.toString(),
                                    carbRatio_3.toString()
                                  ]
                                      .where((String value) => value != '0.0')
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
                                height: 20,
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
                              const Text(
                                "mg/dL",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.w300),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              const Icon(
                                Icons.link_off,
                                color: Color.fromARGB(255, 38, 20, 84),
                              ),
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
                                        '$totalCarbs',
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
                              const Text(
                                "grams",
                                style: TextStyle(
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

                                        showTotalCarbs = false;
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
}

class Articles extends StatefulWidget {
  const Articles({super.key});

  @override
  _ArticlesState createState() => _ArticlesState();
}

class _ArticlesState extends State<Articles> {
  List articles = [];
  List<bool>? starred;

  @override
  void initState() {
    super.initState();
    articles = [];
    starred = [];
    fetchArticles();
  }

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
  }

  bool _isPressed = false;
  @override
  Widget build(BuildContext context) {
    List filteredArticles =
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 25.0,
              right: 25,
              top: 30,
              bottom: 20,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Todays Read',
                  style: TextStyle(
                    fontSize: 27,
                    fontFamily: 'InriaSerifBold',
                    color: Color.fromARGB(255, 38, 20, 84),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isPressed = !_isPressed;
                    });
                  },
                  child: Icon(
                    _isPressed
                        ? Icons.notifications
                        : Icons.notifications_none_outlined,
                    size: 30,
                    color: const Color.fromARGB(255, 38, 20, 84),
                  ),
                ),
              ],
            ),
          ),
          (filteredArticles.isEmpty || starred == null)
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.25,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        String? imageUrl = filteredArticles[index]['thumbnail'];
                        String title = filteredArticles[index]['title'];
                        String url = filteredArticles[index]['link'];
                        String? date = filteredArticles[index]['date'];

                        return Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: SizedBox(
                            child: InkWell(
                              onTap: () => launch(url),
                              child: Card(
                                color: Colors.transparent,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                clipBehavior: Clip.antiAlias,
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color.fromARGB(
                                                    185, 77, 77, 77)
                                                .withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 7,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(10.0),
                                          topRight: Radius.circular(10.0),
                                          bottomLeft: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                        child: imageUrl != null
                                            ? Image.network(
                                                imageUrl,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.5,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.15,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          top: 8.0,
                                          left: 25,
                                          //right: 15,
                                        ),
                                        child: ShaderMask(
                                          shaderCallback: (Rect bounds) {
                                            return const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: <Color>[
                                                Colors.black,
                                                Color.fromARGB(51, 0, 0, 0)
                                              ],
                                              stops: <double>[0.7, 1.0],
                                            ).createShader(bounds);
                                          },
                                          blendMode: BlendMode.dstIn,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                child: Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontFamily: 'InriaSerif',
                                                    color: Color.fromARGB(
                                                        255, 38, 20, 84),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  starred![index]
                                                      ? Icons.bookmark_rounded
                                                      : Icons
                                                          .bookmark_border_rounded,
                                                  color: starred![index]
                                                      ? const Color.fromARGB(
                                                          255,
                                                          49,
                                                          205,
                                                          215) // Corrected color definition
                                                      : const Color.fromARGB(
                                                          255, 49, 205, 215),
                                                  size: 27,
                                                ),
                                                onPressed: () async {
                                                  logger.info("clicked");
                                                  DBHelper dbHelper =
                                                      DBHelper.instance;
                                                  var response;
                                                  if (starred![index]) {
                                                    response = await dbHelper
                                                        .deleteFavorite(url);
                                                    logger.info(response);
                                                  } else {
                                                    response = await dbHelper
                                                        .addFavorite(url, title,
                                                            imageUrl, date);
                                                  }
                                                  logger.info(response);
                                                  setState(
                                                    () {
                                                      starred![index] =
                                                          !starred![index];
                                                    },
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
          const Padding(
            padding: EdgeInsets.only(
              left: 25.0,
              bottom: 5,
            ),
            child: Text(
              'For You',
              style: TextStyle(
                fontSize: 22,
                fontFamily: 'InriaSerifBold',
                color: Color.fromARGB(255, 38, 20, 84),
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: (articles.isEmpty || starred == null)
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: SizedBox(
                      child: ListView.builder(
                        itemCount: articles
                            .where((article) =>
                                !filteredArticles.contains(article))
                            .toList()
                            .length,
                        itemBuilder: (context, index) {
                          String? imageUrl = articles[index]['thumbnail'];
                          String title = articles[index]['title'];
                          String url = articles[index]['link'];
                          String? date = articles[index]['date'];

                          return SizedBox(
                            height: imageUrl != null
                                ? MediaQuery.of(context).size.height * 0.13
                                : null,
                            child: InkWell(
                              onTap: () => launch(url),
                              child: Card(
                                color: Colors.transparent,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    //bottom: 5.0,
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      imageUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: Image.network(
                                                imageUrl,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                                height:
                                                    120, // Adjust the height as needed
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(),
                                      const SizedBox(
                                          width: 10), // Add some spacing
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'InriaSerif',
                                                color: Color.fromARGB(
                                                    255, 38, 20, 84),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (date != null)
                                              SizedBox(
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      size: 17,
                                                      color: Color.fromARGB(
                                                          255, 106, 106, 106),
                                                    ),
                                                    const SizedBox(
                                                      width: 7,
                                                    ),
                                                    Text(
                                                      date,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 106, 106, 106),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          starred![index +
                                                  filteredArticles.length]
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color: starred![index +
                                                  filteredArticles.length]
                                              ? const Color.fromARGB(
                                                  255, 49, 205, 215)
                                              : const Color.fromARGB(
                                                  255, 49, 205, 215),
                                          size: 25,
                                        ),
                                        onPressed: () async {
                                          logger.info("clicked");
                                          DBHelper dbHelper = DBHelper.instance;
                                          var response;
                                          if (starred![index +
                                              filteredArticles.length]) {
                                            response = await dbHelper
                                                .deleteFavorite(url);
                                            logger.info(response);
                                          } else {
                                            response =
                                                await dbHelper.addFavorite(
                                                    url, title, imageUrl, date);
                                          }
                                          logger.info(response);
                                          setState(
                                            () {
                                              starred![index +
                                                      filteredArticles.length] =
                                                  !starred![index +
                                                      filteredArticles.length];
                                            },
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class Profile extends StatelessWidget {
  //const Settings({Key? key}) : super(key: key);

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
      body: const SingleChildScrollView(
        child: Center(
          child: Text('Profile!'), // Replace with your desired text
        ),
      ),
    );
  }
}
