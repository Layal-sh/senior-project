import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/application/create.dart';

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
            child: /*GridView.builder(
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
            ),*/

                FutureBuilder<List<Map>>(
              future: db.selectAllMeals(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  List<Map> meals = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: meals.length,
                    itemBuilder: (ctx, i) => MealBox(
                      meal: Meal(
                        name: meals[i]['mealName'],
                        imageUrl:
                            meals[i]['mealPicture'] ?? 'default_image_url',
                      ),
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 3 / 3.5,
                      crossAxisSpacing: 10,
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
            child: Image.network(meal.imageUrl), //need to change acc to image
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: Text(
                    meal.name,
                    softWrap: true,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      color: Color.fromARGB(255, 38, 20, 84),
                      fontSize: 30,
                      fontFamily: 'Ruda',
                      letterSpacing: -0.75,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {},
                child: const CircleAvatar(
                  radius: 11,
                  backgroundColor: Color.fromARGB(255, 225, 225, 225),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Color.fromARGB(255, 255, 255, 255),
                    size: 14,
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
