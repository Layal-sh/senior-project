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
        onCreate: _onCreate, version: 4, onUpgrade: _onUpgrade);
    return database;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {}

  _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE "Entry"(
    entryId INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
    patientId INTEGER NOT NULL,
    glucoseLevel REAL NOT NULL,
    insulinDosage INTEGER NULL,
    entryDate TEXT NOT NULL
  );
  ''');
    await db.execute('''
  CREATE TABLE "Meals"(
    mealId INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
    mealName TEXT NOT NULL,
    mealPicture TEXT NULL,
    unit INTEGER NOT NULL,
    carbohydrates REAL NOT NULL,
    tags TEXT NULL,
    certainty REAL NULL
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
    // response.forEach((element) {
    //   print(element['mealName']);
    // });
    return response;
  }

  //create an entry for the insulin dosage
  createEntry(int pid, double glucose, int insulin, String date,
      List<Map> meals) async {
    logger.info("Entered functino");
    Database? mydb = await db;
    print('$pid $glucose $insulin $date');
    int response = await mydb!.rawInsert('''
  INSERT INTO Entry (patientId, glucoseLevel, insulinDosage, entryDate)
  VALUES($pid,$glucose,$insulin,$date);
  ''');
    int entryID = getEntryId(pid, date);
    print(entryID);
    meals.forEach((element) {
      mydb.rawInsert('''
  INSERT INTO hasMeal (entryId,mealId,quantity)
  VALUES($entryID,${element['mealId']},${element['quantity']});
  ''');
    });
    return response;
  }

  //this is for testing hasMeal
  selectAllHasMeals() async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
  SELECT * FROM "hasMeal";
   ''');
    print(response);
    return response;
  }

  selectAllMealComposition() async {
    Database? mydb = await db;
    List<Map> response =
        await mydb!.rawQuery('''select * from MealComposition''');
    print(response);
    return response;
  }

  selectMealCompositionById(int id) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(
        '''select c.childMealID, m.mealName, m.carbohydrates, c.quantity
	from Meals as m, MealComposition as c
	where m.mealId=c.childMealID and c.parentMealID=$id''');
    //display the meal composition
    print(response);
    return response;
  }

  getEntryId(int pid, String date) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
      SELECT entryId from Entry
      WHERE entryDate like $date and patientID = $pid
      ''');
    return response[0]['entryId'];
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
    return ings;
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
}
