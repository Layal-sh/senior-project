import 'package:flutter/material.dart';
import 'package:sugar_sense/application/meals.dart';
import 'package:sugar_sense/AI/ai_functions.dart';

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
        title: const Text(
          'Home',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 249, 254),
            fontSize: 17,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
          ),
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
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 249, 254),
            fontSize: 17,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
          ),
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
  double bolusCalculation = 0.0;
  final TextEditingController _GlucoseController = TextEditingController();
  final TextEditingController _CarbController = TextEditingController();
  String? carbRatioSelected;
  ValueNotifier<double> glucoseLevelNotifier = ValueNotifier<double>(0.0);
  ValueNotifier<double> carbsTotalNotifier = ValueNotifier<double>(0.0);

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
                            print(double.parse(_GlucoseController.text));
                            double glucoseLevel =
                                double.parse(_GlucoseController.text);
                            print(glucoseLevel.runtimeType);
                            if (getChosenMeals().isNotEmpty &&
                                _GlucoseController.text.isNotEmpty) {
                              bolusCalculation = calculateDosage(
                                  getChosenMeals(), glucoseLevel);
                              print(bolusCalculation);
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
                      child: const SizedBox(
                        //height: 100,
                        width: double.infinity,

                        child: Padding(
                          padding: EdgeInsets.only(
                              left: 20.0, top: 10, bottom: 10, right: 30.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
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
                                      Text(
                                        "0",
                                        style: TextStyle(
                                          fontSize: 35,
                                          fontFamily: "Inter",
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 20,
                                  ),
                                  Column(
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
                                  keyboardType: TextInputType.number,
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

class Articles extends StatelessWidget {
  //const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Articles',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 249, 254),
            fontSize: 17,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: const SingleChildScrollView(
        child: Center(
          child: Text('Articles!'), // Replace with your desired text
        ),
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
        title: const Text(
          'Profile',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 249, 254),
            fontSize: 17,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
          ),
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
