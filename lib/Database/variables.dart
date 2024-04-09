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
  await prefs.setInt('glucoseUnit', glucoseUnit_);
  await prefs.setInt('carbUnit', carbUnit_);
}

Future<void> loadPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  targetBloodSugar_ = prefs.getInt('targetBloodSugar') ?? 100;
  pid_ = prefs.getInt('pid_') ?? 0;
  insulinSensitivity_ = prefs.getInt('insulinSensitivity') ?? 20;
  carbRatio_ = prefs.getDouble('carbRatio') ?? 3;
  carbRatio_2 = prefs.getDouble('carbRatio2') ?? 4;
  carbRatio_3 = prefs.getDouble('carbRatio3') ?? 0;
  username_ = prefs.getString('username') ?? "";
  firstName_ = prefs.getString('firstName') ?? "";
  lastName_ = prefs.getString('lastName') ?? "";
  email_ = prefs.getString('email') ?? "";
  signedIn_ = prefs.getBool('signedIn') ?? false;
  doctorCode_ = prefs.getString('doctorCode') ?? "";
  phoneNumber_ = prefs.getString('phoneNumber') ?? "";
  profilePicture_ = prefs.getString('profilePicture') ?? "";
  privacy_ = prefs.getString('privacy') ?? "111";
  glucoseUnit_ = prefs.getInt('glucoseUnit') ?? 0;
  carbUnit_ = prefs.getInt('carbUnit') ?? 0;
}

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
