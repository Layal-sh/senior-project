import 'dart:math';

import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/main.dart';

int calculateDosage(double totalCarbs, double bloodSugar, double carbRatio) {
  double ans = 0;
  if (glucoseUnit_ == 0) bloodSugar = bloodSugar * 18.0156;
  ans += (bloodSugar - targetBloodSugar_) / insulinSensitivity_;
  ans += ((totalCarbs / 15) * carbRatio);
  return ans.round();
}

double calculateTotalCarbs(List<Map> meals) {
  double ans = 0;
  for (Map meal in meals) {
    ans += meal["carbohydrates"] * meal["quantity"];
  }
  return ans;
}

void updatePrevMeals(double bloodSugar, double carbRatio) async {
  DBHelper dbHelper = DBHelper.instance;
  List<Map> latestEntry = await dbHelper.getLatestEntryId(1);
  int prevEntryId = latestEntry[0]['entryId'];
  List<Map> hasMeals = await dbHelper.getMealsFromEntryID(prevEntryId);
  List<Map> meals = [];
  double bloodSugarDiff = bloodSugar - targetBloodSugar_;
  logger.info("AI working");
  if ((bloodSugarDiff).abs() <= insulinSensitivity_) {
    logger.info("Patient is good");
    //patient is good certainty factor goes up for all meals
    int mealCount = 0; //number of distinct meals
    for (Map mid in hasMeals) {
      List<Map> mealResponse = await dbHelper.getMealById(mid["id"]);
      Map meal = mealResponse[0];
      meals.add(meal);
      mealCount++;
    }
    double alpha = sqrt(mealCount) / mealCount;
    for (Map meal in meals) {
      double newCertainty = meal["certainty"] +
          alpha *
              (1 - meal["certainty"]) /
              2; //ensuring certainty does not go above 1
      await dbHelper.updateMealById(
          meal["mealId"], meal["carbohydrates"], newCertainty);
    }
  } else {
    logger.info("Patient is not good");
    //patient is not good carbs for each meal go up (or down depending if they have low or high bloodsugar)
    double totalBlame = 0;
    for (Map mid in hasMeals) {
      List<Map> mealResponse = await dbHelper.getMealById(mid["id"]);
      Map<String, dynamic> meal = Map<String, dynamic>.from(mealResponse[0]);
      meal["quantity"] = mid["quantity"];
      double blame = meal["carbohydrates"] * (1 - meal["certainty"]);
      meal["blame"] = blame;
      totalBlame += blame * meal["quantity"];
      meals.add(meal);
    }
    double unaccountedCarbs =
        ((bloodSugarDiff / insulinSensitivity_) / carbRatio) * 15;
    unaccountedCarbs /= 2; //accounting for uncontrollable factors
    logger.info("Unaccounted Carbs: $unaccountedCarbs");
    for (Map meal in meals) {
      double ratio = meal["blame"] / totalBlame;
      double newCarbs = meal["carbohydrates"] + unaccountedCarbs * ratio;
      await dbHelper.updateMealById(
          meal["mealId"], newCarbs, meal["certainty"]);
      logger.info("updated: ${meal["mealName"]} to $newCarbs");
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
    case 7:
      ans = "serving";
      break;
  }
  return ans;
}
