import 'package:sugar_sense/Database/variables.dart';

int calculateDosage(List<Map> meals, double bloodSugar) {
  double ans = 0;
  double totalCarbs = 0;
  for (Map meal in meals) {
    totalCarbs += meal["carbohydrates"] * meal["quantity"];
  }
  ans += (bloodSugar - targetBloodSugar_) / insulinSensitivity_;
  ans += ((totalCarbs / 15) * carbRatio_);
  return (ans).round();
}
