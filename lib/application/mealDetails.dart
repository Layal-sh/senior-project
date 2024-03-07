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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 38, 20, 84),
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
        actions: [
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
        ],
      ),
      body: Hero(
        tag: 'meal${widget.meal.name}',
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(
                top: 100,
              ),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 20,
              decoration: const BoxDecoration(
                color: Colors.white, // Set the box color to white
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(70),
                  topRight: Radius.circular(70),
                ), // Give the box rounded corners
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 100, left: 20, right: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.meal.name,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontSize: 17,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<Map>>(
                        future: db.selectAllHasMeals(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
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
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              child: SizedBox(
                width: 175,
                height: 175,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/facebook.png', //Image.network(widget.meal.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
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
              child: SizedBox(
                width: 100,
                height: 90,
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
          ),

          //meal name
        ],
      ),
    );
  }
}
