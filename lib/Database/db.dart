// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';

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
        onCreate: _onCreate, version: 32, onUpgrade: _onUpgrade);
    return database;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('''
      ALTER TABLE Entry ADD COLUMN unit INTEGER NULL;
      ''');
      await db.execute('''DROP TABLE IF EXISTS "Favorites";''');
      print("Dropped Favorites table");
      await db.execute('''DROP TABLE IF EXISTS "Articles";''');
      print("Dropped Articles table");
      await db.execute('''
      CREATE TABLE "Articles"(
        url TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        imageUrl TEXT NULL,
        date TEXT NULL
      );
      ''');
      print("Created Articles table");
    }
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
        url TEXT NOT NULL PRIMARY KEY,
        title TEXT NOT NULL,
        imageUrl TEXT NULL,
        date TEXT NULL
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

  ////////////////////////////////////////////////////////////
  ////////////////// Instructions ////////////////////////////
  ////////////////////////////////////////////////////////////
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

//////////////////////////////////////////////////////////////
  /////////////// Fixing for Sign up///////////////////////////
  //////////////////////////////////////////////////////////////
  deleteMealComposition() async {
    logger.info("Deleting Meal Composition...");
    Database? mydb = await db;
    int response = await mydb!.rawDelete('''
    DELETE FROM MealComposition;
''');
    return response;
  }

  dropAllArticles() async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete('''
    DELETE FROM Articles;
    ''');
    return response;
  }

  ////////////////////////////////////////////////////////////
  /////////////// Display of Meals///////////////////////////
  ////////////////////////////////////////////////////////////

