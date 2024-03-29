import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/application/meals.dart';
import 'package:sugar_sense/AI/ai_functions.dart';

class MealDetailsPage extends StatefulWidget {
  final Meal meal;
  const MealDetailsPage({required this.meal});

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  DBHelper db = DBHelper.instance;
  final TextEditingController controller = TextEditingController(text: '1');
  final TextEditingController _numberOfMeal = TextEditingController();
  // Your list of ingredients

  Future<List<Ingredient>> fetchIngredients() async {
    List<Map> response =
        await db.getIngredients(widget.meal.id); // Call getIngredients

    // Convert the response into a list of Ingredient objects
    List<Ingredient> ingredients = response.map((item) {
      return Ingredient(
        name: item['mealName'],
        unit: item['unit'],
        quantity: item['quantity'],
      );
    }).toList();
    return ingredients;
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance!.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 38, 20, 84), // Set status bar color
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      //backgroundColor: const Color.fromARGB(255, 38, 20, 84),

      body: Padding(
        padding: const EdgeInsets.only(
          top: 30,
        ),
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.start,
          //mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
              ),
              child: SizedBox(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 35,
                        color: Color.fromARGB(255, 38, 20, 84),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit,
                        color: Color.fromARGB(255, 38, 20, 84),
                      ),
                      onPressed: () {
                        // Handle the settings button press here
                      },
                    ),
                  ],
                ),
              ),
            ),
            /*Center(
              child: SizedBox(
                width: 175,
                height: 175,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.asset(
                    widget.meal.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),*/
            Padding(
              padding: const EdgeInsets.only(
                left: 40,
                right: 20,
                top: 10,
              ),
              child: Text(
                widget.meal.name,
                style: const TextStyle(
                  color: Color.fromARGB(255, 38, 20, 84),
                  fontSize: 25,
                  fontFamily: 'Inter',
                  letterSpacing: -0.75,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            const Padding(
              padding: EdgeInsets.only(
                left: 40,
                right: 20,
              ),
              child: Text(
                "Categories",
                style: TextStyle(
                  color: Color.fromARGB(255, 38, 20, 84),
                  fontSize: 23,
                  fontFamily: 'Inter',
                  letterSpacing: -0.75,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<Ingredient>>(
                future: fetchIngredients(), //_ingFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    if (snapshot.data!.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(
                              left: 40,
                              right: 20,
                            ),
                            child: Text(
                              'Ingredients:',
                              style: TextStyle(
                                color: Color.fromARGB(255, 38, 20, 84),
                                fontSize: 20,
                                fontFamily: 'Inter',
                                letterSpacing: -0.75,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (ctx, i) {
                                return IngBox(ingredient: snapshot.data![i]);
                              },
                            ),
                          ),
                        ],
                      );
                    } else {
                      return const SizedBox
                          .shrink(); // Return an empty widget if the list is empty
                    }
                  }

                  /*return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (ctx, i) {
                        return IngBox(ingredient: snapshot.data![i]);
                      },
                    );*/ /*GridView.builder(
                      padding: const EdgeInsets.all(10.0),
                      itemCount: ingredients.length,
                      itemBuilder: (ctx, i) => IngBox(
                        ingredient: Ingredient(
                          name: ingredients[i]['mealName'],
                          quantity: ingredients[i]['c.quantity'],
                          unit: ingredients[i]['c.unit'],
                        ),
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 3 / 5,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 10,
                      ),
                    );*/
                },
              ),
            ),

            /*Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 0, 0, 0)),
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Carbohydrates',
                        style: TextStyle(
                          fontSize: 25.0,
                          fontFamily: 'InterBlack',
                        ),
                      ),
                      const Divider(
                        color: Color.fromARGB(255, 0, 0, 0),
                        //height: 10,
                        thickness: 1,
                      ),
                      const Text(
                        'Serving Size',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_drop_up,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    int currentValue =
                                        int.parse(controller.text);
                                    if (currentValue < 99) {
                                      currentValue++;
                                      controller.text = (currentValue)
                                          .toString(); // incrementing value
                                    }
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(0.0),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.arrow_drop_down,
                                    size: 40,
                                  ),
                                  onPressed: () {
                                    int currentValue =
                                        int.parse(controller.text);
                                    if (currentValue > 1) {
                                      currentValue--;
                                      controller.text = (currentValue)
                                          .toString(); // decrementing value
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.13,
                            height: 40.0,
                            child: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20.0),
                              decoration: const InputDecoration(
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 10.0),
                                border: OutlineInputBorder(),
                                hintText: '1',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Row(
                            children: [
                              Text(
                                widget.meal
                                    .name, // Replace with your actual value
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                " (${unitString(widget.meal.unit)})", // Replace with your actual value
                                style: const TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Divider(
                        color: Color.fromARGB(255, 0, 0, 0),
                        //height: 10,
                        thickness: 5,
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      const Text(
                        'Amount per Serving',
                        style: TextStyle(
                          fontSize: 17.0,
                          fontFamily: 'Inter',
                          //fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Carbohydrates',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '10g', // Replace with your actual value
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )*/
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          left: 25,
          right: 25,
          bottom: 40,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Form(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2.7,
                height: 30,
                child: TextFormField(
                  controller: _numberOfMeal,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                    hintText: 'Choose Amount',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 198, 198, 198),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 38, 20, 84),
                        width: 1.5,
                      ),
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color.fromARGB(255, 171, 171, 171),
                        width: 100,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Text(
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
            SizedBox(
              width: 135,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(1),
                  backgroundColor: const Color.fromARGB(255, 30, 203, 215),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Add To Meals',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 15,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  print("adding to meals");
                  try {
                    if (double.parse(_numberOfMeal.text) <= 0) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const AlertDialog(
                            content:
                                Text('Cannot input negative or zero values'),
                          );
                        },
                      );
                    } else {
                      addToChosenMeals(
                          widget.meal.id, double.parse(_numberOfMeal.text));
                    }
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const AlertDialog(
                          content: Text('Specify the amount as a number'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Ingredient {
  final String name;
  final double quantity;
  final int unit;

  Ingredient({
    required this.name,
    required this.quantity,
    required this.unit,
  });
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
    };
  }
}

class IngBox extends StatefulWidget {
  final Ingredient ingredient;

  const IngBox({required this.ingredient});
  @override
  _IngBoxState createState() => _IngBoxState();
}

class _IngBoxState extends State<IngBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
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
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Text(
              "${widget.ingredient.quantity}",
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color.fromARGB(255, 38, 20, 84),
                fontSize: 20,
                fontFamily: 'Inter',
                letterSpacing: -0.75,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.2,
            child: Text(
              "${widget.ingredient.unit}",
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color.fromARGB(255, 38, 20, 84),
                fontSize: 20,
                fontFamily: 'Inter',
                letterSpacing: -0.75,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
