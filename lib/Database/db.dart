// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../main.dart';

class DBHelper {
  DBHelper._privateConstructor();

  static final DBHelper instance = DBHelper._privateConstructor();

  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  initialDb() async {
    String DbPath = await getDatabasesPath();
    String path = join(DbPath, 'SugarSense.db');
    Database database = await openDatabase(path,
        onCreate: _onCreate, version: 23, onUpgrade: _onUpgrade);
    return database;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    //if (oldVersion < newVersion) {
    // await db.execute(
    //     '''ALTER TABLE "Meals" ADD COLUMN frequency INTEGER NULL;''');
    //}
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE "Entry"(
    entryId INTEGER PRIMARY KEY AUTOINCREMENT,
    glucoseLevel REAL NOT NULL,
    insulinDosage INTEGER NULL,
    entryDate TEXT NOT NULL
  );
  ''');
    await db.execute('''
    CREATE TABLE "Meals"(
      mealId INTEGER NOT NULL PRIMARY KEY,
      mealName TEXT NOT NULL,
      mealPicture TEXT NULL,
      unit INTEGER NOT NULL,
      carbohydrates REAL NOT NULL,
      tags TEXT NULL,
      frequency INTEGER NOT NULL,
      certainty REAL NOT NULL
    );
  ''');
    await db.execute('''
  CREATE TABLE "MealComposition"(
    parentMealId INTEGER NOT NULL,
    childMealId INTEGER NOT NULL,
    quantity REAL NOT NULL,
    unit INTEGER NOT NULL,
    PRIMARY KEY(parentMealId, childMealId),
    FOREIGN KEY(parentMealId) REFERENCES Meals(mealId),
    FOREIGN KEY(childMealId) REFERENCES Meals(mealId)
  );
  ''');
    await db.execute('''
  CREATE TABLE "hasMeal"(
    entryId INTEGER NOT NULL,
    mealId INTEGER NOT NULL,
    quantity REAL NOT NULL,
    unit INTEGER NOT NULL,
    FOREIGN KEY(entryId) REFERENCES Entry(entryId),
    FOREIGN KEY(mealId) REFERENCES Meals(mealId),
    PRIMARY KEY(entryId,mealId)
  );
  ''');
    await db.execute('''
  CREATE TABLE "Articles"(
    articleId INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
    link TEXT NOT NULL
  );
  ''');
    await db.execute('''
  CREATE TABLE "Favorites"(
    patientId INTEGER NOT NULL,
    articleId INTEGER NOT NULL,
    FOREIGN KEY(articleId) REFERENCES Articles(articleId),
    PRIMARY KEY(patientId,articleId)
  );
  ''');
    logger.info("Local Database has been created");
  }

  readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }
  //needs a create meal query

//insert query
  insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

//update data
  updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

//delete data
  deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }

  //get all meals from local database for adding inputs
  Future<List<Map>> selectAllMeals() async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
  SELECT * FROM "Meals";
   ''');
    logger.info("All meals have been fetched successfully.");
    return response;
  }

  //create an entry for the insulin dosage
  createEntry(double glucose, int insulin, String date, List<Map> meals) async {
    Database? mydb = await db;
    print('$glucose $insulin $date');
    int entryId = await mydb!.rawInsert('''
  INSERT INTO Entry (glucoseLevel, insulinDosage, entryDate)
  VALUES($glucose,$insulin,'$date');
  ''');
    int idEntry = await getLatestEntryId();

    meals.forEach((element) {
      mydb.rawInsert('''
  INSERT INTO hasMeal (entryId,mealId,quantity,unit)
  VALUES($idEntry,${element['id']},${element['quantity']},"${element['unit']}");
  ''');
      logger.info("hasMeal has been created successfully.");
    });
    logger.info("Created entry with id $entryId");
    return entryId;
  }

  selectAllMealComposition() async {
    Database? mydb = await db;
    List<Map> response =
        await mydb!.rawQuery('''select * from MealComposition''');
    logger.info("All meal compositions have been fetched successfully.");
    return response;
  }

  getEntryDate(String date) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
      SELECT entryId from Entry
      WHERE entryDate = $date
      ''');
    return response[0];
  }

  getLatestEntryId() async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * from Entry 
    ORDER BY entryDate DESC
    LIMIT 1
    ''');
    return response[0]['entryId'];
  }

  Future<List<Map>> getMealIngredients(int id) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * FROM "MealComposition" WHERE parentMealId = $id;
    ''');
    List<Map> ings = [];
    for (Map ing in response) {
      ings.add(await getMealById(ing["childMealId"]));
    }
    logger.info("Ingredients for meal $id have been fetched successfully.");
    return ings;
  }

  getIngredients(int parentId) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
      SELECT m1.mealName, m1.mealID, c.unit, c.quantity 
  FROM Meals AS m, Meals AS m1, MealComposition AS c
  WHERE m.mealID=c.parentMealID AND m1.mealID=c.childMealID AND m.mealID=$parentId;
    ''');
    logger
        .info("Ingredients for meal $parentId have been fetched successfully.");
    return response;
  }

  getMealById(int id) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * FROM "Meals" WHERE mealId = $id;
    ''');
    return response;
  }

  updateMealById(int mealId, double carbs, double certainty) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate('''
    UPDATE Meals SET carbohydrate = $carbs , certainty = $certainty
    WHERE mealId = $mealId
    ''');
    logger.info("Meal $mealId has been updated successfully.");
    return response;
  }

  getMealsFromEntryID(int entryId) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * FROM "hasMeal" WHERE entryId = $entryId;
    ''');
    return response;
  }

  //create hasMeal for each entry
  createMealForEntry(int entryId, int mealId, int qtty, int unit) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert('''
  INSERT INTO "hasMeal"(entryId,mealId,quantity)
  VALUES($entryId,$mealId,$qtty);
  ''');
    return response;
  }

