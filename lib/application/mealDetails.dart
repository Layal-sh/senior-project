import 'package:flutter/material.dart';
import 'package:sugar_sense/application/meals.dart';

class MealDetailsPage extends StatefulWidget {
  final Meal meal;
  const MealDetailsPage({required this.meal});

  @override
  State<MealDetailsPage> createState() => _MealDetailsPageState();
}

class _MealDetailsPageState extends State<MealDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      appBar: AppBar(
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color.fromARGB(255, 38, 20, 84),
          size: 25.0,
        ),
        title: const Text(
          'Details',
          style: TextStyle(
            color: Color.fromARGB(255, 38, 20, 84),
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
                color: Color.fromARGB(255, 38, 20, 84),
              ),
              onPressed: () {
                // Handle the settings button press here
              },
            ),
          ),
        ],
      ),
      body: Hero(
        tag: 'meal${widget.meal.imageUrl}',
        child: Container(
          margin: const EdgeInsets.only(
            top: 20,
          ),
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: Colors.white, // Set the box color to white
            borderRadius:
                BorderRadius.circular(20), // Give the box rounded corners
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/AddDish.png', //Image.network(widget.meal.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Text(
                  widget.meal.name,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 38, 20, 84),
                    fontSize: 20,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
