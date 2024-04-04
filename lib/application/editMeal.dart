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

class EditMeal extends StatefulWidget {
  final Meal meal;
  const EditMeal({required this.meal});

  @override
  State<EditMeal> createState() => _EditMealState();
}

DBHelper db = DBHelper.instance;

class _EditMealState extends State<EditMeal> {
  String? _selectedImagePath;
  final TextEditingController _nameController = TextEditingController();
  late Future<List<eIngredient>> ingredients;
  Future<List<eIngredient>> efetchIngredients() async {
    List<Map> response =
        await db.getIngredients(widget.meal.id); // Call getIngredients

    // Convert the response into a list of Ingredient objects
    List<eIngredient> ingredients = response
        .map((item) {
          return eIngredient(
            name: item['mealName'],
            unit: item['unit'],
            quantity: item['quantity'],
          );
        })
        .whereType<eIngredient>()
        .toList();
    return ingredients;
  }

  List<double> globalControllers = [];
  @override
  void initState() {
    super.initState();
    loadCategories();
    _selectedImagePath = widget.meal.imageUrl;
    _nameController.text = widget.meal.name;
  }

  void loadCategories() async {
    setState(() {});
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
                      TextButton(
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
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
                          onPressed: () {},
                          child: const Text('Save',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Your body content
              ),
              Column(
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final ImagePicker _picker = ImagePicker();
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);

                      if (image != null) {
                        setState(() {
                          _selectedImagePath = image.path;
                        });
                      }
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 175,
                          height: 175,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: _selectedImagePath != null
                                ? Image.file(
                                    File(_selectedImagePath!),
                                    width: 175,
                                    height: 175,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    widget.meal.imageUrl,
                                    width: 175,
                                    height: 175,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 7,
                          child: InkWell(
                            onTap: () async {
                              final ImagePicker _picker = ImagePicker();
                              final XFile? image = await _picker.pickImage(
                                  source: ImageSource.gallery);

                              if (image != null) {
                                setState(() {
                                  _selectedImagePath = image.path;
                                });
                              }
                            },
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
                            fontSize: 23,
                            fontFamily: 'InterBold',
                            letterSpacing: -0.75,
                            fontWeight: FontWeight.w700,
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
                        const SizedBox(height: 20),
                        FutureBuilder<List<eIngredient>>(
                          future: efetchIngredients(), //_ingFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              if (snapshot.data!.isNotEmpty) {
                                var limitedData =
                                    snapshot.data!.take(15).toList();
                                List<eIngBox> boxes = List.generate(
                                  limitedData.length,
                                  (i) => eIngBox(ingredient: snapshot.data![i]),
                                );

                                // Create a list of controllers
                                List<double> controllers = boxes.map((box) {
                                  try {
                                    return double.parse(
                                        box.quantityController.text);
                                  } catch (e) {
                                    return 0.0; // Return 0.0 if the text is not a valid double
                                  }
                                }).toList();

                                globalControllers = controllers;
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                      child: Text(
                                        'Ingredients:',
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 38, 20, 84),
                                          fontSize: 23,
                                          fontFamily: 'InterBold',
                                          letterSpacing: -0.75,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: boxes.map((box) {
                                        return Column(
                                          children: <Widget>[
                                            box,
                                            const SizedBox(height: 10),
                                          ],
                                        );
                                      }).toList(),
                                    )
                                  ],
                                );
                              } else {
                                return const SizedBox
                                    .shrink(); // Return an empty widget if the list is empty
                              }
                            }
                          },
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class eIngredient {
  final String name;
  //final double quantity;
  final int unit;
  final double quantity;

  eIngredient({required this.name, required this.quantity, required this.unit});
}

class eIngBox extends StatefulWidget {
  final eIngredient ingredient;

  const eIngBox({required this.ingredient});
  @override
  _eIngBoxState createState() => _eIngBoxState();
  TextEditingController get quantityController =>
      _eIngBoxState().quantityController;
}

class _eIngBoxState extends State<eIngBox> {
  final TextEditingController quantityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          //width: MediaQuery.of(context).size.width * 0.6,
          child: Text(
            widget.ingredient.name,
            softWrap: true,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color.fromARGB(255, 38, 20, 84),
              fontSize: 18,
              fontFamily: 'Inter',
              letterSpacing: -0.75,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  bottomLeft: Radius.circular(10.0),
                ),
                border: Border.all(
                  color: const Color.fromARGB(
                      255, 0, 0, 0), // Specify the border color
                  width: 1.0, // Specify the border thickness
                ),
              ),
              width: MediaQuery.of(context).size.width * 0.1,
              height: 35,
              child: TextFormField(
                textAlign: TextAlign.center,
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: '0.0',
                  border: InputBorder.none,
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 62, 209, 219),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(10.0),
                  bottomRight: Radius.circular(10.0),
                ),
                border: Border(
                  top: BorderSide(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    width: 1.0,
                  ),
                  right: BorderSide(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    width: 1.0,
                  ),
                  bottom: BorderSide(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    width: 1.0,
                  ),
                ),
              ),
              width: MediaQuery.of(context).size.width * 0.2,
              height: 35,
              child: Center(
                child: Text(
                  unitString(widget.ingredient.unit),
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 38, 20, 84),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    letterSpacing: -0.75,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
