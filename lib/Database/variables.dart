import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:sugar_sense/main.dart';

Future<void> saveStringList(List<String> stringList) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setStringList('deleteEntryList', stringList);
}

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
  await prefs.setBool('signedIn', isLoggedIn);
  await prefs.setString('doctorCode', doctorCode_);
  await prefs.setString('phoneNumber', phoneNumber_);
  await prefs.setString('profilePicture', profilePicture_);
  await prefs.setString('privacy', privacy_);
  await prefs.setInt('selectedPlan_', selectedPlan_);
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

Future<void> loadPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  syncedInsulin_ = prefs.getBool('syncedInsulin') ?? true;
  syncedRatios_ = prefs.getBool('syncedRatios') ?? true;
  syncedTarget_ = prefs.getBool('syncedTarget') ?? true;
  syncedPrivacy_ = prefs.getBool('syncedPrivacy') ?? true;
  targetBloodSugar_ = prefs.getInt('targetBloodSugar') ?? 100;
  pid_ = prefs.getInt('pid') ?? -1;
  insulinSensitivity_ = prefs.getInt('insulinSensitivity') ?? 20;
  carbRatio_ = prefs.getDouble('carbRatio') ?? 3;
  carbRatio_2 = prefs.getDouble('carbRatio2') ?? 0;
  carbRatio_3 = prefs.getDouble('carbRatio3') ?? 0;
  username_ = prefs.getString('username') ?? "";
  firstName_ = prefs.getString('firstName') ?? "";
  lastName_ = prefs.getString('lastName') ?? "";
  email_ = prefs.getString('email') ?? "";
  isLoggedIn = prefs.getBool('signedIn') ?? false;
  doctorCode_ = prefs.getString('doctorCode') ?? "";
  doctorName_ = prefs.getString('doctorName') ?? "";
  phoneNumber_ = prefs.getString('phoneNumber') ?? "";
  profilePicture_ = prefs.getString('profilePicture') ?? "";
  privacy_ = prefs.getString('privacy') ?? "111";
  glucoseUnit_ = prefs.getInt('glucoseUnit') ?? 0;
  carbUnit_ = prefs.getInt('carbUnit') ?? 0;
  carbs_ = prefs.getDouble('carbs') ?? 15;
  insulin_ = prefs.getDouble('insulin') ?? carbRatio_;
  carbs_2 = prefs.getDouble('carbs2') ?? 15;
  insulin_2 = prefs.getDouble('insulin2') ?? carbRatio_2;
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
String doctorCode_ = "";
String doctorName_ = "";
String phoneNumber_ = "";
String profilePicture_ = "";
int pid_ = -1;
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
String nextLoginTime_ = "";
String birthDate_ = "";
String twentyTwoYearsLater_ = "";
String nextAppointment_ = "";
bool isLoggedIn = false;
setLoginTime() {
  DateTime now = DateTime.now();
  nextLoginTime_ = now.add(const Duration(days: 30)).toString();
}

checkLoginTime() {
  DateTime now = DateTime.now();
  if (nextLoginTime_ == "") {
    return false;
  }
  DateTime nextLoginTime = DateTime.parse(nextLoginTime_);
  if (now.isAfter(nextLoginTime)) {
    return false;
  }

  return true;
//if it returns false then it forces him to go to the login, if it's true then it takes him to the dashboard immediately.
}

Future<bool> isConnectedToWifi() async {
  return true;
  // try {
  //   final response = await http.get(Uri.parse('http://www.google.com'));
  //   if (response.statusCode == 200) {
  //     return true;
  //   } else {
  //     return false;
  //   }
  // } catch (_) {
  //   return false;
  // }
}

Future<bool> changeDoctor(String doctorCode) async {
  try {
    var response = await http.get(
        Uri.parse('http://$localhost:8000/changeDoctor/$doctorCode/$pid_'));
    if (response.statusCode == 200) {
      doctorCode_ = doctorCode;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('doctorCode', doctorCode_);
      var responseBody = jsonDecode(response.body);
      if (responseBody['message'] == 'added') {
        doctorName_ =
            responseBody['firstName'] + ' ' + responseBody['lastName'];
      } else {
        doctorName_ = "";
      }
      await prefs.setString('doctorName', doctorName_);
      return true;
    } else {
      return false;
    }
  } catch (e) {
    logger.warning('HTTP request failed: $e');
    return false;
  }
}
/////////////////////////////////////////////////////////////////////////////
/////////////////SYNCING AAAAAAAAAAAAAAAAAAAAAAAAAAAAAA//////////////////////
/////////////////////////////////////////////////////////////////////////////

bool syncedRatios_ = true;
bool syncedTarget_ = true;
bool syncedInsulin_ = true;
bool syncedPrivacy_ = true;

Future<void> saveCarbRatios() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('numOfRatios', numOfRatios_);
  await prefs.setDouble('carbRatio', carbRatio_);
  await prefs.setDouble('carbRatio2', carbRatio_2);
  await prefs.setDouble('carbRatio3', carbRatio_3);
  await prefs.setDouble('carbs', carbs_);
  await prefs.setDouble('insulin', insulin_);
  await prefs.setDouble('carbs2', carbs_2);
  await prefs.setDouble('insulin2', insulin_2);
  await prefs.setDouble('carbs3', carbs_3);
  await prefs.setDouble('insulin3', insulin_3);
  await prefs.setBool('syncedRatios', false);

  try {
    final result = await http.get(Uri.parse(
        'http://$localhost:8000/changeCarbRatios/$carbRatio_/$carbRatio_2/$carbRatio_3/$pid_'));
    if (result.statusCode == 200) {
      logger.info("Carb Ratios synced successfully");
      await prefs.setBool('syncedRatios', true);
    }
  } catch (e) {
    logger.warning(e);
  }
}

Future<void> saveTarget() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('targetBloodSugar', targetBloodSugar_);
  await prefs.setBool('syncedTarget', false);
  try {
    final result = await http.get(Uri.parse(
        'http://$localhost:8000/changeTargetGlucose/$targetBloodSugar_/$pid_'));
    if (result.statusCode == 200) {
      logger.info("Target Blood Sugar synced successfully");
      await prefs.setBool('syncedTarget', true);
    }
  } catch (e) {
    logger.warning(e);
  }
}

Future<void> saveInsulinSensitivity() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('insulinSensitivity', insulinSensitivity_);
  await prefs.setBool('syncedInsulin', false);
  try {
    final result = await http.get(Uri.parse(
        'http://$localhost:8000/changeInsulinSensitivity/$insulinSensitivity_/$pid_'));
    if (result.statusCode == 200) {
      logger.info("Insulin Sensitivity synced successfully");
      await prefs.setBool('syncedInsulin', true);
    }
  } catch (e) {
    logger.warning(e);
  }
}

Future<void> savePrivacy() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('privacy', privacy_);
  await prefs.setBool('syncedPrivacy', false);
  try {
    final result = await http
        .get(Uri.parse('http://$localhost:8000/changePrivacy/$privacy_/$pid_'));
    if (result.statusCode == 200) {
      logger.info("Privacy synced successfully");
      await prefs.setBool('syncedPrivacy', true);
    }
  } catch (e) {
    logger.warning(e);
  }
}