//get meal id by name
  getMealIdByName(String name) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT mealId FROM "Meals" WHERE mealName = "$name";
    ''');
     if (response.isNotEmpty) {
    return response.first['mealId'] as int;
  }
  return -1;
  }

//Create a new meal and insert it into the database after checking if it already exists
  Future<int> createNewMeal(
    String name,
    double carbs,
    int unit,
    String picture,
    String tags,
  ) async {

    double certainty = 0.0;
    int frequency = 0;
    Database? mydb = await db;
    int mealId = await getMealIdByName("$name");

    int nextId= await getNextMealId();
   
    if (mealId < 0) {
      
      int response = await mydb!.rawInsert(
          '''INSERT INTO Meals(mealId,mealName,carbohydrates,unit,mealPicture,tags,certainty,frequency) VALUES($nextId,"$name",$carbs,$unit,"$picture","$tags",$certainty,$frequency);''');
      logger.info("New meal $name has been created successfully.");

      return nextId;
    } else {
      logger.info("Couldn't create meal. Meal already exists.");
      return -1;
    }
  }

  getNextMealId() async {
  Database? mydb = await db;
  var result = await mydb!.rawQuery('SELECT MAX(mealId) as maxId FROM Meals');
  if (result.isNotEmpty) {
    int maxId = result.first['maxId'] as int;
    return maxId + 1;
  }
  return 1; // return 1 if the Meals table is empty
}

//Create meal composition of a parent Meal and a child meal
  createMealComposition(
      int parentMealId, int childMealId, int unit, double quantity) async {
         print("entered meal composition");
    Database? mydb = await db;
    int response = await mydb!.rawInsert('''
  INSERT INTO MealComposition(parentMealId,childMealId,quantity,unit)
  VALUES($parentMealId,$childMealId,$quantity,$unit);
  ''');
    logger.info(
        "Meal composition for the 'Meals Editing' has been created successfully.");
    return response;
  }

//Creates a new edited meal and makes its meal composition(The child meal should include new parent meal id)
//child meals: id, quantity, unit
  editNewMeal(int parentMealId,String mealName, String picture, List<Map> childMeals) async{
    
    List<Map> response = await getMealById(parentMealId);

    if(mealName == null || mealName == "") {
      mealName = "My ${response[0]['mealName']}";
    }

    int newMealID= await createNewMeal(
        mealName,
        response[0]['carbohydrates'],
        response[0]['unit'],
        picture,
        response[0]['tags'] + ', myMeals');

    print(newMealID);

    if(newMealID!=-1){
      print("inside if");
      if (childMeals != null) {
      childMeals.forEach((element) {
      createMealComposition(
          newMealID, element['mealID'], element['unit'], element['quantity']);
    });
      }
    logger.info("Meal has been edited successfully.");
    }
    else{
      logger.info("Error meal wasn't edited.");
    }
    
  }

  Future<void> syncMeals() async {
    logger.info("Syncing meals...");
    DBHelper dbHelper = DBHelper.instance;

// Fetch data from the server
    var response = await http.get(Uri.parse('http://$localhost:8000/meals'));
    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      var meals = jsonDecode(response.body);
      final Database? db = await dbHelper.db;
      for (var meal in meals) {
        await db?.insert(
          'Meals',
          meal,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      logger.info("Meals have been synced successfully.");
      // Now you can use meals to insert data into the database
    } else {
      // If the server returns an error response, throw an exception.
      throw Exception('Failed to load meals');
    }
  }

  Future<void> syncMealComposition() async {
    logger.info("Syncing meal compositions...");
    DBHelper dbHelper = DBHelper.instance;
    // Fetch the MealComposition data from the server
    var response =
        await http.get(Uri.parse('http://$localhost:8000/MealComposition'));

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON
      var mealCompositionData = jsonDecode(response.body);

      // Get a reference to the database
      final Database? db = await dbHelper.db;

      // For each meal composition in the data, update the database
      for (var mealComposition in mealCompositionData) {
        await db?.insert(
          'MealComposition',
          mealComposition,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      logger.info("Meal compositions have been synced successfully.");
    } else {
      // If the server returns a response with a status code other than 200,
      // throw an exception
      throw Exception('Failed to load meal composition');
    }
  }

  searchMeal(String input) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT mealId FROM "Meals" WHERE mealName = $input OR tags LIKE '%$input%';
    ''');
    return response;
  }

