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
  if ((bloodSugar - targetBloodSugar_).abs() <= insulinSensitivity_) {
    DBHelper dbHelper = DBHelper.instance;
    int prevEntryId = await dbHelper.getLatestEntryId();
    List<Map> hasMeals = await dbHelper.getMealsFromEntryID(prevEntryId);
    List<Map> meals = [];
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
