import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/accCreation/membership.dart';
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
var selectedIndex = 0;
List articles = [];
List<bool>? starred;

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
  }

  @override
  void initState() {
    super.initState();
    TotalCarbs();
    selectedIndex = 0;

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

class Dashboard extends StatefulWidget {
  final Function changeTab;
  Dashboard({required this.changeTab});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool today = true;
  bool monthly = false;
  bool yearly = false;
  bool b = true;
  bool g = false;
  bool c = false;
  Map<String, dynamic> latestEntry = {};
  List<Map> entries = [];
  List<Map> dayentries = [];
  List<Map> monthentries = [];
  List<Map> yearentries = [];
  List<Map> averageInsulinDosagePerDay = [];
  List<Map> averageInsulinDosagePerMonth = [];
  void calculateAverageInsulinDosage() {
    var groupedEntries = groupBy(monthentries, (entry) {
      return DateTime.parse(entry['date']).day;
    });

    groupedEntries.forEach((day, entries) {
      double averageInsulinDosage = entries
              .map((e) => double.parse(e['insulinDosage'].toString()))
              .reduce((a, b) => a + b) /
          entries.length;
      double averageGlucose = entries
              .map((e) => double.parse(e['glucoseLevel'].toString()))
              .reduce((a, b) => a + b) /
          entries.length;
      double averageCarbs = entries
              .map((e) => double.parse(e['totalCarbs'].toString()))
              .reduce((a, b) => a + b) /
          entries.length;
      averageInsulinDosagePerDay.add({
        'day': day,
        'averageInsulinDosage': averageInsulinDosage,
        'averageGlucose': averageGlucose,
        'averageCarbs': averageCarbs,
      });
    });
  }

  void calculateAverageMonthly() {
    var groupedEntries = groupBy(yearentries, (entry) {
      return DateTime.parse(entry['date']).month;
    });

    groupedEntries.forEach((month, entries) {
      double averageInsulinDosage = entries
              .map((e) => double.parse(e['insulinDosage'].toString()))
              .reduce((a, b) => a + b) /
          entries.length;
      double averageGlucose = entries
              .map((e) => double.parse(e['glucoseLevel'].toString()))
              .reduce((a, b) => a + b) /
          entries.length;
      double averageCarbs = entries
              .map((e) => double.parse(e['totalCarbs'].toString()))
              .reduce((a, b) => a + b) /
          entries.length;
      averageInsulinDosagePerMonth.add({
        'month': month,
        'averageInsulinDosage': averageInsulinDosage,
        'averageGlucose': averageGlucose,
        'averageCarbs': averageCarbs,
      });
    });
  }

  @override
  void initState() {
    super.initState();
    loadLatestEntry();
    db.getEntries(1).then((result) {
      setState(() {
        dayentries = result;
      });
    });
    db.getEntries(2).then((result) {
      setState(() {
        entries = result;
      });
    });
    db.getEntries(3).then((result) {
      setState(() {
        monthentries = result;
      });
      calculateAverageInsulinDosage();
    });
    db.getEntries(4).then((result) {
      setState(() {
        yearentries = result;
      });
      calculateAverageMonthly();
    });
  }

  loadLatestEntry() async {
    var entry = await db.getLatestEntry();
    setState(() {
      latestEntry = entry;
    });
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map>> entriesByDate = {};
    for (var entry in entries) {
      String date =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(entry['date']));
      if (entriesByDate[date] == null) {
        entriesByDate[date] = [entry];
      } else {
        entriesByDate[date]!.add(entry);
      }
    }
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                top: 20,
              ),
              child: Text(
                "Welcome back !",
                style: TextStyle(
                  fontSize: 23,
                  fontFamily: 'Ruda',
                  color: Color.fromARGB(255, 38, 20, 84),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                top: 10,
              ),
              child: Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'RudaBlack',
                  color: Color.fromARGB(255, 38, 20, 84),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 20, right: 20),
              child: Row(
                children: [
                  SizedBox(
                    //width: 60,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          today = true;
                          yearly = false;
                          monthly = false;
                        });
                      },
                      child: Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 12,
                          color: today
                              ? const Color.fromARGB(255, 22, 161, 170)
                              : const Color.fromARGB(255, 26, 11, 63),
                          fontWeight: today ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    //width: 60,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          yearly = false;
                          today = false;
                          monthly = true;
                        });
                      },
                      child: Text(
                        'Monthly',
                        style: TextStyle(
                          fontSize: 12,
                          color: monthly
                              ? const Color.fromARGB(255, 22, 161, 170)
                              : const Color.fromARGB(255, 26, 11, 63),
                          fontWeight:
                              monthly ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    //width: 60,
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          yearly = true;
                          today = false;
                          monthly = false;
                        });
                      },
                      child: Text(
                        'Yearly',
                        style: TextStyle(
                          fontSize: 12,
                          color: yearly
                              ? const Color.fromARGB(255, 22, 161, 170)
                              : const Color.fromARGB(255, 26, 11, 63),
                          fontWeight:
                              yearly ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AspectRatio(
              aspectRatio: 1.60,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 18,
                  left: 12,
                  top: 10,
                  bottom: 12,
                ),
                child: LineChart(
                  /*today ? mainData() : */ mainData(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      b = true;
                      g = false;
                      c = false;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        b ? Icons.circle : Icons.circle_outlined,
                        size: 13,
                        color: const Color.fromARGB(255, 38, 20, 84),
                      ),
                      const Text('Bolus'),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: () {
                    setState(() {
                      b = false;
                      g = true;
                      c = false;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        g ? Icons.circle : Icons.circle_outlined,
                        size: 13,
                        color: Color.fromARGB(255, 132, 135, 195),
                      ),
                      Text('Glucose Levels'),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                InkWell(
                  onTap: () {
                    setState(() {
                      b = false;
                      g = false;
                      c = true;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        c ? Icons.circle : Icons.circle_outlined,
                        size: 13,
                        color: Color.fromARGB(255, 22, 161, 170),
                      ),
                      Text('Carbs'),
                    ],
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: 20.0,
                top: 10,
              ),
              child: Text(
                "Daily Inputs",
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: 'RudaBlack',
                  color: Color.fromARGB(255, 38, 20, 84),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                bottom: 5,
                left: 20,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.width *
                    15 /
                    (MediaQuery.of(context).size.height * 0.05),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: latestEntry.isNotEmpty ? 4 : 1,
                  itemBuilder: (context, index) {
                    return Row(
                      children: [
                        index == 0
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    widget.changeTab(2);
                                  });
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.3,
                                  //padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 135, 117, 181),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      CircleAvatar(
                                        radius: 25, // Half of your icon size
                                        backgroundColor: Color.fromARGB(
                                            255,
                                            255,
                                            255,
                                            255), // Replace with your desired background color
                                        child: Icon(
                                          Icons.add,
                                          size: 50,
                                          color: Color.fromARGB(
                                              255, 135, 117, 181),
                                        ),
                                      ),
                                      Text(
                                        'Add your logs',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Ruda',
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : index == 1
                                ? Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 156, 232, 237),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        left: 2.0,
                                        right: 2.0,
                                        top: 5,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.08,
                                            child: Image.asset(
                                              'assets/insulin.png',
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01,
                                          ),
                                          Text(
                                            'Bolus Dose',
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.04,
                                              fontFamily: 'Ruda-SemiBold',
                                              color: const Color.fromARGB(
                                                  255, 0, 138, 147),
                                            ),
                                          ),
                                          SizedBox(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.001,
                                          ),
                                          Text(
                                            '${latestEntry['insulinDosage']}',
                                            style: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.065,
                                              fontFamily: 'Ruda-SemiBold',
                                              color: const Color.fromARGB(
                                                  255, 38, 20, 84),
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'units',
                                                  style: TextStyle(
                                                    fontFamily: 'Ruda-SemiBold',
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03,
                                                    color: const Color.fromARGB(
                                                        255, 96, 79, 139),
                                                  ),
                                                ),
                                                Text(
                                                  DateFormat.jm().format(
                                                      DateTime.parse(
                                                          latestEntry['date'])),
                                                  style: TextStyle(
                                                    fontFamily: 'Ruda-SemiBold',
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.03,
                                                    color: const Color.fromARGB(
                                                        255, 96, 79, 139),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : index == 2
                                    ? Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 186, 172, 223),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 2.0,
                                            right: 2.0,
                                            top: 5,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.085,
                                                child: Image.asset(
                                                  'assets/blood.png',
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.01,
                                              ),
                                              Text(
                                                'Blood Sugar',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04,
                                                  fontFamily: 'Ruda-SemiBold',
                                                  color: const Color.fromARGB(
                                                      255, 90, 67, 148),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.001,
                                              ),
                                              Text(
                                                '${latestEntry['glucoseLevel']}',
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.065,
                                                  fontFamily: 'Ruda-SemiBold',
                                                  color: const Color.fromARGB(
                                                      255, 38, 20, 84),
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        latestEntry['unit'] == 0
                                                            ? "mmol/L"
                                                            : "mg/dL",
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Ruda-SemiBold',
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.03,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 96, 79, 139),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        DateFormat.jm().format(
                                                            DateTime.parse(
                                                                latestEntry[
                                                                    'date'])),
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Ruda-SemiBold',
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.03,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 96, 79, 139),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: const Color.fromARGB(
                                              255, 156, 232, 237),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            left: 2.0,
                                            right: 2.0,
                                            top: 5,
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.08,
                                                child: Image.asset(
                                                  'assets/bread.png',
                                                  fit: BoxFit.fitWidth,
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.01,
                                              ),
                                              Text(
                                                'Carbohydrates',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.04,
                                                  fontFamily: 'Ruda-SemiBold',
                                                  color: const Color.fromARGB(
                                                      255, 0, 138, 147),
                                                ),
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.001,
                                              ),
                                              Text(
                                                '${latestEntry['totalCarbs']}',
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.065,
                                                  fontFamily: 'Ruda-SemiBold',
                                                  color: const Color.fromARGB(
                                                      255, 38, 20, 84),
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Flexible(
                                                      child: Text(
                                                        'grams',
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Ruda-SemiBold',
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.03,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 96, 79, 139),
                                                        ),
                                                      ),
                                                    ),
                                                    Flexible(
                                                      child: Text(
                                                        DateFormat.jm().format(
                                                            DateTime.parse(
                                                                latestEntry[
                                                                    'date'])),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily:
                                                              'Ruda-SemiBold',
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.03,
                                                          color: const Color
                                                              .fromARGB(
                                                              255, 96, 79, 139),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            FutureBuilder<List<Map>>(
              future: db.getEntries(1),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Map>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data!.isEmpty) {
                  return Container();
                } else {
                  var reversedData = snapshot.data!.reversed.toList();
                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap:
                            true, // This tells the ListView to size itself to its children's height
                        physics:
                            NeverScrollableScrollPhysics(), // This disables scrolling inside the ListView
                        itemCount: reversedData.length,
                        itemBuilder: (context, index) {
                          Map entry = reversedData[index];
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 20,
                              right: 20,
                              bottom: 5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat.jm()
                                      .format(DateTime.parse(entry['date'])),
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                    fontFamily: 'Ruda',
                                    color:
                                        const Color.fromARGB(255, 38, 20, 84),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.12,
                                      //padding: const EdgeInsets.all(10.0),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color.fromARGB(255, 38, 20, 84),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${entry['insulinDosage']}',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                fontFamily: 'Ruda',
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'units',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.025,
                                                fontFamily: 'Ruda',
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Bolus',
                                      style: TextStyle(
                                        letterSpacing: 0.1,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        fontFamily: 'Ruda',
                                        color: const Color.fromARGB(
                                            255, 38, 20, 84),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.12,
                                      //padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromARGB(
                                            255, 38, 20, 84),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${entry['glucoseLevel']}',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                fontFamily: 'Ruda',
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              latestEntry['unit'] == 0
                                                  ? "mmol/L"
                                                  : "mg/dL",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.025,
                                                fontFamily: 'Ruda',
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Blood Sugar',
                                      style: TextStyle(
                                        letterSpacing: 0.1,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        fontFamily: 'Ruda',
                                        color: const Color.fromARGB(
                                            255, 38, 20, 84),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.12,
                                      //padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromARGB(
                                            255, 38, 20, 84),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${entry['totalCarbs']}',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                fontFamily: 'Ruda',
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'grams',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.025,
                                                fontFamily: 'Ruda',
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Carbohydrates',
                                      style: TextStyle(
                                        letterSpacing: 0.1,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        fontFamily: 'Ruda',
                                        color: const Color.fromARGB(
                                            255, 38, 20, 84),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.12,
                                      //padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromARGB(
                                            255, 38, 20, 84),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              entry['target'] == 2 ? '1' : '0',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                                fontFamily: 'Ruda',
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.08,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.007,
                                              child: const Divider(
                                                color: Colors.white,
                                                thickness: 1,
                                              ),
                                            ),
                                            Text(
                                              entry['target'] == 1 ? '1' : '0',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                                fontFamily: 'Ruda',
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Hypers/Hypos',
                                      style: TextStyle(
                                        letterSpacing: 0.1,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        fontFamily: 'Ruda',
                                        color: const Color.fromARGB(
                                            255, 38, 20, 84),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      // Add more widgets here if needed
                    ],
                  );
                }
              },
            ),
            entriesByDate.isNotEmpty
                ? const Padding(
                    padding: EdgeInsets.only(
                      left: 20.0,
                      top: 10,
                    ),
                    child: Text(
                      "Last Week Entries",
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: 'RudaBlack',
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                : Container(),
            Column(
              children: entriesByDate.entries.map((e) {
                var date = e.key;
                var entries = e.value;
                return Padding(
                  padding: const EdgeInsets.only(
                    top: 8.0,
                    left: 20,
                    right: 20,
                    bottom: 10,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: ExpansionTile(
                        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
                        collapsedBackgroundColor:
                            const Color.fromARGB(255, 38, 20, 84),
                        iconColor: Colors.white,
                        collapsedIconColor: Colors.white,
                        title: Text(
                          DateFormat('EEEE, d MMMM yyyy')
                              .format(DateTime.parse(date)),
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                            fontFamily: 'Ruda',
                            color: const Color.fromARGB(255, 255, 255, 255),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        children: entries.map<Widget>((entry) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat.jm()
                                      .format(DateTime.parse(entry['date'])),
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                            0.04,
                                    fontFamily: 'Ruda',
                                    color: const Color.fromARGB(
                                        255, 255, 255, 255),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.12,
                                      //padding: const EdgeInsets.all(10.0),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${entry['insulinDosage']}',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                fontFamily: 'Ruda',
                                                color: const Color.fromARGB(
                                                    255, 38, 20, 84),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'units',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.025,
                                                fontFamily: 'Ruda',
                                                color: const Color.fromARGB(
                                                    255, 38, 20, 84),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Bolus',
                                      style: TextStyle(
                                        letterSpacing: 0.1,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        fontFamily: 'Ruda',
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.12,
                                      //padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${entry['glucoseLevel']}',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                fontFamily: 'Ruda',
                                                color: const Color.fromARGB(
                                                    255, 38, 20, 84),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              latestEntry['unit'] == 0
                                                  ? "mmol/L"
                                                  : "mg/dL",
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.025,
                                                fontFamily: 'Ruda',
                                                color: const Color.fromARGB(
                                                    255, 38, 20, 84),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Blood Sugar',
                                      style: TextStyle(
                                        letterSpacing: 0.1,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        fontFamily: 'Ruda',
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.12,
                                      //padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              '${entry['totalCarbs']}',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.035,
                                                fontFamily: 'Ruda',
                                                color: const Color.fromARGB(
                                                    255, 38, 20, 84),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              'grams',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.025,
                                                fontFamily: 'Ruda',
                                                color: const Color.fromARGB(
                                                    255, 38, 20, 84),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Carbohydrates',
                                      style: TextStyle(
                                        letterSpacing: 0.1,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        fontFamily: 'Ruda',
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.12,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.12,
                                      //padding: const EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                      ),
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              entry['target'] == 2 ? '1' : '0',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                                fontFamily: 'Ruda',
                                                color: const Color.fromARGB(
                                                    255, 38, 20, 84),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.08,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.007,
                                              child: const Divider(
                                                color: Color.fromARGB(
                                                    255, 38, 20, 84),
                                                thickness: 1,
                                              ),
                                            ),
                                            Text(
                                              entry['target'] == 1 ? '1' : '0',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.03,
                                                fontFamily: 'Ruda',
                                                color: const Color.fromARGB(
                                                    255, 38, 20, 84),
                                                fontWeight: FontWeight.w600,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'Hypers/Hypos',
                                      style: TextStyle(
                                        letterSpacing: 0.1,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                0.025,
                                        fontFamily: 'Ruda',
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 13,
      color: Color.fromARGB(255, 178, 178, 178),
    );
    Widget text;
    if (today) {
      switch (value.toInt()) {
        case 0:
          text = const Text('0', style: style);
          break;

        case 2:
          text = const Text('2', style: style);
          break;

        case 4:
          text = const Text('4', style: style);
          break;

        case 6:
          text = const Text('6', style: style);
          break;

        case 8:
          text = const Text('8', style: style);
          break;
        case 10:
          text = const Text('10', style: style);
          break;

        case 12:
          text = const Text('12', style: style);
          break;

        case 14:
          text = const Text('2', style: style);
          break;

        case 16:
          text = const Text('4', style: style);
          break;
        case 18:
          text = const Text('6', style: style);
          break;

        case 20:
          text = const Text('8', style: style);
          break;
        case 22:
          text = const Text('10', style: style);
          break;

        default:
          text = const Text('', style: style);
          break;
      }
    } else if (monthly) {
      switch (value.toInt()) {
        case 2:
          text = const Text('2', style: style);
          break;

        case 4:
          text = const Text('4', style: style);
          break;

        case 6:
          text = const Text('6', style: style);
          break;

        case 8:
          text = const Text('8', style: style);
          break;
        case 10:
          text = const Text('10', style: style);
          break;

        case 12:
          text = const Text('12', style: style);
          break;

        case 14:
          text = const Text('14', style: style);
          break;

        case 16:
          text = const Text('16', style: style);
          break;
        case 18:
          text = const Text('18', style: style);
          break;

        case 20:
          text = const Text('20', style: style);
          break;
        case 22:
          text = const Text('22', style: style);
          break;
        case 24:
          text = const Text('24', style: style);
          break;
        case 26:
          text = const Text('26', style: style);
          break;

        case 28:
          text = const Text('28', style: style);
          break;
        case 30:
          text = const Text('30', style: style);
          break;

        default:
          text = const Text('', style: style);
          break;
      }
    } else {
      switch (value.toInt()) {
        case 2:
          text = const Text('2', style: style);
          break;

        case 4:
          text = const Text('4', style: style);
          break;

        case 6:
          text = const Text('6', style: style);
          break;

        case 8:
          text = const Text('8', style: style);
          break;
        case 10:
          text = const Text('10', style: style);
          break;

        case 12:
          text = const Text('12', style: style);
          break;

        default:
          text = const Text('', style: style);
          break;
      }
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 13,
      color: Color.fromARGB(255, 178, 178, 178),
    );
    String text;
    if (b) {
      switch (value.toInt()) {
        case 10:
          text = '10';
          break;
        case 20:
          text = '20';
          break;
        case 30:
          text = '30';
          break;
        case 40:
          text = '40';
          break;
        case 50:
          text = '50';
          break;
        case 60:
          text = '60';
          break;
        case 70:
          text = '70';
          break;
        case 80:
          text = '80';
          break;
        case 90:
          text = '90';
          break;
        default:
          return Container();
      }
    } else if (g) {
      switch (value.toInt()) {
        case 100:
          text = '100';
          break;
        case 200:
          text = '200';
          break;
        case 300:
          text = '300';
          break;
        case 400:
          text = '400';
          break;
        case 500:
          text = '500';
          break;
        case 600:
          text = '600';
          break;
        case 700:
          text = '700';
          break;

        default:
          return Container();
      }
    } else {
      switch (value.toInt()) {
        case 50:
          text = '50';
          break;

        case 100:
          text = '100';
          break;

        case 150:
          text = '150';
          break;

        case 200:
          text = '200';
          break;

        case 250:
          text = '250';
          break;

        case 300:
          text = '300';
          break;
        default:
          return Container();
      }
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    return LineChartData(
      clipData: const FlClipData(
        bottom: true, // Clip the bottom side
        top: true, // Clip the top side
        left: true, // Clip the left side
        right: true, // Clip the right side
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: b
            ? 1
            : g
                ? 10
                : 5,
        getDrawingHorizontalLine: (value) {
          //hori grids color
          return const FlLine(
            color: Color.fromARGB(103, 162, 162, 162),
            strokeWidth: 1,
            dashArray: [1, 10],
          );
        },
        getDrawingVerticalLine: (value) {
          //ver grids color
          return const FlLine(
            color: Color.fromARGB(103, 162, 162, 162),
            strokeWidth: 0.5,
            dashArray: [2, 11],
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 25,
            interval: 2,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: b
                ? 10
                : g
                    ? 100
                    : 25,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 25,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(
          color: const Color.fromARGB(103, 162, 162, 162),
        ),
      ),
      minX: 0,
      maxX: today
          ? 24
          : monthly
              ? 31
              : 12,
      minY: 0,
      maxY: b
          ? 90
          : g
              ? 700
              : 300,
      lineBarsData: [
        LineChartBarData(
          spots: (today
                  ? dayentries.map((entry) {
                      return FlSpot(
                        DateTime.parse(entry['date']).hour +
                            DateTime.parse(entry['date']).minute /
                                60.0, // Convert date to double
                        double.parse(entry['insulinDosage'].toString()),
                      );
                    })
                  : monthly
                      ? averageInsulinDosagePerDay.map((entry) {
                          return FlSpot(
                            entry['day'].toDouble(),
                            double.parse(
                                entry['averageInsulinDosage'].toString()),
                          );
                        })
                      : averageInsulinDosagePerMonth.map((entry) {
                          return FlSpot(
                            entry['month'].toDouble(),
                            double.parse(
                                entry['averageInsulinDosage'].toString()),
                          );
                        }))
              .toList(),
          isCurved: true,
          color: const Color.fromARGB(255, 38, 20, 84),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: const Color.fromARGB(255, 38, 20, 84).withOpacity(0.3),
          ),
        ),
        LineChartBarData(
          spots: (today
                  ? dayentries.map((entry) {
                      return FlSpot(
                        DateTime.parse(entry['date']).hour +
                            DateTime.parse(entry['date']).minute /
                                60.0, // Convert date to double
                        double.parse(entry['glucoseLevel'].toString()),
                      );
                    })
                  : monthly
                      ? averageInsulinDosagePerDay.map((entry) {
                          return FlSpot(
                            entry['day'].toDouble(),
                            double.parse(entry['averageGlucose'].toString()),
                          );
                        })
                      : averageInsulinDosagePerMonth.map((entry) {
                          return FlSpot(
                            entry['month'].toDouble(),
                            double.parse(entry['averageGlucose'].toString()),
                          );
                        }))
              .toList(),
          isCurved: true,
          color: const Color.fromARGB(255, 132, 135, 195),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: const Color.fromARGB(255, 132, 135, 195).withOpacity(0.3),
          ),
        ),
        LineChartBarData(
          spots: (today
                  ? dayentries.map((entry) {
                      return FlSpot(
                        DateTime.parse(entry['date']).hour +
                            DateTime.parse(entry['date']).minute /
                                60.0, // Convert date to double
                        double.parse(entry['totalCarbs'].toString()),
                      );
                    })
                  : monthly
                      ? averageInsulinDosagePerDay.map((entry) {
                          return FlSpot(
                            entry['day'].toDouble(),
                            double.parse(entry['averageCarbs'].toString()),
                          );
                        })
                      : averageInsulinDosagePerMonth.map((entry) {
                          return FlSpot(
                            entry['month'].toDouble(),
                            double.parse(entry['averageCarbs'].toString()),
                          );
                        }))
              .toList(),
          isCurved: true,
          color: const Color.fromARGB(255, 22, 161, 170),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            color: const Color.fromARGB(255, 22, 161, 170).withOpacity(0.3),
          ),
        ),
      ],
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
class Articles extends StatefulWidget {
  const Articles({super.key});

  @override
  _ArticlesState createState() => _ArticlesState();
}

class _ArticlesState extends State<Articles> {
  @override
  void initState() {
    super.initState();
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
      body: SingleChildScrollView(
        child: Column(
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
                  const Text(
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
                          String? imageUrl =
                              filteredArticles[index]['thumbnail'];
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
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                          .addFavorite(
                                                              url,
                                                              title,
                                                              imageUrl,
                                                              date);
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
            (articles.isEmpty || starred == null)
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: SizedBox(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
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
          ],
        ),
      ),
    );
  }
}

class AddInput extends StatefulWidget {
  final Function changeTab;
  AddInput({required this.changeTab});

  @override
  _AddInputState createState() => _AddInputState();
}

class _AddInputState extends State<AddInput> {
  //const Settings({Key? key}) : super(key: key);
  void refresh() {
    setState(() {});
  }

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
                                                  glucoseUnit_);
                                              print('Chosen Meals:');
                                              print(chosenMeals);
                                              print('Total Carbs:');
                                              print(calculateTotalCarbs(
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

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  XFile? _selectedImage;
  bool acc = false;
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _pnController = TextEditingController();

  void _pickImage(StateSetter setState) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = (await _picker.pickImage(source: ImageSource.gallery));

    setState(() {
      _selectedImage = image;
    });
  }

  List fav = [];
  void favorites() {
    for (int i = 0; i < articles.length; i++) {
      if (starred![i]) {
        fav.add(articles[i]);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    favorites();
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        SizedBox(
                          width: min(MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height) *
                              0.5,
                          height: min(MediaQuery.of(context).size.width,
                                  MediaQuery.of(context).size.height) *
                              0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: (_selectedImage != null && acc == true)
                                ? Image.file(
                                    File(_selectedImage!.path),
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color:
                                        const Color.fromARGB(255, 45, 170, 178),
                                    child: Center(
                                      child: Text(
                                        //textAlign: TextAlign.center,
                                        firstName_[0].toUpperCase(),
                                        style: TextStyle(
                                          fontSize: min(
                                                  MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height) *
                                              0.2,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        /*Positioned(
                          right: 0,
                          bottom: 20,
                          child: InkWell(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 38, 20, 84),
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(15),
                                  topRight: Radius.circular(15),
                                  bottomLeft: Radius.circular(7),
                                  bottomRight: Radius.circular(15),
                                ),
                              ),
                              child: const Icon(
                                Icons.edit,
                                size: 20,
                                color: Color.fromARGB(255, 255, 255, 255),
                              ),
                            ),
                          ),
                        ),
                      */
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      username_,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.05,
                        color: const Color.fromARGB(255, 28, 42, 58),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    phoneNumber_.isNotEmpty
                        ? Text(
                            phoneNumber_,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.045,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Container(
                          height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                            color: Color.fromARGB(255, 255, 249,
                                254), // Set the desired color here
                            borderRadius: BorderRadius
                                .zero, // This removes the round edges
                          ),
                          child: Column(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                color: const Color.fromARGB(255, 38, 20, 84),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 25.0,
                                    ),
                                    child: Text(
                                      'Edit Profile',
                                      style: TextStyle(
                                        fontSize: min(
                                                MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                MediaQuery.of(context)
                                                    .size
                                                    .height) *
                                            0.05,
                                        color: Colors.white,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SingleChildScrollView(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.height *
                                        0.025,
                                    left: 20,
                                    right: 20,
                                  ),
                                  child: Column(
                                    children: [
                                      Center(
                                        child: Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () => _pickImage(setState),
                                              child: Stack(
                                                children: [
                                                  SizedBox(
                                                    width: min(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height) *
                                                        0.5,
                                                    height: min(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height) *
                                                        0.5,
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              100),
                                                      child: _selectedImage !=
                                                              null
                                                          ? Image.file(
                                                              File(
                                                                  _selectedImage!
                                                                      .path),
                                                              width: 200,
                                                              height: 200,
                                                              fit: BoxFit.cover,
                                                            )
                                                          : Container(
                                                              color: const Color
                                                                  .fromARGB(255,
                                                                  45, 170, 178),
                                                              child: Center(
                                                                child: Text(
                                                                  //textAlign: TextAlign.center,
                                                                  firstName_[0]
                                                                      .toUpperCase(),
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: min(
                                                                            MediaQuery.of(context).size.width,
                                                                            MediaQuery.of(context).size.height) *
                                                                        0.2,
                                                                    color: Colors
                                                                        .white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    right: 0,
                                                    bottom: 20,
                                                    child: InkWell(
                                                      onTap: () =>
                                                          _pickImage(setState),
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(5),
                                                        decoration:
                                                            const BoxDecoration(
                                                          color: Color.fromARGB(
                                                              255, 38, 20, 84),
                                                          shape: BoxShape
                                                              .rectangle,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                            topLeft:
                                                                Radius.circular(
                                                                    15),
                                                            topRight:
                                                                Radius.circular(
                                                                    15),
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    7),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    15),
                                                          ),
                                                        ),
                                                        child: const Icon(
                                                          Icons.edit,
                                                          size: 20,
                                                          color: Color.fromARGB(
                                                              255,
                                                              255,
                                                              255,
                                                              255),
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
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.02,
                                      ),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 38, 20, 84),
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _userController,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: const TextStyle(
                                            color:
                                                Color.fromARGB(255, 38, 20, 84),
                                            fontSize: 15,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                          decoration: InputDecoration(
                                            //labelText: 'UserName',
                                            hintText: username_,
                                            labelStyle: const TextStyle(
                                              color: Color.fromARGB(
                                                  189, 38, 20, 84),
                                              fontSize: 15,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.person_2_outlined,
                                              color: Color.fromARGB(
                                                  255, 38, 20, 84),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          //onEditingComplete: () => _focusNodePassword.requestFocus(),
                                          //validator: (String? value) {
                                          //  if (value == null || value.isEmpty) {
                                          //    return 'Please enter your email';
                                          //  } else if (!_boxAccounts.containsKey(value)) {
                                          //    return 'Email not found';
                                          //  }
                                          //  return null;
                                          //},
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color.fromARGB(
                                                255, 38, 20, 84),
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(15),
                                            bottomLeft: Radius.circular(15),
                                            topRight: Radius.circular(15),
                                            bottomRight: Radius.circular(15),
                                          ),
                                        ),
                                        child: TextFormField(
                                          controller: _controllerEmail,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          style: const TextStyle(
                                            color:
                                                Color.fromARGB(255, 38, 20, 84),
                                            fontSize: 15,
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w600,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: email_,
                                            labelStyle: const TextStyle(
                                              color: Color.fromARGB(
                                                  189, 38, 20, 84),
                                              fontSize: 15,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w600,
                                            ),
                                            prefixIcon: const Icon(
                                              Icons.email_outlined,
                                              color: Color.fromARGB(
                                                  255, 38, 20, 84),
                                            ),
                                            border: InputBorder.none,
                                          ),
                                          validator: (String? value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return "Please enter email.";
                                            } else if (!(value.contains('@') &&
                                                value.contains('.'))) {
                                              return "Invalid email";
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.07,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: const Color.fromARGB(
                                                      255, 38, 20, 84),
                                                ),
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  bottomLeft:
                                                      Radius.circular(15),
                                                ),
                                              ),
                                              child: TextFormField(
                                                controller: _pnController,
                                                keyboardType:
                                                    TextInputType.phone,
                                                style: const TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 38, 20, 84),
                                                  fontSize: 15,
                                                  fontFamily: 'Inter',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                decoration: InputDecoration(
                                                  hintText: phoneNumber_,
                                                  labelStyle: const TextStyle(
                                                    color: Color.fromARGB(
                                                        189, 38, 20, 84),
                                                    fontSize: 15,
                                                    fontFamily: 'Poppins',
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  prefixIcon: const Icon(
                                                    Icons.phone_android,
                                                    color: Color.fromARGB(
                                                        255, 38, 20, 84),
                                                  ),
                                                  border: InputBorder.none,
                                                ),
                                                validator: (String? value) {
                                                  if (value == null ||
                                                      value.isEmpty) {
                                                    return "Please enter email.";
                                                  } else if (!(value
                                                          .contains('@') &&
                                                      value.contains('.'))) {
                                                    return "Invalid email";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.07,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: const Color.fromARGB(
                                                    255, 38, 20, 84),
                                              ),
                                              borderRadius:
                                                  const BorderRadius.only(
                                                topRight: Radius.circular(15),
                                                bottomRight:
                                                    Radius.circular(15),
                                              ),
                                            ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                children: [
                                                  const Text('+961'),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.07,
                                                    child: Image.asset(
                                                      'assets/lebanon.png',
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "Change Password",
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 116, 116, 116),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color.fromARGB(
                                                    255, 38, 20, 84),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10), // Change this value as needed
                                            ),
                                          ),
                                          child: const Text(
                                            'Accept',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                255,
                                                255,
                                                249,
                                                254,
                                              ),
                                              fontSize: 20,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              acc = true;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.06,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            //primary: Color.fromARGB(255, 255, 255, 255), // background color
                                            side: const BorderSide(
                                              color: Color.fromARGB(
                                                  255, 38, 20, 84),
                                              width: 1,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  10), // Change this value as needed
                                            ),
                                          ),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: Color.fromARGB(
                                                  255, 38, 20, 84),
                                              fontSize: 20,
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      });
                    },
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.manage_accounts_outlined,
                            size: MediaQuery.of(context).size.width * 0.085,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),
                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.045,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: MediaQuery.of(context).size.width * 0.04,
                        color: const Color.fromARGB(255, 84, 95, 107),
                      ), // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () async {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Scaffold(
                          body: Container(
                            height: MediaQuery.of(context).size.height,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 249,
                                  254), // Set the desired color here
                              borderRadius: BorderRadius
                                  .zero, // This removes the round edges
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.09,
                                  color: const Color.fromARGB(255, 38, 20, 84),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 25.0,
                                        ),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.04,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shadowColor: Colors.transparent,
                                              backgroundColor:
                                                  Colors.transparent,
                                              foregroundColor:
                                                  Colors.transparent,
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              // background color
                                              side: const BorderSide(
                                                color: Color.fromARGB(
                                                    255, 38, 20, 84),
                                                width: 1,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    10), // Change this value as needed
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.arrow_back_ios_rounded,
                                                  color: const Color.fromARGB(
                                                      255, 255, 249, 254),
                                                  size: min(
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height) *
                                                      0.035,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'Profile',
                                                  style: TextStyle(
                                                    fontSize: min(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height) *
                                                        0.035,
                                                    color: Colors.white,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 25.0,
                                          ),
                                          child: Text(
                                            'Favorites',
                                            style: TextStyle(
                                              fontSize: min(
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height) *
                                                  0.05,
                                              color: Colors.white,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.025,
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: Column(
                                      children: [
                                        (fav.isEmpty || starred == null)
                                            ? Center(
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.4,
                                                    ),
                                                    const Text(
                                                      'You have no saved articles',
                                                    ),
                                                  ],
                                                ),
                                              )
                                            : Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 5.0),
                                                child: SizedBox(
                                                  child: ListView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    itemCount: fav.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      String? imageUrl =
                                                          articles[index]
                                                              ['thumbnail'];
                                                      String title =
                                                          articles[index]
                                                              ['title'];
                                                      String url =
                                                          articles[index]
                                                              ['link'];
                                                      String? date =
                                                          articles[index]
                                                              ['date'];

                                                      return SizedBox(
                                                        height: imageUrl != null
                                                            ? MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.13
                                                            : null,
                                                        child: InkWell(
                                                          onTap: () =>
                                                              launch(url),
                                                          child: Card(
                                                            color: Colors
                                                                .transparent,
                                                            shadowColor: Colors
                                                                .transparent,
                                                            surfaceTintColor:
                                                                Colors
                                                                    .transparent,
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                //bottom: 5.0,
                                                                left: 10,
                                                                right: 10,
                                                              ),
                                                              child: Row(
                                                                children: [
                                                                  imageUrl !=
                                                                          null
                                                                      ? ClipRRect(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10.0),
                                                                          child:
                                                                              Image.network(
                                                                            imageUrl,
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.25,
                                                                            height:
                                                                                120, // Adjust the height as needed
                                                                            fit:
                                                                                BoxFit.cover,
                                                                          ),
                                                                        )
                                                                      : Container(),
                                                                  const SizedBox(
                                                                      width:
                                                                          10), // Add some spacing
                                                                  Expanded(
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          title,
                                                                          maxLines:
                                                                              3,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          style:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                16,
                                                                            fontFamily:
                                                                                'InriaSerif',
                                                                            color: Color.fromARGB(
                                                                                255,
                                                                                38,
                                                                                20,
                                                                                84),
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                        if (date !=
                                                                            null)
                                                                          SizedBox(
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                const Icon(
                                                                                  Icons.access_time,
                                                                                  size: 17,
                                                                                  color: Color.fromARGB(255, 106, 106, 106),
                                                                                ),
                                                                                const SizedBox(
                                                                                  width: 7,
                                                                                ),
                                                                                Text(
                                                                                  date,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: const TextStyle(
                                                                                    color: Color.fromARGB(255, 106, 106, 106),
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
                                                                      starred![
                                                                              index]
                                                                          ? Icons
                                                                              .bookmark
                                                                          : Icons
                                                                              .bookmark_border,
                                                                      color: starred![
                                                                              index]
                                                                          ? const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              49,
                                                                              205,
                                                                              215)
                                                                          : const Color
                                                                              .fromARGB(
                                                                              255,
                                                                              49,
                                                                              205,
                                                                              215),
                                                                      size: 25,
                                                                    ),
                                                                    onPressed:
                                                                        () async {
                                                                      logger.info(
                                                                          "clicked");
                                                                      DBHelper
                                                                          dbHelper =
                                                                          DBHelper
                                                                              .instance;
                                                                      var response;
                                                                      if (starred![
                                                                          index]) {
                                                                        response =
                                                                            await dbHelper.deleteFavorite(url);
                                                                        logger.info(
                                                                            response);
                                                                      } else {
                                                                        response = await dbHelper.addFavorite(
                                                                            url,
                                                                            title,
                                                                            imageUrl,
                                                                            date);
                                                                      }
                                                                      logger.info(
                                                                          response);
                                                                      setState(
                                                                        () {
                                                                          starred![index] =
                                                                              !starred![index];
                                                                          if (!starred![
                                                                              index]) {
                                                                            fav.removeAt(index);
                                                                          }
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
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bookmark_outline_rounded,
                            size: MediaQuery.of(context).size.width * 0.085,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),
                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'Favorites',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.045,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: MediaQuery.of(context).size.width * 0.04,
                        color: const Color.fromARGB(255, 84, 95, 107),
                      ), // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Membership(
                        username: username_,
                        index: 1,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.token_outlined,
                            size: MediaQuery.of(context).size.width * 0.085,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),

                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'Subscriptions',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.045,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: MediaQuery.of(context).size.width * 0.04,
                        color: const Color.fromARGB(255, 84, 95, 107),
                      ), // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: Stack(
                          //mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Colors.transparent,
                                    Colors.white
                                  ],
                                  stops: <double>[0.75, 0.85],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstOut,
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 30,
                                    right: 30,
                                    top: 20,
                                    bottom: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'AGREEMENT',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Color.fromARGB(
                                              255, 173, 173, 173),
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const Text(
                                        'Terms of Service',
                                        style: TextStyle(
                                          fontSize: 32.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20.0),
                                      const Text(
                                        '1. OUR SERVICES',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'The information provided when using the Services is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation or which would subject us to any registration requirement within such jurisdiction or country. Accordingly, those persons who choose to access the Services from other locations do so on their own initiative and are solely responsible for compliance with local laws, if and to the extent local laws are applicable.',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      const SizedBox(height: 10.0),
                                      const Text(
                                        '2. Use License',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Subject to your compliance with these Legal Terms, including the "PROHIBITED ACTIVITIES" section below, we grant you a non-exclusive, non-transferable, revocable license to: access the Services; and download or print a copy of any portion of the Content to which you have properly gained access. solely for your personal, non-commercial use or internal business purpose. Except as set out in this section or elsewhere in our Legal Terms, no part of the Services and no Content or Marks may be copied, reproduced, aggregated, ',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 40,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    /*SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.4,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              side: const BorderSide(
                                                color: Color.fromARGB(
                                                  255,
                                                  49,
                                                  205,
                                                  215,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              49,
                                              205,
                                              215,
                                            ),
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                    */
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            49,
                                            205,
                                            215,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Change this value as needed
                                          ),
                                        ),
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              255,
                                              249,
                                              254,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.policy_outlined,
                            size: MediaQuery.of(context).size.width * 0.085,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),

                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.045,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  // Handle your tap event here...
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: MediaQuery.of(context).size.width * 0.085,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),

                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'User Manual',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.045,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  // Handle your tap event here...
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: MediaQuery.of(context).size.width * 0.085,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),

                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'Help and Support',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.045,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  // Handle your tap event here...
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: MediaQuery.of(context).size.width * 0.085,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.045,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      // This is the right icon
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Widget settingItem(String title, String value, VoidCallback onTap) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              color: Color.fromARGB(255, 38, 20, 84),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.right, // Align text to the right
                ),
              ),
              Align(
                alignment: Alignment.centerRight, // Align icon to the right
                child: IconButton(
                  icon: const Icon(Icons.edit,
                      color: Color.fromARGB(255, 22, 161, 170)),
                  onPressed: onTap,
                ),
              ),
            ],
          ),
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

  Widget carbRatioInputDialog(
      String title, double initialCarbs, double initialInsulin) {
    TextEditingController carbsController =
        TextEditingController(text: initialCarbs.toStringAsFixed(2));
    TextEditingController insulinController =
        TextEditingController(text: initialInsulin.toStringAsFixed(2));

    return AlertDialog(
      title: Text(title),
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
            Navigator.of(context).pop({
              'carbs': double.parse(carbsController.text),
              'insulin': double.parse(insulinController.text),
            });
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Widget numberInputDialog(String title, double initialValue) {
    TextEditingController controller =
        TextEditingController(text: initialValue.toStringAsFixed(2));
    return AlertDialog(
      title: Text(title),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                settingItem('Carb Ratio:',
                    "${carbUnit_ == 0 ? (carbs_).toString() : (carbs_ / 15).toString()}/$insulin_",
                    () async {
                  Map<String, double>? newCarbRatio =
                      await showDialog<Map<String, double>>(
                    context: context,
                    builder: (context) => carbRatioInputDialog(
                        'Enter new carb ratio',
                        carbUnit_ == 0 ? carbs_ : carbs_ / 15,
                        insulin_),
                  );
                  if (newCarbRatio != null) {
                    setState(() {
                      carbs_ = carbUnit_ == 0
                          ? newCarbRatio['carbs']!
                          : newCarbRatio['carbs']! * 15;
                      insulin_ = newCarbRatio['insulin']!;
                      carbRatio_ = insulin_ /
                          (carbUnit_ == 0
                              ? carbs_ / 15
                              : newCarbRatio['carbs']!);
                      saveValues();
                    });
                  }
                }),
                const SizedBox(height: 20),
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