//get all meals from local database for adding inputs
  Future<List<Map>> selectAllMeals() async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
  SELECT * FROM "Meals";
   ''');
    logger.info("All meals have been fetched successfully.");
    return response;
  }

  selectAllMealComposition() async {
    Database? mydb = await db;
    List<Map> response =
        await mydb!.rawQuery('''select * from MealComposition''');
    logger.info("All meal compositions have been fetched successfully.");
    return response;
  }

  Future<List<Map>> getIngredients(int parentId) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
      SELECT m1.mealName, m1.mealID, m1.carbohydrates , c.unit, c.quantity 
  FROM Meals AS m, Meals AS m1, MealComposition AS c
  WHERE m.mealID=c.parentMealID AND m1.mealID=c.childMealID AND m.mealID=$parentId;
    ''');
    logger
        .info("Ingredients for meal $parentId have been fetched successfully.");
    return response;
  }

  Future<List<Map>> displayMostFrequentMeals(int top) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * FROM "Meals" ORDER BY frequency DESC LIMIT ?;
    ''', [top]);
    return response;
  }

  //////////////////////////////////////////////////////////////////////
  /////////////// Retreive Meals by Id or Name///////////////////////////
  /////////////////////////////////////////////////////////////////////

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

  getMealByName(String name) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT mealId FROM "Meals" WHERE mealName = "$name";
    ''');
    return response;
  }

  getMealById(int id) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * FROM "Meals" WHERE mealId = $id;
    ''');
    return response;
  }

  deleteMealById(String mealName) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete('''
    DELETE FROM Meals WHERE mealName = "$mealName";
    ''');
    return response;
  }

  ////////////////////////////////////////////////////////////
  /////////////// Functions For AI///////////////////////////
  ////////////////////////////////////////////////////////////

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

  updateMealById(int mealId, double carbs, double certainty) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate('''
    UPDATE Meals SET carbohydrate = $carbs , certainty = $certainty
    WHERE mealId = $mealId
    ''');
    logger.info("Meal $mealId has been updated successfully.");
    return response;
  }

  ////////////////////////////////////////////////////////////
  /////////////// Create Entrires with its Meals /////////////
  ////////////////////////////////////////////////////////////

  generateNewEntry(double glucose, int insulin, String date, int unit) async {
    Database? mydb = await db;
    int entryId = await mydb!.rawInsert('''
  INSERT INTO Entry (glucoseLevel, insulinDosage, entryDate, unit)
  VALUES($glucose,$insulin,'$date',$unit);
  ''');
    if (entryId > 0) {
      var latestEntry = await getLatestEntryId(1);
      return latestEntry[0]['entryId'];
    } else {
      return -1;
    }
  }

  generateHasMeals(int idEntry, List<Map> meals) async {
    bool hasmeal = false;

    await Future.wait(meals.map((element) async {
      int response = await createMealForEntry(
          idEntry, element['id'], element['quantity'], element['unit']);

      logger.info("hasMeal of ${element['id']} has been created successfully.");

      if (response > 0) {
        await updateFrequency(element['id']);
        hasmeal = true;
      } else {
        logger.info("has meal didnt work");
        hasmeal = false;
      }
    }));
    return hasmeal;
  }

  //0 mmol/L
  //1 mg/dL
  //create an entry for the insulin dosage
  createEntry(double glucose, int insulin, String date, List<Map> meals,
      int unit) async {
    Database? mydb = await db;
    int idEntry = await generateNewEntry(glucose, insulin, date, unit);

    bool generate = await generateHasMeals(idEntry, List<Map>.from(meals));
    if (generate) {
      logger.info("Created entry with id $idEntry");
      return true;
    }

    return idEntry;
  }

  //create hasMeal for each entry
  createMealForEntry(int entryId, int mealId, double qtty, int unit) async {
    logger.info("entered cretae meal for entry");
    Database? mydb = await db;
    int response = await mydb!.rawInsert('''
  INSERT INTO "hasMeal"(entryId,mealId,quantity,unit)
  VALUES($entryId,$mealId,$qtty,$unit);
  ''');

    if (response > 0)
      logger.info("meal was add to entry $entryId");
    else {
      logger.info("meal couldn't be added add to entry $entryId");
    }
    return response;
  }

  // updateFrequency(int mealId) async {
  //   Database? mydb = await db;
  //   int response = await mydb!.rawUpdate('''
  //   UPDATE Meals SET frequency = frequency + 1;
  //   WHERE mealId = $mealId
  //   ''');
  //   logger.info("Frequency for meal $mealId has been updated successfully.");
  //   return response;
  // }

  updateFrequency(int mealId) async {
    Database? mydb = await db;
    await mydb!.rawUpdate('''
    UPDATE Meals
    SET frequency = frequency + 1
    WHERE mealId = ?
  ''', [mealId]);
    logger.info("Meal with id: $mealId increased in frequency");
  }

  //////////////////////////////////////////////////////////////////////
  /////////////// Functions related to Entries///////////////////////////
  /////////////////////////////////////////////////////////////////////
  getMealsFromEntryID(int entryId) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * FROM "hasMeal" WHERE entryId = $entryId;
    ''');
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

  getLatestEntryId(int n) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * from Entry 
    ORDER BY entryDate DESC
    LIMIT $n
    ''');
    return response;
  }

  // insertEntry(double glucose, int insulin, String date) async {
  //   Database? mydb = await db;
  //   int response = await mydb!.rawInsert('''
  //   INSERT INTO Entry(glucoseLevel, insulinDosage, entryDate)
  //   VALUES($glucose, $insulin, "$date");
  //   ''');
  //   return response;
  // }
  getAllEntries() async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * from Entry 
    ORDER BY entryDate
    ''');
    return response;
  }

  getEntriesDaily() async {
    Database? mydb = await db;
    var res = await mydb!.rawQuery('''
    SELECT * FROM Entry WHERE substr(entryDate, 1, 10) = date('now')
  ''');
    return res;
  }

  getEntriesWeekly() async {
    Database? mydb = await db;
    var res = await mydb!.rawQuery('''
    SELECT * FROM Entry WHERE substr(entryDate, 1, 10) BETWEEN date('now', '-7 day') AND date('now')
  ''');
    return res;
  }

  getEntriesMonthly() async {
    Database? mydb = await db;
    var res = await mydb!.rawQuery('''
    SELECT * FROM Entry WHERE substr(entryDate, 1, 10) BETWEEN date('now', '-1 month') AND date('now')
  ''');
    return res;
  }

  getEntriesYearly() async {
    Database? mydb = await db;
    var res = await mydb!.rawQuery('''
    SELECT * FROM Entry WHERE substr(entryDate, 1, 10) BETWEEN date('now', '-1 year') AND date('now')
  ''');
    return res;
  }

  getLatestEntry() async {
    Database? mydb = await db;
    List<Map> response = await getLatestEntryId(1);

    if (response.isEmpty) {
      print('No entries found');
      return <String, dynamic>{}; // Return an empty map instead of null
    }

    List<Map> hasMeals = await getMealsFromEntryID(response[0]['entryId']);
    return organizeEntries(response[0], hasMeals);
  }

  /*layaaaallllllll wee didd itt:
  to get evrything: n=0
  to get for the day: n=1
  to get for the past week: n=2
  to get for the past month: n=3
  to get for the past year: n=4
  */
  Future<List<Map>> getEntries(int n) async {
    Database? mydb = await db;
    List<Map> response = [];
    if (n == 0) {
      response = await getAllEntries();
    } else if (n == 1) {
      response = await getEntriesDaily();
    } else if (n == 2) {
      response = await getEntriesWeekly();
    } else if (n == 3) {
      response = await getEntriesMonthly();
    } else if (n == 4) {
      response = await getEntriesYearly();
    }

    List<Map> allMeals = [];
    for (var entry in response) {
      List<Map> entryMeals = await getMealsFromEntryID(entry['entryId']);
      Map organized = await organizeEntries(entry, entryMeals);
      allMeals.add(organized);
    }
    return allMeals;
  }

  organizeEntries(Map response, List<Map> hasMeals) async {
    int target = 0;
    double totalCarbs = await getCarbsHasMeal(hasMeals);
    print('total carbs: $totalCarbs');

    double currentGlucose = response['glucoseLevel'];
    if (currentGlucose >= 80 && currentGlucose <= 120) {
      target = 0;
    } else if (currentGlucose < 80) {
      //hypoglycemia
      target = 1;
    } else {
      //hyperglycemia
      target = 2;
    }

    Map<String, dynamic> result = {
      'entryId': response['entryId'],
      'glucoseLevel': currentGlucose,
      'insulinDosage': response['insulinDosage'],
      'totalCarbs': totalCarbs,
      'date': response['entryDate'],
      'unit': response['unit'],
      'target': target
    };
    return result;
  }

  getCarbsHasMeal(List<Map> hasMeals) async {
    double totalCarbs = 0;

    for (var meal in hasMeals) {
      var mealId = meal['mealId'];
      var mealCarbs = await getCarbsByMealId(mealId);
      double qty = meal['quantity'];
      totalCarbs += (mealCarbs * qty);
    }

    return totalCarbs;
  }

  getCarbsByMealId(int mealId) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
      SELECT carbohydrates from Meals
      WHERE mealId = $mealId
      ''');

    return response[0]['carbohydrates'];
  }

  deleteEntryById(int entryId) async {
    await deleteHasMealById(entryId);

    Database? mydb = await db;
    int response = await mydb!.rawDelete('''
    DELETE FROM Entry WHERE entryId= $entryId;
''');
    logger.info("deleteing entry of id $entryId");
    return response;
  }

  deleteHasMealById(int entryId) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete('''
    DELETE FROM hasMeal WHERE entryId =$entryId;
''');
    if (response > 0) {
      logger.info("deleteing hasMeals of entry $entryId");
      return true;
    } else {
      return false;
    }
  }

  deleteAllEntries() async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete('''
    DELETE FROM hasMeal;
''');
    logger.info("delete evrything in hasMeals");
    int response2 = await mydb.rawDelete('''
    DELETE FROM Entry;
''');
    logger.info("delete evrything in entries");
  }

  ////////////////////////////////////////////////
  /////////////// Create & Edit Meals /////////////
  /////////////////////////////////////////////////

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

    int nextId = await getNextMealId();

    if (mealId < 0) {
      int response = await mydb!.rawInsert(
          '''INSERT INTO Meals(mealId,mealName,carbohydrates,unit,mealPicture,tags,certainty,frequency) 
          VALUES($nextId,"$name",$carbs,$unit,"$picture","$tags",$certainty,$frequency);''');
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
    print("createMealComposition Response: $response");
    return response;
  }

