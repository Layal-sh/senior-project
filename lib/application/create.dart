// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugar_sense/AI/ai_functions.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/application/meals.dart';
import 'package:sugar_sense/main.dart';

class CreateMeal extends StatefulWidget {
  const CreateMeal({super.key});

  @override
  State<CreateMeal> createState() => _CreateMealState();
}

Timer? _timer;

class _CreateMealState extends State<CreateMeal> {
  void refresh() {
    setState(() {});
  }

  double totalCCarbs = 0;
  XFile? _selectedImage;
  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = (await _picker.pickImage(source: ImageSource.gallery));

    setState(() {
      _selectedImage = image;
    });
  }

  final _nameController = TextEditingController();
  final gramsController = TextEditingController();
  DBHelper dbHelper = DBHelper.instance;
  List<Map> allMeals = [];
  List<int> selectedMeals = [];
  List<String> categories = [
    'Drinks',
    'Sweets & snacks',
    'Pastries',
    'Dairy products',
    'Fruits',
    'Lebanese dishes',
    'Arabic desserts',
    'Grains, pasta & rice',
    'Breakfast',
    'Lunch',
    'Dinner'
  ];

  List<String> selectedCategories = [];
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
  void initState() {
    super.initState();
    loadMeals();
    TotalCCarbs();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {});
      }
    });
  }

  void loadMeals() async {
    allMeals = await dbHelper.selectAllMeals();
    setState(() {});
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameController.dispose();
    chosenCMeals.clear();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 38, 20, 84), // Set status bar color
      ));
    });
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                color: const Color.fromARGB(255, 38, 20, 84),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 10.0,
                    right: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        backgroundColor: Color.fromARGB(0, 0, 236, 253),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 30,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            _timer?.cancel();
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8.0,
                          bottom: 8,
                          left: 5,
                          right: 5,
                        ),
                        child: TextButton(
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 45, 170, 178),
                            //padding: const EdgeInsets.all(16),
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                          ),
                          onPressed: () async {
                            ///////////////////////////////////////////////////////////////////////
                            DBHelper dbHelper = DBHelper.instance;
                            String image = "";
                            if (_selectedImage == null) {
                              image = "All.png";
                            } else {
                              image = _selectedImage!.path;
                            }
                            int createdMeal = await dbHelper.createMeal(
                                _nameController.text,
                                image,
                                chosenCMeals,
                                selectedCategories,
                                chosenCMeals.isEmpty
                                    ? double.parse(gramsController.text)
                                    : totalCCarbs);
                            print("Created Meal: $createdMeal");
                            if (createdMeal == -1) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return const AlertDialog(
                                    content: Text('Meal Name Already Exists!'),
                                  );
                                },
                              );
                            } else {
                              Navigator.pop(context);
                              Navigator.pop(context);

                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      const Meals(Index: 0),
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    );
                                  },
                                ),
                              );
                              selectedCategory = 'mymeals';
                            }
                          },
                          child: const Text(
                            'Create',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Your body content
              ),
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    SizedBox(
                      width: 175,
                      height: 175,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: _selectedImage != null
                            ? Image.file(
                                File(_selectedImage!.path),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color.fromARGB(255, 211, 211, 211),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 50,
                                  color: Colors.grey[800],
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 7,
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
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                color: const Color.fromARGB(255, 231, 231, 231),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Name: ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontSize: 17,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 38, 20, 84),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 38, 20, 84),
                            width: 1.5,
                          ),
                        ),
                        hintText: 'Enter meal name',
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      'Choose categories: ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontSize: 17,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Wrap(
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 5,
                      children: [
                        for (var category in categories)
                          ChoiceChip(
                            label: Opacity(
                              opacity: selectedCategories.contains(category)
                                  ? 1.0
                                  : 0.5, // Adjust the opacity based on whether the category is selected
                              child: Text(category),
                            ),
                            selected: selectedCategories.contains(category),
                            selectedColor:
                                const Color.fromARGB(255, 51, 184, 194),
                            backgroundColor:
                                const Color.fromARGB(126, 158, 158, 158),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                color: selectedCategories.contains(category)
                                    ? const Color.fromARGB(255, 45, 170, 178)
                                    : const Color.fromARGB(126, 158, 158,
                                        158), // Adjust the border color based on whether the category is selected
                              ),
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            onSelected: (bool selected) {
                              setState(() {
                                if (selected) {
                                  selectedCategories.add(category);
                                } else {
                                  selectedCategories.remove(category);
                                }
                              });
                            },
                          ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Carbs: ',
                          style: TextStyle(
                            color: Color.fromARGB(255, 38, 20, 84),
                            fontSize: 17,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                chosenCMeals.isEmpty
                                    ? SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.15,
                                        child: TextFormField(
                                          controller: gramsController,
                                          textAlign: TextAlign.center,
                                          keyboardType: const TextInputType
                                              .numberWithOptions(decimal: true),
                                          decoration: const InputDecoration(
                                            hintText: '0.0',
                                            hintStyle: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            color:
                                                Color.fromARGB(255, 38, 20, 84),
                                          ),
                                          validator: (value) {
                                            /*if (value.isEmpty) {
                                        return 'Please enter a number';
                                      }
                                      return null;*/
                                          },
                                        ),
                                      )
                                    : !showTotalCarbs
                                        ? ElevatedButton(
                                            onPressed: () {
                                              _timer?.cancel();
                                              totalCCarbs = calculateTotalCarbs(
                                                  chosenCMeals);
                                              setState(
                                                () {
                                                  showTotalCarbs = true;
                                                },
                                              );
                                            },
                                            child: const Text('Calculate'),
                                          )
                                        : Text(
                                            '$totalCCarbs',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              color: Color.fromARGB(
                                                  255, 38, 20, 84),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const Text(
                                  'grams',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 38, 20, 84),
                                    fontSize: 17,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                var result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Meals(Index: 1)),
                                );
                                if (result == 'refresh') {
                                  refresh();
                                }
                                _timer = Timer.periodic(Duration(seconds: 1),
                                    (timer) {
                                  if (mounted) {
                                    // Check if the widget is still in the tree
                                    setState(() {});
                                  }
                                });
                                setState(() {
                                  showTotalCarbs = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                shape:
                                    CircleBorder(), // Make the button circular
                                padding: EdgeInsets.all(
                                    15), // Adjust the size of the button
                              ),
                              child: Image.asset(
                                'assets/AddDish.png',
                                height: 32,
                                width: 32,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.9,
                      child: Wrap(
                        direction: Axis.horizontal,
                        alignment: chosenCMeals.isEmpty
                            ? WrapAlignment.center
                            : WrapAlignment.start,
                        spacing: 10,
                        children: <Widget>[
                          for (var meal in chosenCMeals)
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
                                      totalCCarbs =
                                          calculateTotalCarbs(chosenCMeals) -
                                              (meal["carbohydrates"] *
                                                  meal['quantity']);
                                      setState(() {
                                        chosenCMeals.remove(meal);

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
