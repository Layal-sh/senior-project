import 'package:sugar_sense/Database/variables.dart';

int calculateDosage(List<Map> meals, int bloodSugar) {
  int ans = 0;
  double totalCarbs = 0;
  for (Map meal in meals) {
    totalCarbs += meal["carbohydrates"];
  }
  ans += (bloodSugar - targetBloodSugar_) * insulinSensitivity_;
  ans += ((totalCarbs / 15) * carbRatio_) as int;
  return ans;
}