//Creates a new edited meal and makes its meal composition(The child meal should include new parent meal id)
//child meals: id, quantity, unit
  editNewMeal(int parentMealId, String mealName, String picture,
      List<Map> childMeals) async {
    List<Map> response = await getMealById(parentMealId);
    double totalCarbs = response[0]['carbohydrates'];

    childMeals.forEach((element) {
      totalCarbs += element['carbohydrates'] * element['quantity'];
    });

    if (mealName == null || mealName == "") {
      mealName = "My ${response[0]['mealName']}";
    }

    int newMealID = await createNewMeal(
        mealName,
        totalCarbs,
        response[0]['unit'],
        response[0]['mealPicture'],
        response[0]['tags'] + ', myMeals');

    if (newMealID != -1) {
      if (childMeals != null) {
        childMeals.forEach((element) {
          createMealComposition(newMealID, element['mealID'], element['unit'],
              element['quantity']);
        });
      }
      logger.info("Meal has been edited successfully with id $newMealID.");
      return newMealID;
    } else {
      logger.info("Error meal wasn't edited.");
      return -1;
    }
  }

// ...

// Future<int> createMeal(String mealName,  XFile? image, List<Map> childMeals, List<String> categories, double carbohydrates) async {
//   double totalCarbs = carbohydrates;
//   String picture = "All.png";

//   if (image != null) {
//     // Get the application documents directory
//     final Directory directory = await getApplicationDocumentsDirectory();

//     // Copy the image to the application documents directory
//     final File newImage = await File(image.path).copy('${directory.path}/${image.name}');

//     // Get the path to the new image
//     picture = newImage.path;
//   }

//   if (childMeals.isNotEmpty) {
//     childMeals.forEach((element) {
//       totalCarbs += element['carbohydrates'] * element['quantity'];
//     });
//   }

//   String tags = "";
//   categories.forEach((element) {
//     tags += element + ", ";
//   });
//   tags += "myMeals";

