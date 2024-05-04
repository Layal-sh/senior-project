// ignore_for_file: unused_local_variable, library_private_types_in_public_api

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/main.dart';
import 'package:http/http.dart' as http;

class Dashboard extends StatefulWidget {
  final Function changeTab;
  const Dashboard({super.key, required this.changeTab});

  @override
  _DashboardState createState() => _DashboardState();
}

DBHelper db = DBHelper.instance;

class _DashboardState extends State<Dashboard> {
  bool today = true;
  bool monthly = false;
  bool yearly = false;
  bool b = true;
  bool g = false;
  bool c = false;
  Map<String, dynamic> latestEntry = {};
  List<Map> entries = [];
  List<Map> dayentries = []; //why not working?????
  List<Map> monthentries = [];
  List<Map> yearentries = [];
  List<Map> averageInsulinDosagePerDay = [];
  List<Map> averageInsulinDosagePerMonth = [];
  void calculateAverageInsulinDosage() {
    var groupedEntries = groupBy(monthentries, (entry) {
      return DateTime.parse(entry['entryDate']).day;
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
      return DateTime.parse(entry['entryDate']).day;
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

//this is used for deleting entries from the server database
  Future<void> saveStringList(List<String> stringList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('DeleteEntryList', stringList);
  }

  Future<void> addToDeleteEntryList(String newItem) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? stringList = prefs.getStringList('deleteEntryList');
    if (stringList == null) {
      stringList = [
        newItem
      ]; // if the list does not exist, initialize it with the new item
    } else {
      stringList.add(newItem); // if the list exists, add the new item to it
    }
    await prefs.setStringList('deleteEntryList', stringList);
  }

  int patientId = pid_;

  deleteEntry(int id) async {
    DBHelper dbHelper = DBHelper.instance;
    await dbHelper.deleteEntryById(id);
    if (await isConnectedToWifi()) {
      final response = await http
          .get(Uri.parse("http://$localhost:8000/deleteEntry/$id/$patientId"));
    } else {
      addToDeleteEntryList(id.toString());
    }
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

  bool clicked = false;
  loadLatestEntry() async {
    var entry = await db.getLatestEntry();
    setState(() {
      latestEntry = entry;
    });
  }

  Future<void> refreshData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map>> entriesByDate = {};
    for (var entry in entries) {
      String date =
          DateFormat('yyyy-MM-dd').format(DateTime.parse(entry['entryDate']));
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
                        '3 Months',
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
                child: yearly
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: 2000,
                          child: LineChart(
                            mainData(),
                          ),
                        ),
                      )
                    : LineChart(
                        mainData(),
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
                        color: const Color.fromARGB(255, 132, 135, 195),
                      ),
                      const Text('Glucose Levels'),
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
                        color: const Color.fromARGB(255, 22, 161, 170),
                      ),
                      const Text('Carbs'),
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
                                                          latestEntry[
                                                              'entryDate'])),
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
                                                        glucoseUnit_ == 0
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
                                                                    'entryDate'])),
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
                                                                    'entryDate'])),
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
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data!.isEmpty) {
                  return Container();
                } else {
                  var reversedData =
                      snapshot.data!.reversed.toList(); //WAHT IS THAT???????

                  return Column(
                    children: [
                      ListView.builder(
                        shrinkWrap:
                            true, // This tells the ListView to size itself to its children's height
                        physics:
                            const NeverScrollableScrollPhysics(), // This disables scrolling inside the ListView
                        itemCount: reversedData.length,
                        itemBuilder: (context, index) {
                          Map entry = reversedData[index];
                          DateTime entryDate =
                              DateTime.parse(entry['entryDate']);
                          DateTime twoHoursAgo =
                              DateTime.now().subtract(const Duration(hours: 2));
                          return Padding(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 20,
                              right: 5,
                              bottom: 5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat.jm().format(
                                      DateTime.parse(entry['entryDate'])),
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
                                if (entryDate.isAfter(twoHoursAgo))
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Color.fromARGB(255, 25, 167, 177),
                                    ),
                                    onPressed: () async {
                                      // await db
                                      //     .deleteEntryById(entry['entryId']);

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Confirm Delete'),
                                            content: const Text(
                                                'Are you sure you want to delete this entry?'),
                                            actions: <Widget>[
                                              TextButton(
                                                child: const Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                              TextButton(
                                                child: const Text('Delete'),
                                                onPressed: () {
                                                  deleteEntry(entry['entryId']);
                                                  refreshData();
                                                  setState(() {
                                                    clicked = true;
                                                    widget.changeTab(2);
                                                    Navigator.of(context).pop();
                                                  });
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
                                  DateFormat.jm().format(
                                      DateTime.parse(entry['entryDate'])),
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
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
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
      if (value >= 1 && value <= 92) {
        text = Text(value.toInt().toString(), style: style);
      } else {
        text = const Text('', style: style);
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
            interval: yearly ? 1 : 2,
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
              : 93,
      minY: 0,
      maxY: b
          ? 91
          : g
              ? 710
              : 310,
      lineBarsData: [
        LineChartBarData(
          spots: (today
                  ? dayentries.map((entry) {
                      return FlSpot(
                        DateTime.parse(entry['entryDate']).hour +
                            DateTime.parse(entry['entryDate']).minute /
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
                        DateTime.parse(entry['entryDate']).hour +
                            DateTime.parse(entry['entryDate']).minute /
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
                        DateTime.parse(entry['entryDate']).hour +
                            DateTime.parse(entry['entryDate']).minute /
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
