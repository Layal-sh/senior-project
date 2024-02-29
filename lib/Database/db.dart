import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class SqlDb {
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
        onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return database;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {}

  _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE "Users"(
    userId INTEGER AUTOINCREMENT NOT NULL PRIMARY KEY,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    userName TEXT NULL,
    email TEXT NOT NULL,
    userPassword TEXT NOT NULL
  );
  ''');
    await db.execute('''
  CREATE TABLE "Doctors"(
    doctorId INTEGER NOT NULL PRIMARY KEY ,
    FOREIGN KEY(doctorId) REFERENCES Users(userId)
  );
  ''');
    await db.execute('''
  CREATE TABLE Patients (
	  patientID INTEGER PRIMARY KEY NOT NULL,
	  doctorID INTEGER NULL,
	  phoneNumber INTEGER NOT NULL,
	  profilePhoto TEXT NULL, 
	  insulinSensivity REAL NOT NULL,
	  carbRatio REAL NOT NULL,
	  FOREIGN KEY(patientID) REFERENCES Users(userID),
	  FOREIGN KEY(doctorID) REFERENCES Doctors(doctorID)
  );
  ''');
    await db.execute('''
  CREATE TABLE "Entry"(
    entryId INTEGER AUTOINCREMENT NOT NULL PRIMARY KEY,
    patientId INTEGER NOT NULL,
    glucoseLevel REAL NOT NULL,
    insulinDosage INTEGER NULL,
    entryDate TEXT NOT NULL,
    FOREIGN KEY(patientId) REFERENCES Patients(patientId)
  );
  ''');
    await db.execute('''
  CREATE TABLE "Meals"(
    mealId INTEGER AUTOINCREMENT NOT NULL PRIMARY KEY,
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
    PRIMARY KEY(entryID,mealID)
  );
  ''');
    await db.execute('''
  CREATE TABLE "Articles"(
    articleId INTEGER AUTOINCREMENT NOT NULL PRIMARY KEY,
    link TEXT NOT NULL
  );
  ''');
    await db.execute('''
  CREATE TABLE "Favorites"(
    patientId INTEGER NOT NULL,
    articleId INTEGER NOT NULL,
    FOREIGN KEY(patientId) REFERENCES Patients(patientId),
    FOREIGN KEY(articleId) REFERENCES Articles(articleId),
    PRIMARY KEY(patientID,articleID)
  );
  ''');
    await db.execute('''
  CREATE TABLE "Administration"(
    adminId INTEGER AUTOINCREMENT NOT NULL PRIMARY KEY,
    username TEXT NOT NULL,
    adminPassword TEXT NOT NULL
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
}
