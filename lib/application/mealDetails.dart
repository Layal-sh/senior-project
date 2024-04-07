import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/application/editMeal.dart';
import 'package:sugar_sense/application/meals.dart';
import 'package:sugar_sense/application/app.dart';
import 'package:sugar_sense/AI/ai_functions.dart';
import 'package:sugar_sense/main.dart';

class MealDetailsPage extends StatefulWidget {
  final Meal meal;
  final int index;
  const MealDetailsPage({required this.meal, required this.index});

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  DBHelper db = DBHelper.instance;
  final TextEditingController controller = TextEditingController(text: '1.0');
  final TextEditingController _numberOfMeal = TextEditingController();
  // Your list of ingredients

  ValueNotifier<double> currentValue = ValueNotifier<double>(1.0);

  Future<List<Ingredient>> fetchIngredients() async {
    List<Map> response =
        await db.getIngredients(widget.meal.id); // Call getIngredients

    // Convert the response into a list of Ingredient objects
    List<Ingredient> ingredients = response
        .map((item) {
          if (item['quantity'] != 0) {
            return Ingredient(
              name: item['mealName'],
              unit: item['unit'],
              quantity: item['quantity'],
            );
          }
          return null;
        })
        .whereType<Ingredient>()
        .toList();
    return ingredients;
  }

  Future<List<Ingredient>> fetchAllIngredients() async {
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

    controller.addListener(updateCurrentValue);
    currentValue.addListener(updateControllerText);
  }

  void updateCurrentValue() {
    currentValue.value = double.tryParse(controller.text) ?? 1.0;
  }

