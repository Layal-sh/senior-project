import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20,
          ),
          child: Column(
            //mainAxisAlignment: MainAxisAlignment.start,
            //mainAxisSize: MainAxisSize.min,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              /*Expanded(
                child: ListView.builder(
                  itemCount: ingredients.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(ingredients[index]),
                    );
                  },
                ),
              )*/
              Expanded(
                child: FutureBuilder<List<Map>>(
                  future: db.getMealIngredients(widget.meal.id),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Map>> snapshot) {
                    print(snapshot.hasData);
                    if (snapshot.hasData) {
                      List<Map> ingredients = snapshot.data!;
                      return ListView.builder(
                        itemCount: ingredients.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListView.builder(
                            itemCount: snapshot.data!.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title:
                                    Text(snapshot.data![index]['childMealID']),
                              );
                            },
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // By default, show a loading spinner.
                      return CircularProgressIndicator();
                    }
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

/*class Ingredient {
  final int name;

  Ingredient({required this.name});
}*/

/*class IngBox extends StatelessWidget {
  final Ingredient ingredient;

  const IngBox({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50), // Change this value as needed
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 8,
              right: 8,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "ingredient.name",
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
}*/