/*
1 -> drinks
2 -> sweets & snacks
3 -> pastries
4 -> dairy products
5 -> fruits
6 -> lebanese dishes
7 -> arabic desserts
8 -> grains, pasta & rice
9 -> breakfast
10 -> lunch
11 -> dinner
12 -> myMeals
*/
  chooseCategory(int input) {
    String response = "";
    switch (input) {
      case 1:
        response = "drinks";
        break;
      case 2:
        response = "sweet & snacks";
        break;
      case 3:
        response = "bread & pastries";
        break;
      case 4:
        response = "dairy products";
        break;
      case 5:
        response = "fruits";
        break;
      case 6:
        response = "lebanese dishes";
        break;
      case 7:
        response = "arabic desserts";
        break;
      case 8:
        response = "grains, pasta & rice";
        break;
      case 9:
        response = "breakfast";
        break;
      case 10:
        response = "lunch";
        break;
      case 11:
        response = "dinner";
        break;
      case 12:
        response = "myMeals";
        break;
      default:
        return "";
    }
    logger.info("Category $response has been chosen.");
    return searchMeal(response);
  }

  updateFrequency(int mealId) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate('''
    UPDATE Meals SET frequency = frequency + 1;
    WHERE mealId = $mealId
    ''');
    logger.info("Frequency for meal $mealId has been updated successfully.");
    return response;
  }
}
