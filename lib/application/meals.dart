import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/application/create.dart';
import 'package:sugar_sense/application/mealDetails.dart';

class Meals extends StatefulWidget {
  const Meals({Key? key}) : super(key: key);

  @override
  State<Meals> createState() => _MealsState();
}

class _MealsState extends State<Meals> {
  final TextEditingController _filter = TextEditingController();
  DBHelper db = DBHelper.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateMeal()),
                );
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
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map>>(
              future: db.selectAllMeals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Map> meals = snapshot.data!;
                  print(meals);
                  return GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: meals.length,
                    itemBuilder: (ctx, i) => MealBox(
                      meal: Meal(
                        name: meals[i]['mealName'],
                        imageUrl:'assets/' + (meals[i]['mealPicture'] ?? 'AddDish.png'),
                        id: meals[i]['mealId'],
                      ),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3 / 3.5,
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
  Meal({required this.name, required this.imageUrl, required this.id});
}

class MealBox extends StatelessWidget {
  final Meal meal;

  const MealBox({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5), // Change this value as needed
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: meal.imageUrl != null && meal.imageUrl.startsWith('http')
                ? Image.network(meal.imageUrl)
                : Image.asset(meal.imageUrl),
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
                      meal.name,
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
                    onTap: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  MealDetailsPage(
                            meal: meal,
                          ),
                          transitionsBuilder:
                              (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'meal${meal.name}',
                      child: const CircleAvatar(
                        radius: 11,
                        backgroundColor: Color.fromARGB(170, 64, 205, 215),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 14,
                        ),
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
    );
  }
}