  void updateControllerText() {
    controller.text = currentValue.value.toString();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 38, 20, 84), // Set status bar color
      ));
    });
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(
          83, 115, 61, 252), //const Color.fromARGB(184, 30, 203, 215),

      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.3,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(0),
                            child: Image.asset(
                              widget.meal.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height * 0.2,
                          left: 15,
                          right: 15,
                        ),
                        child: Expanded(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 249, 254),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20), // Top left corner
                                topRight:
                                    Radius.circular(20), // Top right corner
                                // Add other corners if needed
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: 25.0,
                                    right: 25,
                                    top: 25,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                80,
                                        child: Expanded(
                                          child: Text(
                                            widget.meal.name,
                                            style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 38, 20, 84),
                                              fontSize: 35,
                                              fontFamily: 'Inter',
                                              letterSpacing: -0.75,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      const Text(
                                        "Categories",
                                        style: TextStyle(
                                          color:
                                              Color.fromARGB(255, 38, 20, 84),
                                          fontSize: 23,
                                          fontFamily: 'InterBold',
                                          letterSpacing: -0.75,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      FutureBuilder<List<String>>(
                                        future: db
                                            .getCategoryOfMeal(widget.meal.id),
                                        builder: (BuildContext context,
                                            AsyncSnapshot<List<String>>
                                                snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return CircularProgressIndicator(); // Show a loading spinner while waiting
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}'); // Show error if there is any
                                          } else {
                                            // Display the categories
                                            return Wrap(
                                              spacing: 10, // space between rows
                                              runSpacing: 10,
                                              children: snapshot.data!
                                                  .map(
                                                    (category) =>
                                                        IntrinsicWidth(
                                                      child: Container(
                                                        height: 35,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: const Color
                                                              .fromARGB(255, 30,
                                                              203, 215),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 8.0,
                                                                  right: 8),
                                                          child: Center(
                                                            child: Text(
                                                              category, // Display the category
                                                              style:
                                                                  const TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        255,
                                                                        255,
                                                                        255),
                                                                fontSize: 18,
                                                                fontFamily:
                                                                    'Inter',
                                                                letterSpacing:
                                                                    -0.75,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w900,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                  .toList(),
                                            );
                                          }
                                        },
                                      ),
                                      FutureBuilder<List<Ingredient>>(
                                        future:
                                            fetchIngredients(), //_ingFuture,
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const CircularProgressIndicator();
                                          } else if (snapshot.hasError) {
                                            return Text(
                                                'Error: ${snapshot.error}');
                                          } else {
                                            if (snapshot.data!.isNotEmpty) {
                                              var limitedData = snapshot.data!
                                                  .take(15)
                                                  .toList();
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Padding(
                                                    padding: EdgeInsets.only(
                                                      bottom: 10,
                                                    ),
                                                    child: Text(
                                                      'Ingredients:',
                                                      style: TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 38, 20, 84),
                                                        fontSize: 23,
                                                        fontFamily: 'InterBold',
                                                        letterSpacing: -0.75,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                  Column(
                                                    children: List.generate(
                                                      limitedData.length,
                                                      (i) => IngBox(
                                                          ingredient: snapshot
                                                              .data![i]),
                                                    ),
                                                  ),
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
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 20.0,
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.8,
                                      child: Container(
                                        padding: const EdgeInsets.all(10.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: const Color.fromARGB(
                                                  255, 0, 0, 0)),
                                          borderRadius:
                                              BorderRadius.circular(1.0),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Carbohydrates',
                                              style: TextStyle(
                                                fontSize: 25.0,
                                                fontFamily: 'InterBlack',
                                              ),
                                            ),
                                            const Divider(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                        Icons.arrow_drop_up,
                                                        size: 40,
                                                      ),
                                                      onPressed: () {
                                                        currentValue.value =
                                                            double.parse(
                                                                controller
                                                                    .text);
                                                        if (currentValue.value <
                                                            99) {
                                                          currentValue.value +=
                                                              1.0;
                                                          controller.text =
                                                              currentValue.value
                                                                  .toString();
                                                        }
                                                      },
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              0.0),
                                                      child: IconButton(
                                                        icon: const Icon(
                                                          Icons.arrow_drop_down,
                                                          size: 40,
                                                        ),
                                                        onPressed: () {
                                                          currentValue.value =
                                                              double.parse(
                                                                  controller
                                                                      .text);
                                                          if (currentValue
                                                                  .value >
                                                              1) {
                                                            currentValue
                                                                .value -= 1;
                                                            controller.text =
                                                                currentValue
                                                                    .value
                                                                    .toString(); // decrementing value
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.13,
                                                  height: 40.0,
                                                  child: TextField(
                                                    controller: controller,
                                                    keyboardType:
                                                        TextInputType.number,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        fontSize: 20.0),
                                                    decoration:
                                                        const InputDecoration(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 10.0),
                                                      border:
                                                          OutlineInputBorder(),
                                                      hintText: '1',
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    "${widget.meal.name} (${unitString(widget.meal.unit)})", // Replace with your actual value
                                                    style: const TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const Divider(
                                              color:
                                                  Color.fromARGB(255, 0, 0, 0),
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  'Total Carbohydrates',
                                                  style: TextStyle(
                                                    fontSize: 20.0,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                ValueListenableBuilder<double>(
                                                  valueListenable: currentValue,
                                                  builder:
                                                      (context, value, child) {
                                                    return Text(
                                                      formatDouble(widget.meal
                                                              .carbohydrates *
                                                          value),
                                                      style: const TextStyle(
                                                          fontSize: 16.0),
                                                    );
                                                  },
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 10,
                right: 10,
              ),
              child: SizedBox(
                child: FutureBuilder<List<Ingredient>>(
                  future: fetchAllIngredients(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator(); // Show loading indicator while waiting for the future to complete
                    } else if (snapshot.hasError) {
                      return Text(
                          'Error: ${snapshot.error}'); // Show error if the future completes with an error
                    } else {
                      // Check if the meal has ingredients
                      return snapshot.data!.isNotEmpty
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      const Color.fromARGB(79, 0, 236, 253),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      size: 35,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                CircleAvatar(
                                  backgroundColor:
                                      const Color.fromARGB(79, 0, 236, 253),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              EditMeal(
                                            meal: widget.meal,
                                            index: widget.index,
                                          ),
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      const Color.fromARGB(79, 0, 236, 253),
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.arrow_back_rounded,
                                      size: 35,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                              ],
                            ); // Empty container when there are no ingredients
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Color.fromARGB(255, 255, 249, 254),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 25,
            right: 25,
            bottom: 40,
            top: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Form(
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
              Expanded(
                flex: 2,
                child: SizedBox(
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
                      logger.info("adding to chosen meals");
                      try {
                        if (_numberOfMeal.text.isEmpty) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                content: Text('Specify the amount as a number'),
                              );
                            },
                          );
                        } else if (double.parse(_numberOfMeal.text) <= 0) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                content: Text(
                                    'Cannot input negative or zero values'),
                              );
                            },
                          );
                        } else {
                          bool found;
                          if (widget.index == 0) {
                            found = await addToChosenMeals(widget.meal.id,
                                double.parse(_numberOfMeal.text));
                          } else {
                            found = await addToChosenCMeals(widget.meal.id,
                                double.parse(_numberOfMeal.text));
                          }

                          if (found) {
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

                          //Navigator.of(context).pop(context, 'refresh');
                        }
                      } catch (e) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return const AlertDialog(
                              content: Text('an error occured'),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(() {
      updateCurrentValue();
    });
    super.dispose();
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
    return Row(
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
          width: MediaQuery.of(context).size.width * 0.1,
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
          width: MediaQuery.of(context).size.width * 0.26,
          child: Text(
            unitString(widget.ingredient.unit),
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
    );
  }
}

String formatDouble(double value) {
  String twoDigits = value.toStringAsFixed(2);
  return twoDigits.endsWith('0') ? value.toStringAsFixed(1) : twoDigits;
}
