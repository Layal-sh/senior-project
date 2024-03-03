int calculateDosage(List<Map> meals, int bloodSugar) {
  int ans = 0;
  int targetBloodSugar = 100; //NEED A DB FUNCTION FOR THIS
  int insulinSensitivity = 20; //NEED A DB FUNCTION FOR THIS
  double carbRatio = 3; //ALSO NEEDS A DB FUNCTION FOR THIS
  double totalCarbs = 0;
  for (Map meal in meals) {
    totalCarbs += meal["carbohydrates"];
  }
  ans += (bloodSugar - targetBloodSugar) * insulinSensitivity;
  ans += ((totalCarbs / 15) * carbRatio) as int;
  return ans;
}
