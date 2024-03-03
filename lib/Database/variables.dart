import 'package:shared_preferences/shared_preferences.dart';

Future<void> savePreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await prefs.setInt('targetBloodSugar', targetBloodSugar_);
  await prefs.setInt('insulinSensitivity', insulinSensitivity_);
  await prefs.setDouble('carbRatio', carbRatio_);
  await prefs.setString('username', username_);
  await prefs.setString('firstName', firstName_);
  await prefs.setString('lastName', lastName_);
  await prefs.setString('email', email_);
  await prefs.setBool('signedIn', signedIn_);
  await prefs.setString('doctorCode', doctorCode_);
  await prefs.setString('phoneNumber', phoneNumber_);
  await prefs.setString('profilePicture', profilePicture_);
}

Future<void> loadPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  targetBloodSugar_ = prefs.getInt('targetBloodSugar') ?? 0;
  insulinSensitivity_ = prefs.getInt('insulinSensitivity') ?? 0;
  carbRatio_ = prefs.getDouble('carbRatio') ?? 0;
  username_ = prefs.getString('username') ?? "";
  firstName_ = prefs.getString('firstName') ?? "";
  lastName_ = prefs.getString('lastName') ?? "";
  email_ = prefs.getString('email') ?? "";
  signedIn_ = prefs.getBool('signedIn') ?? false;
  doctorCode_ = prefs.getString('doctorCode') ?? "";
  phoneNumber_ = prefs.getString('phoneNumber') ?? "";
  profilePicture_ = prefs.getString('profilePicture') ?? "";
}

int targetBloodSugar_ = 0;
int insulinSensitivity_ = 0;
double carbRatio_ = 0;
String username_ = "";
String firstName_ = "";
String lastName_ = "";
String email_ = "";
bool signedIn_ = false;
String doctorCode_ = "";
String phoneNumber_ = "";
String profilePicture_ = "";
