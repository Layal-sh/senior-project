// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _AppState extends State<App> {
  var selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page = Dashboard();
    switch (selectedIndex) {
      case 0:
        page = Dashboard();
        break;
      case 1:
        page = Settings();
        break;
      case 2:
        page = AddInput();
        break;
      case 3:
        page = Articles();
        break;
      case 4:
        page = Profile();
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
                      icon: Icon(Icons.settings_outlined, size: 30),
                      activeIcon: Icon(Icons.settings, size: 30),
                      label: 'Settings',
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
                      icon: Icon(Icons.newspaper_rounded, size: 30),
                      activeIcon: Icon(Icons.newspaper_rounded, size: 30),
                      label: 'Articles',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outlined, size: 30),
                      activeIcon: Icon(Icons.person, size: 30),
                      label: 'Profile',
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
      body: const SingleChildScrollView(
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

  final TextEditingController _GlucoseController = TextEditingController();
  final TextEditingController _CarbController = TextEditingController();
  String? carbRatioSelected;
  ValueNotifier<double> glucoseLevelNotifier = ValueNotifier<double>(0.0);
  ValueNotifier<double> carbsTotalNotifier = ValueNotifier<double>(0.0);
  ValueNotifier<int> bolusCalculation = ValueNotifier<int>(0);
  double glucoseLevel = 0.0;
  List<Map> meals = [];
  String date = "";
  int bolusCalculationResult = 0;

  void updateBolusCalculation() {
    if (_GlucoseController.text.isNotEmpty) {
      /* &&
        _CarbController.text.isNotEmpty && getChosenMeals().isNotEmpty*/
      glucoseLevel = double.parse(_GlucoseController.text);
      double totalCarbs = _CarbController.text.isNotEmpty
          ? double.parse(_CarbController.text)
          : 0.0;
      meals = getChosenMeals();
      double totalCarbs_ = calculateTotalCarbs(meals);
      int bolusCalculationResult = calculateDosage(totalCarbs_, glucoseLevel);
      bolusCalculation.value = bolusCalculationResult + 0;
      DBHelper dbHelper = DBHelper.instance;
      DateTime now = DateTime.now();
      date = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(now);
    }
  }

  @override
  void initState() {
    super.initState();
    _GlucoseController.addListener(updateBolusCalculation);
    _CarbController.addListener(updateBolusCalculation);
  }

  @override
  void dispose() {
    _GlucoseController.removeListener(updateBolusCalculation);
    _CarbController.removeListener(updateBolusCalculation);
    super.dispose();
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
                            /*double glucoseLevel =
                                double.parse(_GlucoseController.text);
                            if (getChosenMeals().isNotEmpty &&
                                _GlucoseController.text.isNotEmpty) {
                              bolusCalculation = calculateDosage(
                                  calculateTotalCarbs(getChosenMeals()),
                                  glucoseLevel);

                              print('Chosen Meals:');
                              print(chosenMeals);
                              print('Total Carbs:');
                              print(calculateTotalCarbs(getChosenMeals()));
                              print('Bolus Calculation:');
                              print(bolusCalculation);
                            } else {
                              print("NO WORKY");
                            }*/
                            DBHelper dbHelper = DBHelper.instance;
                            dbHelper.createEntry(glucoseLevel,
                                bolusCalculationResult, date, meals);
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
                          DropdownButton(
                            hint: const Text("Select"),
                            value: carbRatioSelected,
                            onChanged: (String? newValue) {
                              setState(() {
                                carbRatioSelected = newValue;
                              });
                            },
                            items: <String>['x', 'y', 'z']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                ),
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
                                width: MediaQuery.of(context).size.width / 7,
                                //height: 20,
                                child: const Text(
                                  '0',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
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
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Meals()),
                        );
                      },
                      child: Column(
                        children: [
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: Image.asset('assets/AddDish.png'),
                          ),
                          const Text(
                            'Add Meals',
                            style: TextStyle(
                              color: Color.fromARGB(255, 38, 20, 84),
                              fontSize: 20,
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
      final response =
          await http.get(Uri.parse('http://$localhost:8000/News/$s'));

      if (response.statusCode == 200) {
        List<dynamic> responseData = jsonDecode(response.body);
        DBHelper dbHelper = DBHelper.instance;
        for (var article in responseData) {
          List<Map> res = await dbHelper.checkArticle(article['title']);
          starred!.add(res.isNotEmpty);
          logger.info("Starred: ${starred!.last}");
        }

        setState(() {
          articles.addAll(responseData);
          starred;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
      body: (articles.isEmpty || starred == null)
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                String? imageUrl = articles[index]['thumbnail'];
                String title = articles[index]['title'];
                String url = articles[index]['link'];
                String? date = articles[index]['date'];

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    leading: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            width: 60, // adjust the width as needed
                            height: 60, // adjust the height as needed
                            fit: BoxFit.cover,
                          )
                        : null,
                    title: Text(title),
                    subtitle: date != null
                        ? Text(date)
                        : null, // display the date here
                    trailing: IconButton(
                      icon: Icon(
                        starred![index] ? Icons.star : Icons.star_border,
                        color: starred![index] ? Colors.yellow : null,
                      ),
                      onPressed: () async {
                        logger.info("clicked");
                        DBHelper dbHelper = DBHelper.instance;
                        var response;
                        if (starred![index])
                          response = await dbHelper.deleteFavorite(url);
                        else
                          response = await dbHelper.addFavorite(
                              title, url, imageUrl!, date!);
                        logger.info(response);
                        setState(() {
                          starred![index] = !starred![index];
                        });
                      },
                    ),
                    onTap: () => launch(url),
                  ),
                );
              },
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
