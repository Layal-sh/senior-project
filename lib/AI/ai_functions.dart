import 'dart:html';
import 'dart:math';

import 'package:path/path.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/Database/db.dart';

int calculateDosage(double totalCarbs, double bloodSugar) {
  double ans = 0;
  ans += (bloodSugar - targetBloodSugar_) / insulinSensitivity_;
  ans += ((totalCarbs / 15) * carbRatio_);
  return ans.round();
}

double calculateTotalCarbs(List<Map> meals) {
  double ans = 0;
  for (Map meal in meals) {
    ans += meal["carbohydrates"] * meal["quantity"];
  }
  return ans;
}

void updatePrevMeals(double bloodSugar) async {
  DBHelper dbHelper = DBHelper.instance;
  int prevEntryId = await dbHelper.getLatestEntryId();
  List<Map> hasMeals = await dbHelper.getMealsFromEntryID(prevEntryId);
  List<Map> meals = [];
  double bloodSugarDiff = bloodSugar - targetBloodSugar_;
  if ((bloodSugarDiff).abs() <= insulinSensitivity_) {
    //bro is good certainty factor goes up for all meals
    int mealCount = 0;
    for (Map mid in hasMeals) {
      Map meal = await dbHelper.getMealById(mid["mealId"])[0];
      meals.add(meal);
      mealCount++;
    }
    double alpha = sqrt(mealCount) / mealCount;
    for (Map meal in meals) {
      double newCertainty =
          meal["certainty"] + alpha * (1 - meal["certainty"]) / 2;
      await dbHelper.updateMealById(
          meal["mealId"], meal["carbohydrates"], newCertainty);
    }
  } else {
    //bro is not good carbs for each meal go up
    double totalBlame = 0;
    for (Map mid in hasMeals) {
      Map meal = await dbHelper.getMealById(mid["mealId"])[0];
      meal["quantity"] = mid["quantity"];
      double blame = meal["carbohydrates"] * (1 - meal["certainty"]);
      meal["blame"] = blame;
      totalBlame += blame * meal["quantity"];
      meals.add(meal);
    }
    double unaccountedCarbs =
        ((bloodSugarDiff / insulinSensitivity_) / carbRatio_) * 15;
    unaccountedCarbs /= 2;
    for (Map meal in meals) {
      double ratio = meal["blame"] / totalBlame;
      double newCarbs = meal["carbohydrates"] + unaccountedCarbs * ratio;
      await dbHelper.updateMealById(
          meal["mealId"], newCarbs, meal["certainty"]);
    }
  }
}

String unitString(int unit) {
  String ans = "grams";
  switch (unit) {
    case 1:
      ans = "cups";
      break;
    case 2:
      ans = "tablespoons";
      break;
    case 3:
      ans = "teaspoons";
      break;
    case 4:
      ans = "slices";
      break;
    case 5:
      ans = "pieces";
      break;
    case 6:
      ans = "scoops";
      break;
  }
  return ans;
}
