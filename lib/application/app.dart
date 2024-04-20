import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/application/addInput.dart';
import 'package:sugar_sense/application/articles.dart';
import 'package:sugar_sense/application/dashboard.dart';
import 'package:sugar_sense/application/meals/meals.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sugar_sense/application/profile.dart';
import 'package:sugar_sense/application/settings.dart';
import 'package:sugar_sense/login/signup/signup.dart';
import 'package:sugar_sense/main.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

Timer? _timer;
var selectedIndex = 0;
/*List articles = [];
List<bool>? starred;
late List filteredArticles;
late List restArticles;
late List finalList;*/

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
        //username_ = username;
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
      //email_ = email;
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
      //phoneNumber_ = phone;
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
  /*void fetchArticles() async {
    List<String> searches = [
      // 'diabetes type 1',
      // 'diabetes lifestyle',
      // 'diabetes article',
      // 'diabetes insulin'
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
    //logger.info(articles);
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
*/
  @override
  void initState() {
    super.initState();
    TotalCarbs();
    selectedIndex = 0;
    /*filteredArticles = [];
    restArticles = [];
    finalList = [];
    starred = [];
    fetchArticles();*/
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
