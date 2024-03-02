import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Meals extends StatefulWidget {
  const Meals({Key? key}) : super(key: key);

  @override
  State<Meals> createState() => _MealsState();
}

class _MealsState extends State<Meals> {
  final TextEditingController _filter = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meals'),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
        elevation: 0,
        actions: [
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
                // Handle the button press here
              },
              child:
                  const Text('Create', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: const Color.fromARGB(255, 38, 20, 84),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: _filter,
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
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10.0),
              itemCount: meals.length,
              itemBuilder: (ctx, i) => MealBox(meal: meals[i]),
              // This delegate will create a grid layout with max 3 items per row.
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 3 / 3.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
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

  Meal({required this.name, required this.imageUrl});
}

class MealBox extends StatelessWidget {
  final Meal meal;

  const MealBox({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Text(meal.imageUrl), //need to change acc to image
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                meal.name,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  color: Color.fromARGB(255, 38, 20, 84),
                  fontSize: 14,
                  fontFamily: 'Ruda',
                  letterSpacing: -0.75,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const CircleAvatar(
                radius: 11,
                backgroundColor: Color.fromARGB(255, 225, 225, 225),
                child: Icon(
                  Icons.arrow_forward_ios,
                  color: Color.fromARGB(255, 255, 255, 255),
                  size: 14,
                ),
              ),
            ],
          ),
          //meal name
        ],
      ),
    );
  }
}

List<Meal> meals = [
  Meal(name: 'Meal 1', imageUrl: 'ima'),
  Meal(name: 'Meal 2', imageUrl: 'im'),
  Meal(name: 'Meal 3', imageUrl: 'im'),
  Meal(name: 'Meal 4', imageUrl: 'ima'),
  Meal(name: 'Meal 5', imageUrl: 'im'),
  Meal(name: 'Meal 6', imageUrl: 'im'),
  // Add more meals as needed
];
