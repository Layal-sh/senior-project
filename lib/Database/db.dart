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
        onCreate: _onCreate, version: 2, onUpgrade: _onUpgrade);
    return database;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {}

  _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE "Patients"(
    patientId INTEGER NOT NULL PRIMARY KEY,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    userName TEXT NOT NULL,
    email TEXT NOT NULL,
    userPassword TEXT NOT NULL,
    doctorId TEXT NULL,
	  phoneNumber INTEGER NULL,
	  profilePhoto TEXT NULL, 
	  insulinSensivity REAL NOT NULL,
	  carbRatio REAL NOT NULL,
    carbRatio2 REAL NULL,
    carbRatio3 REAL NULL
  );
  ''');
    await db.execute('''
  CREATE TABLE "Entry"(
    entryId INTEGER IDENTITY(1,1) NOT NULL PRIMARY KEY,
    patientId INTEGER NOT NULL,
    glucoseLevel REAL NOT NULL,
    insulinDosage INTEGER NULL,
    entryDate TEXT NOT NULL,
    FOREIGN KEY(patientId) REFERENCES Patients(patientId)
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
    FOREIGN KEY(patientId) REFERENCES Patients(patientId),
    FOREIGN KEY(articleId) REFERENCES Articles(articleId),
    PRIMARY KEY(patientId,articleId)
  );
  ''');
  }

  readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    return response;
  }

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

  //adding new user info to local database
   signUp(int pid, String fname,String lname, String uname,String em,String pass, String docid, double insulinSen,double carbRatio) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert('''
  INSERT INTO "Patients" (patientId, firstName, lastName, userName, email, userPassword, doctorId, insulinSensitivity, carboRatio)
  VALUES($pid,$fname,$lname,$uname,$em,$pass,$docid,$insulinSen,$carbRatio);
  ''');
    return response;
  }
  
  //get all meals from local database for adding inputs
   selectAllMeals() async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery('''
  SELECT * FROM "Meals";
   ''');
   //print(response);
    return response;
  }

  //create an entry for the insulin dosage
  createEntry(int pid, double glucose,int insulin, String date) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert('''
  INSERT INTO "Entry"(patientId, glucodeLevel, insulinDosage, entryDate)
  VALUES($pid,$glucose,$insulin,$date);
  ''');
    return response;
  }

  //create hasMeal for each entry
  createMealForEntry(int entryId, int mealId, int qtty, int unit) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert('''
  INSERT INTO "hasMeal"(entryId,mealId,quantity,unit)
  VALUES($entryId,$mealId,$qtty,$unit);
  ''');
    return response;
  }

  

  Future<void> syncMeals() async {
    logger.info("we syncin frfr");
    DBHelper dbHelper = DBHelper.instance;

// Fetch data from the server
    var response = await http.get(Uri.parse('http://localhost:8000/meals'));
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
      // Now you can use meals to insert data into the database
    } else {
      // If the server returns an error response, throw an exception.
      throw Exception('Failed to load meals');
    }
  }
}
