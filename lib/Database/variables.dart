import 'package:shared_preferences/shared_preferences.dart';

Future<void> savePreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setInt('targetBloodSugar', targetBloodSugar_);
  await prefs.setInt('insulinSensitivity', insulinSensitivity_);
  await prefs.setDouble('carbRatio', carbRatio_);
  await prefs.setDouble('carbRatio2', carbRatio_2);
  await prefs.setDouble('carbRatio3', carbRatio_3);
  await prefs.setString('username', username_);
  await prefs.setString('firstName', firstName_);
  await prefs.setString('lastName', lastName_);
  await prefs.setString('email', email_);
  await prefs.setBool('signedIn', signedIn_);
  await prefs.setString('doctorCode', doctorCode_);
  await prefs.setString('phoneNumber', phoneNumber_);
  await prefs.setString('profilePicture', profilePicture_);
  await prefs.setString('privacy', privacy_);
  await prefs.setInt('selectedPlan_', selectedPlan_);
}

Future<void> saveValues() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('numOfRatios', numOfRatios_);
  await prefs.setInt('targetBloodSugar', targetBloodSugar_);
  await prefs.setInt('insulinSensitivity', insulinSensitivity_);
  await prefs.setDouble('carbRatio', carbRatio_);
  await prefs.setDouble('carbRatio2', carbRatio_2);
  await prefs.setDouble('carbRatio3', carbRatio_3);
  await prefs.setDouble('carbs', carbs_);
  await prefs.setDouble('insulin', insulin_);
  await prefs.setDouble('carbs2', carbs_2);
  await prefs.setDouble('insulin2', insulin_2);
  await prefs.setDouble('carbs3', carbs_3);
  await prefs.setDouble('insulin3', insulin_3);
  await prefs.setString('username', username_);
  await prefs.setString('privacy', privacy_);
}

Future<void> savePrivacy() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('privacy', privacy_);
}

Future<void> saveUnits() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('glucoseUnit', glucoseUnit_);
  await prefs.setInt('carbUnit', carbUnit_);
}

Future<void> saveProfile() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('profilePicture', profilePicture_);
  await prefs.setString('username', username_);
  await prefs.setString('email', email_);
  await prefs.setString('phoneNumber', phoneNumber_);
}

Future<void> saveP() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('profilePicture', profilePicture_);
}

Future<void> saveU() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('username', username_);
}

Future<void> saveE() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString('email', email_);
}

Future<void> saveN() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setString('phoneNumber', phoneNumber_);
}

Future<void> loadPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  targetBloodSugar_ = prefs.getInt('targetBloodSugar') ?? 100;
  pid_ = prefs.getInt('pid_') ?? 0;
  insulinSensitivity_ = prefs.getInt('insulinSensitivity') ?? 20;
  carbRatio_ = prefs.getDouble('carbRatio') ?? 3;
  carbRatio_2 = prefs.getDouble('carbRatio2') ?? 0;
  carbRatio_3 = prefs.getDouble('carbRatio3') ?? 0;
  username_ = prefs.getString('username') ?? "";
  firstName_ = prefs.getString('firstName') ?? "";
  lastName_ = prefs.getString('lastName') ?? "";
  email_ = prefs.getString('email') ?? "";
  signedIn_ = prefs.getBool('signedIn') ?? false;
  doctorCode_ = prefs.getString('doctorCode') ?? "";
  phoneNumber_ = prefs.getString('phoneNumber') ?? "7686431";
  profilePicture_ = prefs.getString('profilePicture') ?? "";
  privacy_ = prefs.getString('privacy') ?? "111";
  glucoseUnit_ = prefs.getInt('glucoseUnit') ?? 0;
  carbUnit_ = prefs.getInt('carbUnit') ?? 0;
  carbs_ = prefs.getDouble('carbs') ?? 15;
  insulin_ = prefs.getDouble('insulin') ?? carbRatio_;
  carbs_2 = prefs.getDouble('carbs2') ?? 15;
  insulin_3 = prefs.getDouble('insulin2') ?? carbRatio_2;
  carbs_3 = prefs.getDouble('carbs3') ?? 15;
  insulin_3 = prefs.getDouble('insulin3') ?? carbRatio_3;
  selectedPlan_ = prefs.getInt('selectedPlan_') ?? -1;
  numOfRatios_ = prefs.getInt('numOfRatios') ?? 1;
}

//0 mmol/L
//1 mg/dL
int targetBloodSugar_ = 100;
int insulinSensitivity_ = 20;
double carbRatio_ = 3;
double carbRatio_2 = 3;
double carbRatio_3 = 3;
String username_ = "";
String firstName_ = "";
String lastName_ = "";
String email_ = "";
bool signedIn_ = false;
String doctorCode_ = "";
String phoneNumber_ = "";
String profilePicture_ = "";
int pid_ = 0;
String privacy_ = "111";
int glucoseUnit_ = 0;
int carbUnit_ = 0;
double carbs_ = 0;
double insulin_ = 0;
double carbs_2 = 0;
double insulin_2 = 0;
double carbs_3 = 0;
double insulin_3 = 0;
int selectedPlan_ = -1;
int numOfRatios_ = 1;
