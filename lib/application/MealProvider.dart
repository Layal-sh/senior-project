import 'package:flutter/foundation.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/main.dart';

DBHelper db = DBHelper.instance;

class MealProvider extends ChangeNotifier {
  List<Map> _chosenMeals = [];

  List<Map> get getChosenMeals => _chosenMeals;

  void addToChosenMeals(int id, double quantity) async {
    List<Map> meal = await db.getMealById(id);
    var imageUrl = 'assets/' + (meal[0]['mealPicture'] ?? 'AddDish.png');
    Map<String, dynamic> insertedMeal = {
      'name': meal[0]['mealName'],
      'imageUrl': imageUrl,
      'id': id,
      'carbohydrates': meal[0]['carbohydrates'],
      'certainty': meal[0]['certainty'],
      'quantity': quantity,
      'unit': meal[0]['unit']
    };
    _chosenMeals.add(insertedMeal);
    logger.info(
        "Added meal to chosen meals --> name: ${insertedMeal['name']} carbs: ${insertedMeal['carbohydrates']} quantity: ${insertedMeal['quantity']} unit: ${insertedMeal['unit']} certainty: ${insertedMeal['certainty']}");
    notifyListeners();
  }

  double getChosenMealsQuantity(int id) {
    double quantity = 0;
    for (int i = 0; i < _chosenMeals.length; i++) {
      if (_chosenMeals[i]['id'] == id) {
        quantity += _chosenMeals[i]['quantity'];
      }
    }
    return quantity;
  }

  int get getChosenMealsLength => _chosenMeals.length;
  double get getChosenMealsCarbs {
    double carbs = 0;
    for (int i = 0; i < _chosenMeals.length; i++) {
      carbs += _chosenMeals[i]['carbohydrates'] * _chosenMeals[i]['quantity'];
    }
    return carbs;
  }

  void updateChosenMealQuantity(int index, int newQuantity) {
    if (index >= 0 && index < _chosenMeals.length) {
      _chosenMeals[index]['quantity'] = newQuantity.toDouble();
      notifyListeners();
    }
  }

  void increaseChosenMealQuantity(int index) {
    if (index >= 0 && index < _chosenMeals.length) {
      _chosenMeals[index]['quantity'] += 1;
      notifyListeners();
    }
  }

  void decreaseChosenMealQuantity(int index) {
    if (index >= 0 && index < _chosenMeals.length) {
      if (_chosenMeals[index]['quantity'] > 1) {
        _chosenMeals[index]['quantity'] -= 1;
        notifyListeners();
      } else {
        _chosenMeals.removeAt(index);
        notifyListeners();
      }
    }
  }

  void removeChosenMeal(int index) {
    if (index >= 0 && index < _chosenMeals.length) {
      _chosenMeals.removeAt(index);
      notifyListeners();
    }
  }

  void clearChosenMeals() {
    _chosenMeals.clear();
    notifyListeners();
  }

  List<Map> getChosenMealsList() {
    return List<Map>.from(_chosenMeals);
  }
}
