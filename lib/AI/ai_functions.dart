import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/Database/db.dart';

int calculateDosage(double totalCarbs, double bloodSugar) {
  double ans = 0;
  ans += (bloodSugar - targetBloodSugar_) / insulinSensitivity_;
  ans += ((totalCarbs / 15) * carbRatio_);
  return (ans).round();
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
}
