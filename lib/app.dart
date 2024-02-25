import 'package:flutter/material.dart';

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
        title: const Text('Home'),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: const Center(
        child: Text('Home!'), // Replace with your desired text
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
        title: const Text('Settings'),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: const Center(
        child: Text('Setting!'), // Replace with your desired text
      ),
    );
  }
}

class AddInput extends StatelessWidget {
  //const Settings({Key? key}) : super(key: key);
  final TextEditingController _GlucoseController = TextEditingController();
  final TextEditingController _CarbController = TextEditingController();

  void calculateBolus() {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Add Input'),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: Form(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            color: Color.fromARGB(255, 38, 20, 84),
                            fontSize: 20,
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
                    height: 20,
                  ),
                  Container(
                    color: const Color.fromARGB(255, 232, 232, 232),
                    child: const SizedBox(
                      //height: 100,
                      width: 400,

                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 20,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                'Total Bolus',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                'CALCULATIONS',
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 116, 97, 164),
                                    fontWeight: FontWeight.w500),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 110,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                "0",
                                style: TextStyle(
                                    fontSize: 40,
                                    fontFamily: "Inter",
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Column(
                            children: [
                              SizedBox(
                                height: 39,
                              ),
                              Text(
                                "units",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: "Inter",
                                    color: Color.fromARGB(255, 0, 0, 0),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    //crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      const Text(
                        'Glucose',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(
                        width: 90,
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 7,
                        height: 40,
                        child: TextFormField(
                          controller: _GlucoseController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: '0',
                            labelStyle: TextStyle(
                              color: Color.fromARGB(188, 0, 0, 0),
                              fontSize: 20,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.black, // Specify your color here
                                width: 100, // Specify your width here
                              ),
                            ),
                          ),
                        ),
                      ),
                      /*const Text(
                        "mg/dL",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color.fromARGB(255, 116, 97, 164),
                            fontWeight: FontWeight.w500),
                      ),*/
                    ],
                  ),
                ],
              ),
            ),
          ],
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
        title: const Text('Articles'),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: const Center(
        child: Text('Articles!'), // Replace with your desired text
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
        title: const Text('Profile'),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: const Center(
        child: Text('Profile!'), // Replace with your desired text
      ),
    );
  }
}