//   int newMealId = await createNewMeal(mealName, totalCarbs, 7, picture, tags);

//   return newMealId;
// }

  createMeal(String mealName, String picture, List<Map> childMeals,
      List<String> categories, double carbohydrates) async {
    double totalCarbs = carbohydrates;

    if (picture == null || picture == "") {
      picture = "All.png";
    }
    if (childMeals.isNotEmpty) {
      childMeals.forEach((element) {
        totalCarbs += element['carbohydrates'] * element['quantity'];
      });
    }
    String tags = "";
    categories.forEach((element) {
      tags += element + ", ";
    });
    tags += "myMeals";
    int newMealId = await createNewMeal(mealName, totalCarbs, 7, picture, tags);
    if (newMealId != -1) {
      if (childMeals.isNotEmpty) {
        childMeals.forEach((element) {
          createMealComposition(newMealId, element['id'], element['unit'] ?? 7,
              element['quantity']);
        });
      }
      logger.info("Meal has been edited successfully with id $newMealId.");
      return newMealId;
    } else {
      logger.info("Error meal wasn't edited.");
      return -1;
    }
  }

// // ...

  ////////////////////////////////////////////////////////////////////
  /////////////// Syncing Of Meals & Meals Composition ////////////////
  ////////////////////////////////////////////////////////////////////

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

  //////////////////////////////////////////////
  /////////////// Articles Page ////////////////
  /////////////////////////////////////////////

  checkArticle(String link) async {
     Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * FROM Articles WHERE url = "$link";
    ''');
    return response;
  }

  addFavorite(String link, String title, String? imageUrl, String? date) async {
    Database? mydb = await db;
    List<Map> chk = await checkArticle(link);
    if (chk.isNotEmpty) {
      return -1;
    } else {
      int response = await mydb!.rawInsert('''
    INSERT INTO Articles(url, title, imageUrl, date)
    VALUES("$link", "$title", "$imageUrl", "$date");
    ''');
      return response;
    }
  }

  deleteFavorite(String link) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete('''
    DELETE FROM Articles WHERE url = "$link";
    ''');
    return response;
  }

//get all articles from the database
  selectAllArticle() async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
    SELECT * FROM Articles ;
    ''');
    return response;
  }

  ///////////////////////////////////////////////////////////
  /////////////// Search for meals & category ////////////////
  ///////////////////////////////////////////////////////////

  searchMealForCatgeory(int mealId, String input) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(
        'SELECT * FROM "Meals" WHERE mealId = ? AND tags LIKE ?',
        [mealId, '%$input%']);
    if (response.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

  Future<bool> searchMealForCat(int mealId, String input) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(
        'SELECT * FROM "Meals" WHERE mealId = ? AND tags LIKE ?',
        [mealId, '%$input%']);
    if (response.isEmpty) {
      return false;
    } else {
      return true;
    }
  }

//copilot's function won over ours :(
  Future<List<Map>> searchMeal(String input) async {
    Database? mydb = await db;
    List<String> words = input.split(' '); // split the input into words

    // create a SQL query that matches each word separately
    String query = 'SELECT * FROM "Meals" WHERE ';
    for (int i = 0; i < words.length; i++) {
      query += 'mealName LIKE ? OR tags LIKE ?';
      if (i != words.length - 1) {
        query += ' OR ';
      }
    }

    // create a list of parameters for the query
    List<String> params = [];
    for (String word in words) {
      params.add('%$word%');
      params.add('%$word%');
    }

    List<Map> response = await mydb!.rawQuery(query, params);
    return response;
  }

  //////////////////////////////////////////////////////////////////
  /////////////// Search and filtering of categories ////////////////
  //////////////////////////////////////////////////////////////////
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
        response = "grains & pasta & rice";
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

  Future<List<String>> getCategoryOfMeal(int mealId) async {
    List<String> categories = [];
    if (await searchMealForCatgeory(mealId, "drinks")) {
      categories.add("drinks");
    }
    if (await searchMealForCatgeory(mealId, "sweet & snacks")) {
      categories.add("sweet & snacks");
    }
    if (await searchMealForCatgeory(mealId, "pastries")) {
      categories.add("pastries");
    }
    if (await searchMealForCatgeory(mealId, "dairy products")) {
      categories.add("dairy products");
    }
    if (await searchMealForCatgeory(mealId, "fruits")) {
      categories.add("fruits");
    }
    if (await searchMealForCatgeory(mealId, "lebanese dishes")) {
      categories.add("lebanese dishes");
    }
    if (await searchMealForCatgeory(mealId, "arabic desserts")) {
      categories.add("arabic desserts");
    }
    if (await searchMealForCatgeory(mealId, "grains & pasta & rice")) {
      categories.add("grains, pasta & rice");
    }
    return categories;
  }
}
