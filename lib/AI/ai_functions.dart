import 'package:sugar_sense/Database/variables.dart';

double calculateDosage(List<Map> meals, double bloodSugar) {
  double ans = 0;
  double totalCarbs = 0;
  for (Map meal in meals) {
    totalCarbs += meal["carbohydrates"];
  }
  //ans += (bloodSugar - targetBloodSugar_) * insulinSensitivity_;
  //ans += ((totalCarbs / 15) * carbRatio_);
  ans += (bloodSugar - 100) * 1;
  ans += ((totalCarbs / 15) * 1);
  return ans;
}
