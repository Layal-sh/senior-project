import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/application/meals.dart';

class MealDetailsPage extends StatefulWidget {
  final Meal meal;
  const MealDetailsPage({required this.meal});

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  DBHelper db = DBHelper.instance;
  String dropdownValue = 'Grams';
  final TextEditingController _numberOfMeal = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 255, 255, 255),
          size: 25.0,
        ),
        title: const Text(
          'Details',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
          ),
        ),
        /*actions: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: IconButton(
              icon: const Icon(
                Icons.edit,
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              onPressed: () {
                // Handle the settings button press here
              },
            ),
          ),
        ],*/
      ),
      body: Hero(
        tag: 'meal${widget.meal.name}',
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
          ),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
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
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 40,
                  right: 20,
                  top: 20,
                ),
                child: Text(
                  widget.meal.name,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 38, 20, 84),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w800,
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
                  'Ingredients',
                  style: TextStyle(
                    color: Color.fromARGB(255, 38, 20, 84),
                    fontSize: 17,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              /*Expanded(
                child: FutureBuilder<List<Map>>(
                  future: db.getMealIngredients(widget.meal.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      List<Map> ingredients = snapshot.data!;
                      return GridView.builder(
                        padding: const EdgeInsets.all(10.0),
                        itemCount: ingredients.length,
                        itemBuilder: (ctx, i) => IngBox(
                          ingredient: Ingredient(
                            name: ingredients[i]['mealName'],
                          ),
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 3 / 3.5,
                          crossAxisSpacing: 7,
                          mainAxisSpacing: 10,
                        ),
                      );
                    }
                  },
                ),
              ),*/
            ],
          ),
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
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3.4,
                    height: 25,
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
                  const SizedBox(
                    width: 10,
                  ),
                  PopupMenuButton<String>(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            dropdownValue,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 38, 20, 84),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 30),
                      ],
                    ),
                    onSelected: (String value) {
                      setState(() {
                        dropdownValue = value;
                      });
                    },
                    itemBuilder: (BuildContext context) {
                      return ['Grams', 'Kilograms', 'Pounds']
                          .map((String value) {
                        return PopupMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList();
                    },
                  )
                ],
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
                          return AlertDialog(
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
                        return AlertDialog(
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

  Ingredient({required this.name});
}

class IngBox extends StatelessWidget {
  final Ingredient ingredient;

  const IngBox({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // Change this value as needed
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 8,
              right: 8,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                ingredient.name,
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

          //meal name
        ],
      ),
    );
  }
}
