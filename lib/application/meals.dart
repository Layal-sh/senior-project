import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/application/create.dart';
import 'package:sugar_sense/application/editMeal.dart';
import 'package:sugar_sense/application/mealDetails.dart';
import 'package:sugar_sense/main.dart';
import 'package:sugar_sense/AI/ai_functions.dart';

class Meals extends StatefulWidget {
  final int Index;
  const Meals({required this.Index});

  @override
  State<Meals> createState() => _MealsState();
}

List<Map> chosenMeals = [];
List<Map> chosenCMeals = [];
List<Map> getChosenMeals() {
  return chosenMeals;
}

List<Map> getChosenCMeals() {
  return chosenCMeals;
}

DBHelper db = DBHelper.instance;
String _formatCategory(String category) {
  return category.replaceAll(' ', '').toLowerCase();
}

String? selectedCategory;

class _MealsState extends State<Meals> {
  final TextEditingController _filter = TextEditingController();
  late Future<List<Map>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _mealsFuture = db.selectAllMeals();
    _filter.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    selectedCategory = null;
    setState(() {});
  }

  List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Drinks',
    'Sweets & snacks',
    'Pastries',
    'Dairy products',
    'Fruits',
    'Lebanese dishes',
    'Arabic desserts',
    'Grains, pasta & rice',
    'My Meals'
  ];
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 38, 20, 84), // top bar color
      statusBarIconBrightness: Brightness.light, // top bar icons
    ));
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => {
                  selectedCategory = null,
                  Navigator.of(context).pop(),
                }),
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
        ),
        title: const Text(
          'Meals',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 249, 254),
            fontSize: 17,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
        elevation: 0,
        actions: widget.Index == 0
            ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      ),
                      backgroundColor: const Color.fromARGB(255, 45, 170, 178),
                      //padding: const EdgeInsets.all(16),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CreateMeal()),
                      );
                    },
                    child: const Text(
                      'Create',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ]
            : [],
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 38, 20, 84),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    right: 15,
                    bottom: 10,
                  ),
                  child: TextField(
                    controller: _filter,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 38, 20, 84),
                      fontSize: 15,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search Food',
                      prefixIcon: Icon(Icons.search),
                      prefixIconColor: Color.fromARGB(255, 164, 164, 164),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide(
                          width: 2,
                          color: Color.fromARGB(255, 38, 20, 84),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: Color.fromARGB(255, 38, 20, 84),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(7),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filter.text = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          (selectedCategory == null && _filter.text.isEmpty)
              ? Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                    left: 10.0,
                    bottom: 5,
                    right: 10,
                  ),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // Display 3 categories on each row
                        childAspectRatio: 3 / 3.2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (ctx, i) => ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.resolveWith<Color>(
                            (Set<MaterialState> states) {
                              // If this category is the selected one, use a different color
                              if (selectedCategory ==
                                  categories[i].toLowerCase()) {
                                return Color.fromARGB(255, 67, 223, 234);
                              }
                              return Color.fromARGB(255, 249, 249, 255);
                            },
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry>(
                                  const EdgeInsets.all(0)),
                        ),
                        onPressed: () {
                          setState(() {
                            if (selectedCategory ==
                                categories[i].toLowerCase()) {
                              selectedCategory = null; // Unselect the category
                            } else {
                              selectedCategory = categories[i].toLowerCase();
                            }
                          });
                        },
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Opacity(
                                  opacity: 0.7,
                                  child: Image.asset(
                                    'assets/${categories[i]}.png',

                                    //fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ), // Replace with your image path
                            Flexible(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.25,
                                child: Text(
                                  textAlign: TextAlign.center,
                                  categories[i],
                                  style: TextStyle(
                                    color: selectedCategory ==
                                            categories[i].toLowerCase()
                                        ? Color.fromARGB(255, 255, 255, 255)
                                        : Color.fromARGB(255, 122, 122, 122),
                                    fontSize: 14,
                                    fontFamily: 'Ruda',
                                    letterSpacing: -0.75,
                                    fontWeight: selectedCategory ==
                                            categories[i].toLowerCase()
                                        ? FontWeight.w600
                                        : FontWeight.w300,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.only(
                    left: 15.0,
                    bottom: 5,
                  ),
                  child: SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection:
                          Axis.horizontal, // Make it scroll horizontally
                      children: categories
                          .map((category) => Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  bottom: 8,
                                  left: 5,
                                ),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty
                                        .resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                        // If this category is the selected one, use a different color
                                        if (selectedCategory ==
                                            category.toLowerCase()) {
                                          return Color.fromARGB(
                                              255, 67, 223, 234);
                                        }
                                        return const Color.fromARGB(
                                            255, 249, 255, 254);
                                      },
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      if (selectedCategory ==
                                          category.toLowerCase()) {
                                        selectedCategory =
                                            null; // Unselect the category
                                      } else {
                                        selectedCategory =
                                            category.toLowerCase();
                                        if (_filter.text.isNotEmpty) {
                                          _filter.clear();
                                          selectedCategory = category
                                              .toLowerCase(); // Clear the filter text
                                        }
                                      }
                                    });
                                  },
                                  child: Text(
                                    category,
                                    style: TextStyle(
                                      color: selectedCategory ==
                                              category.toLowerCase()
                                          ? Color.fromARGB(255, 255, 255, 255)
                                          : Color.fromARGB(255, 122, 122, 122),
                                      fontSize: 15,
                                      fontFamily: 'Rubik',
                                      fontWeight: selectedCategory ==
                                              category.toLowerCase()
                                          ? FontWeight.w600
                                          : FontWeight.w300,
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
          Expanded(
            child: (selectedCategory == null)
                ? _filter.text.isNotEmpty
                    ? FutureBuilder<List<Map>>(
                        future: db.searchMeal(_filter.text),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.data!.isEmpty) {
                            return Text('No meals is found');
                          } else {
                            List<Map> meals = snapshot.data!;
                            return GridView.builder(
                              padding: const EdgeInsets.only(
                                top: 10.0,
                                bottom: 10,
                                left: 15,
                                right: 15,
                              ),
                              itemCount: meals.length,
                              itemBuilder: (ctx, i) => Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  MealBox(
                                    meal: Meal(
                                      name: meals[i]['mealName'],
                                      imageUrl: 'assets/' +
                                          (meals[i]['mealPicture'] ??
                                              'AddDish.png'),
                                      id: meals[i]['mealId'],
                                      carbohydrates: meals[i]['carbohydrates'],
                                      unit: meals[i]['unit'],
                                      quantity: 1,
                                      ingredients: [],
                                    ),
                                    ind: widget.Index,
                                  ),
                                  if (selectedCategory == 'my meals')
                                    Positioned(
                                      top: -15,
                                      left: -15,
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          size: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.09,
                                          color:
                                              Color.fromARGB(255, 12, 140, 149),
                                        ),
                                        onPressed: () {
                                          // Add your delete functionality here
                                        },
                                      ),
                                    ),
                                ],
                              ),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 3 / 3.6,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 10,
                              ),
                            );
                          }
                        },
                      )
                    : Container()
                : FutureBuilder<List<Map>>(
                    future: _filter.text.isNotEmpty
                        ? db.searchMeal(_filter.text)
                        : selectedCategory != 'all'
                            ? db.searchCatgeory(
                                _formatCategory(selectedCategory!))
                            : _mealsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else if (snapshot.data!.isEmpty) {
                        return Text('No meals found for this category');
                      } else {
                        List<Map> meals = snapshot.data!;
                        return GridView.builder(
                          padding: const EdgeInsets.only(
                            top: 10.0,
                            bottom: 10,
                            left: 15,
                            right: 15,
                          ),
                          itemCount: meals.length,
                          itemBuilder: (ctx, i) => MealBox(
                            meal: Meal(
                              name: meals[i]['mealName'],
                              imageUrl: 'assets/' +
                                  (meals[i]['mealPicture'] ?? 'AddDish.png'),
                              id: meals[i]['mealId'],
                              carbohydrates: meals[i]['carbohydrates'],
                              unit: meals[i]['unit'],
                              quantity: 1,
                              ingredients: [],
                            ),
                            ind: widget.Index,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            childAspectRatio: 3 / 3.6,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 10,
                          ),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class Meal {
  final String name;
  final String imageUrl;
  final int id;
  final double carbohydrates;
  final double quantity;
  final int unit;
  final List<eIngredient> ingredients;
  //final int ind;
  Meal({
    required this.name,
    required this.imageUrl,
    required this.id,
    required this.carbohydrates,
    required this.quantity,
    required this.unit,
    required this.ingredients,
    //required this.ind,
  });
  String toString() {
    return 'Meal{name: $name, imageUrl: $imageUrl, id: $id, carbodydrates: $carbohydrates, quantity: $quantity, unit: $unit}';
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'id': id,
      'carbohydrates': carbohydrates,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

double totalCarbs = 0;
double TotalCarbs() {
  for (var meal in chosenMeals) {
    double mealCarbohydrates = meal['carbohydrates'] * meal['quantity'];
    totalCarbs += mealCarbohydrates;
  }
  return totalCarbs;
}

Function addToChosenMeals = (int id, double quantity) async {
  bool found = false;
  print("entered chosen meals");
  print(chosenMeals);
  chosenMeals.forEach((meal) {
    if (meal['id'] == id) {
      found = true;
    }
  });

  if (found) {
    return false;
  } else {
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

    return true;
  }
};

double totalCCarbs = 0;
double TotalCCarbs() {
  for (var meal in chosenCMeals) {
    double mealCarbohydrates = meal['carbohydrates'] * meal['quantity'];
    totalCCarbs += mealCarbohydrates;
  }
  return totalCCarbs;
}

Function addToChosenCMeals = (int id, double quantity) async {
  bool found = false;
  print("entered chosen meals");
  print(chosenCMeals);
  chosenCMeals.forEach((meal) {
    if (meal['id'] == id) {
      found = true;
    }
  });

  if (found) {
    return false;
  } else {
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
    chosenCMeals.add(insertedMeal);
    print("Chosen Meals: $chosenCMeals");
    logger.info(
        "Added meal to chosen meals --> name: ${insertedMeal['name']} carbs: ${insertedMeal['carbohydrates']} quantity: ${insertedMeal['quantity']} unit: ${insertedMeal['unit']} certainty: ${insertedMeal['certainty']}");

    return true;
  }
};

class MealBox extends StatefulWidget {
  final Meal meal;
  final int ind;
  const MealBox({required this.meal, required this.ind});
  @override
  _MealBoxState createState() => _MealBoxState();
}

class _MealBoxState extends State<MealBox> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final TextEditingController quantityController =
            TextEditingController();
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Center(
              child: SingleChildScrollView(
                reverse: true,
                child: AlertDialog(
                  title: const Text(
                    'Enter quantity',
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  content: Column(
                    //mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // This makes the column height wrap its content
                    children: <Widget>[
                      Text(
                        widget.meal.name,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 45, 170, 178),
                          fontSize: 15,
                        ),
                      ),
                      const Text(
                        'Serving:',
                        style: TextStyle(
                          color: Color.fromARGB(255, 45, 170, 178),
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: TextField(
                              controller: quantityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: "Enter quantity",
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                  ),
                                  onPressed: () {
                                    quantityController.clear();
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              unitString(widget.meal.unit),
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.fade,
                              softWrap: false,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 38, 20, 84),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Add more Text widgets for more lines
                    ],
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Color.fromARGB(255, 45, 170, 178),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Color.fromARGB(255, 45, 170, 178),
                        ),
                      ),
                      onPressed: () async {
                        if (quantityController.text.isEmpty) {
                          print('Quantity is empty');
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Not Valid'),
                                content: const Text(
                                  'Please enter a quantity.',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text(
                                      'OK',
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        } else {
                          bool found;
                          if (widget.ind == 0) {
                            found = await addToChosenMeals(widget.meal.id,
                                double.parse(quantityController.text));
                          } else {
                            found = await addToChosenCMeals(widget.meal.id,
                                double.parse(quantityController.text));
                          }

                          if (found) {
                            Navigator.pop(context, 'refresh');
                            Navigator.pop(context, 'refresh');
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const AlertDialog(
                                  content: Text('Meal was already added'),
                                );
                              },
                            );
                          }
                        }
                      },
                    ),
                  ],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(5), // Change this value as needed
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 90,
                  child: FutureBuilder<ByteData>(
                    future: DefaultAssetBundle.of(context)
                        .load(widget.meal.imageUrl),
                    builder: (BuildContext context,
                        AsyncSnapshot<ByteData> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          //print('No');
                          return ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                            child: Image.asset(
                              'assets/AddDish.png',
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          );
                        } else {
                          return ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5),
                            ),
                            child: Image.asset(
                              widget.meal.imageUrl,
                              width: MediaQuery.of(context).size.width,
                              fit: BoxFit.cover,
                            ),
                          );
                        }
                      } else {
                        return const CircularProgressIndicator(); // Show a loading spinner while waiting for the asset to load
                      }
                    },
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 8,
                        right: 8,
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            widget.meal.name,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 38, 20, 84),
                              fontSize: 35,
                              fontFamily: 'Ruda',
                              letterSpacing: -0.75,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () async {
                            var result = await Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        MealDetailsPage(
                                            meal: widget.meal,
                                            index: widget.ind),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  );
                                },
                              ),
                            );
                            if (result == 'refresh') {
                              Navigator.pop(context, 'refresh');
                            }
                          },
                          child: CircleAvatar(
                            radius: MediaQuery.of(context).size.width * 0.027,
                            backgroundColor: Color.fromARGB(170, 64, 205, 215),
                            child: Icon(
                              Icons.arrow_forward_ios,
                              color: Color.fromARGB(255, 255, 255, 255),
                              size: MediaQuery.of(context).size.width * 0.035,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                //meal name
              ],
            ),
          ),
          if (selectedCategory == 'my meals')
            Positioned(
              top: -15,
              left: -15,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  size: MediaQuery.of(context).size.width * 0.09,
                  color: Color.fromARGB(255, 12, 140, 149),
                ),
                onPressed: () {
                  db.deleteMealById(widget.meal.name);
                },
              ),
            ),
        ],
      ),
    );
  }
}
