import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

class _CreateMealState extends State<CreateMeal> {
  XFile? _selectedImage;
  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = (await _picker.pickImage(source: ImageSource.gallery));

    setState(() {
      _selectedImage = image;
    });
  }

  final _nameController = TextEditingController();

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

  @override
  void initState() {
    super.initState();
    loadMeals();
  }

  void loadMeals() async {
    allMeals = await dbHelper.selectAllMeals();
    setState(() {});
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                          onPressed: () {},
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
                    Container(
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
                                color: Color.fromARGB(255, 211, 211, 211),
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
                height: MediaQuery.of(context).size.height - 280,
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
                      height: 10,
                    ),
                    Wrap(
                      spacing: 8.0, // gap between adjacent chips
                      runSpacing: 4.0, // gap between lines
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
                    const SizedBox(
                      height: 20,
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
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  child: TextFormField(
                                    textAlign: TextAlign.center,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                            decimal: true),
                                    decoration: const InputDecoration(
                                      hintText: '0.0',
                                      hintStyle: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                    validator: (value) {
                                      /*if (value.isEmpty) {
                                        return 'Please enter a number';
                                      }
                                      return null;*/
                                    },
                                  ),
                                ),
                                const Text(
                                  'grams',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 38, 20, 84),
                                    fontSize: 17,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Meals()),
                                );
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
                    /*const Text(
                      'Ingredients: ',
                      style: TextStyle(
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontSize: 17,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    */
                    Column(
                      children: <Widget>[
                        // Replace this with your actual total carbs widget
                        ListView.builder(
                          shrinkWrap:
                              true, // This allows the ListView to be inside a Column
                          itemCount: chosenMeals.length,
                          itemBuilder: (context, index) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('${chosenMeals[index]['name']}'),
                                Text(chosenMeals[index]['quantity'].toString()),
                                Text(unitString(chosenMeals[index]['unit'])),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      chosenMeals.removeAt(index);
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                    selectedMeals.isEmpty
                        ? Container()
                        : Expanded(
                            child: ListView.builder(
                              itemCount: selectedMeals.length,
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(allMeals[index]['mealName']),
                                    const Text('quantity'),
                                    const Text('unit'),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () {
                                        setState(() {
                                          //selectedMeals.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                    /*Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          color: const Color.fromARGB(255, 38, 20, 84),
                          iconSize: 30,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => Meals()),
                            );
                          },
                        ),
                        const Text(
                          'Add Ingredients',
                          style: TextStyle(
                            color: Color.fromARGB(255, 38, 20, 84),
                            fontSize: 17,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            decoration: const InputDecoration(
                              fillColor: Colors.white,
                              filled: true,
                              border: OutlineInputBorder(),
                              hintText: 'Carbohydrates number',
                            ),
                            validator: (value) {
                              /*if (value.isEmpty) {
                                return 'Please enter a number';
                              }
                              return null;*/
                            },
                          ),
                        ),
                        const SizedBox(
                            width:
                                10), // Add some spacing between the TextFormField and the Button
                        ElevatedButton(
                          onPressed: () {
                            // Add your calculation logic here
                          },
                          child: Text('Default Calculate'),
                        ),
                      ],
                    )
                  */
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

List<Map> chosenMeals = [];
List<Map> getChosenMeals() {
  return chosenMeals;
}

Function addToChosenMeals = (int id, double quantity) async {
  List<Map> meal = await db.getMealById(id);
  var imageUrl = 'assets/' + (meal[0]['mealPicture'] ?? 'AddDish.png');
  Map<String, dynamic> insertedMeal = {
    'name': meal[0]['mealName'],
    'imageUrl': imageUrl,
    'id': id,
    'carbohydrates': meal[0]['carbohydrates'],
    'certainty': meal[0]['certainty'],
    'quantity': quantity,
    'unit': meal[0]['unit']
  };
  chosenMeals.add(insertedMeal);
  logger.info(
      "Added meal to chosen meals --> name: ${insertedMeal['name']} carbs: ${insertedMeal['carbohydrates']} quantity: ${insertedMeal['quantity']} unit: ${insertedMeal['unit']} certainty: ${insertedMeal['certainty']}");
};
