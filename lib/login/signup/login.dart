// ignore_for_file: use_build_context_synchronously, use_super_parameters, unused_local_variable, avoid_print, duplicate_ignore, unused_import

import 'dart:async';
import 'dart:convert';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/accCreation/membership.dart';
import 'package:sugar_sense/accCreation/userinfo.dart';
import 'package:sugar_sense/application/app.dart';
import 'package:sugar_sense/application/settings.dart';
import 'package:sugar_sense/login/signup/forgetPass/forgetpass.dart';
import 'package:sugar_sense/main.dart';
//import 'package:sugar_sense/notifications/notification.dart';
//import 'package:sugar_sense/notifications/notify.dart';
import 'package:sugar_sense/values/app_regex.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);
  //final PageController controller;
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final ValueNotifier<bool> passwordNotifier = ValueNotifier(true);
  final ValueNotifier<bool> fieldValidNotifier = ValueNotifier(false);

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;
  void initializeControllers() {
    _emailController = TextEditingController()..addListener(controllerListener);

    _passwordController = TextEditingController()
      ..addListener(controllerListener);
  }

  void disposeControllers() {
    _emailController.dispose();
    _passwordController.dispose();
  }

  void controllerListener() {
    final emailorUsername = _emailController.text;
    final password = _passwordController.text;

    if (emailorUsername.isEmpty && password.isEmpty) return;

    if ((AppRegex.emailRegex.hasMatch(emailorUsername) ||
            AppRegex.usernameRegex.hasMatch(emailorUsername)) &&
        AppRegex.passwordRegex.hasMatch(password)) {
      fieldValidNotifier.value = true;
    } else {
      fieldValidNotifier.value = false;
    }
  }

  bool _isLoading = false;
  bool eerror = false;
  bool perror = false;
  String? emailErrorMessage;
  String? passErrorMessage;
  int patientId = pid_;

  deleteListEntries() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? list = prefs.getStringList('deleteEntryList');
    if (list != null) {
      for (var element in list) {
        var response = http.delete(Uri.parse(
            "https://$localhost:8000/deleteEntry/$element/$patientId"));
      }
    }
  }

  Future<void> _signIn(String email, String password, int id) async {
    logger.info("signing in");

    //logger.info("syncing meals from the server to the local database");
    DBHelper dbHelper = DBHelper.instance;
    //dbHelper.dropAllArticles();
    //print(await dbHelper.selectAllArticle());
    // await dbHelper.deleteMealComposition();
    // //logger.info("synced meals successfully");
    await dbHelper.syncMealComposition();
    await dbHelper.syncMeals();
    // //logger.info("synced meals successfully");
    // logger.info("synced meal compositions successfully");
    // logger.info("saving values to shared preferences");

    final response = await http
        .post(
          Uri.parse('http://$localhost:8000/getUserDetails'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'username': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 10));
    //fetch entries from the server
    await dbHelper.dropEntries();
    await dbHelper.syncEntriesById(id);
    if (response.statusCode == 200) {
      // logger.info('Response body: ${response.body}');
      Map<String, dynamic> userDetails = jsonDecode(response.body);
      // logger.info("user details: $userDetails");
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      refreshNextAppointment();
      await prefs.setString('tokenAPI', token_);
      logger.info("token at singing in: $token_");
      // username_ = userDetails['userName'];
      // firstName_ = userDetails['firstName'];
      // lastName_ = userDetails['lastName'];
      // email_ = userDetails['email'];
      // pid_ = userDetails['userID'];
      await prefs.setString('username', userDetails['userName']);
      await prefs.setString('firstName', userDetails['firstName']);
      await prefs.setString('lastName', userDetails['lastName']);
      await prefs.setString('email', userDetails['email']);
      await prefs.setInt('pid', userDetails['userID']);
      pid_ = userDetails['userID'];
      final responsePatient = await http
          .post(
            Uri.parse('http://$localhost:8000/getPatientDetails'), //$localhost
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'username': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 10));
      if (responsePatient.statusCode == 200) {
        logger.info('Response body: ${responsePatient.body}');
        Map<String, dynamic> patientDetails = jsonDecode(responsePatient.body);
        logger.info("patient details: $patientDetails");
        if (patientDetails['doctorCode'] != null) {
          //doctorCode_ = patientDetails['doctorCode'];
          await prefs.setString('doctorCode', patientDetails['doctorCode']);
          final doctorResponse = await http.get(Uri.parse(
              'http://$localhost:8000/getDoctorInfo/${patientDetails['doctorCode']}'));
          if (doctorResponse.statusCode == 200) {
            var responseBody = jsonDecode(doctorResponse.body);
            logger.info("doctor response: $responseBody");
            doctorName_ =
                responseBody['firstName'] + ' ' + responseBody['lastName'];
            await prefs.setString('doctorName', doctorName_);
          }
        }
        if (patientDetails['phoneNumber'] != null) {
          //phoneNumber_ = patientDetails['phoneNumber'];
          await prefs.setInt('phoneNumber', patientDetails['phoneNumber']);
        }
        if (patientDetails['profilePhoto'] != null) {
          //profilePicture_ = patientDetails['profilePhoto'];
          await prefs.setString(
              'profilePicture_', patientDetails['profilePhoto']);
        }
        insulinSensitivity_ = patientDetails['insulinSensivity'].toInt();
        await prefs.setInt(
            'insulinSensitivity_', patientDetails['insulinSensivity'].toInt());
        //targetBloodSugar_ = patientDetails['targetBloodGlucose'];
        await prefs.setInt(
            'targetBloodSugar_', patientDetails['targetBloodGlucose']);
        //carbRatio_ = patientDetails['carbRatio'];
        await prefs.setDouble('carbRatio', patientDetails['carbRatio']);
        numOfRatios_ = 1;
        prefs.setInt('numOfRatios', 1);
        if (patientDetails['carbRatio2'] != null) {
          carbRatio_2 = patientDetails['carbRatio2'];
          await prefs.setDouble('carbRatio2', patientDetails['carbRatio2']);
          if (carbRatio_2 != 0) numOfRatios_++;
          prefs.setInt('numOfRatios', numOfRatios_);
        }
        if (patientDetails['carbRatio3'] != null) {
          carbRatio_3 = patientDetails['carbRatio3'];
          await prefs.setDouble('carbRatio3', patientDetails['carbRatio3']);
          if (carbRatio_3 != 0) numOfRatios_++;
          prefs.setInt('numOfRatios', numOfRatios_);
        }
        if (patientDetails['privacy'] != null) {
          //privacy_ = patientDetails['privacy'];
          await prefs.setString('privacy', patientDetails['privacy']);
        }
        //changeDoctor(doctorCode_);
        loadPreferences();
        prefs.setBool('signedIn', true);
        logger.info("saved values to shared preferences successfully");
      } else {
        logger.warning(responsePatient.body);
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const App()),
    );
  }

  @override
  void initState() {
    initializeControllers();
    super.initState();
  }

  @override
  void dispose() {
    disposeControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/signin.png"), // replace with your image
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      textDirection: TextDirection.ltr,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
                            color: Color.fromARGB(255, 38, 20, 84),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          'Sign in',
                          style: TextStyle(
                            color: Color.fromARGB(255, 38, 20, 84),
                            fontSize: 30,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 38, 20, 84),
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'UserName or Email',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(189, 38, 20, 84),
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: const Icon(
                              Icons.person_2_outlined,
                              color: Color.fromARGB(255, 38, 20, 84),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 38, 20, 84),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 38, 20, 84),
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          //onEditingComplete: () => _focusNodePassword.requestFocus(),
                          //validator: (String? value) {
                          //  if (value == null || value.isEmpty) {
                          //    return 'Please enter your email';
                          //  } else if (!_boxAccounts.containsKey(value)) {
                          //    return 'Email not found';
                          //  }
                          //  return null;
                          //},
                        ),
                        eerror
                            ? Text(
                                emailErrorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 30,
                        ),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          keyboardType: TextInputType.visiblePassword,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 38, 20, 84),
                            fontSize: 15,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: const TextStyle(
                              color: Color.fromARGB(189, 38, 20, 84),
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Color.fromARGB(255, 38, 20, 84),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              color: const Color.fromARGB(255, 107, 100, 126),
                              icon: _obscurePassword
                                  ? const Icon(Icons.visibility_off_outlined)
                                  : const Icon(Icons.visibility_outlined),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              borderSide: BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 38, 20, 84),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                width: 2,
                                color: Color.fromARGB(255, 38, 20, 84),
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          //validator: (String? value) {
                          //  if (value == null || value.isEmpty) {
                          //    return "Please enter password.";
                          //  } else if (value !=_boxAccounts.get(_controllerUsername.text)) {
                          //    return "Wrong password.";
                          //  }

                          //  return null;
                          //},
                        ),
                        perror
                            ? Text(
                                passErrorMessage!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13,
                                ),
                              )
                            : Container(),
                        const SizedBox(
                          height: 15,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const ForgetPass()));
                            },
                            child: const Text(
                              'Forget Password?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 22, 161, 170),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 25,
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 38, 20, 84),
                            minimumSize: const Size.fromHeight(55),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            setState(() {
                              _isLoading = true;
                            });
                            String uvalue = _emailController.text;
                            String pvalue = _passwordController.text;
                            DBHelper dbHelper = DBHelper.instance;
                            //createPlantFoodNotification;
                            bool connectedToWifi = await isConnectedToWifi();
                            print(connectedToWifi);

                            String email = _emailController.text;
                            String password = _passwordController.text;
                            if (uvalue.isEmpty || pvalue.isEmpty) {
                              if (uvalue.isEmpty) {
                                //   setState(() {
                                //     emailErrorMessage =
                                //         "* Please enter your email/username";
                                //     eerror = true;
                                //     _isLoading = false;
                                //   });
                                // } else {
                                //   setState(() {
                                //     eerror = false;
                                //   });
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please enter your username or email'),
                                  ),
                                );
                              } else if (pvalue.isEmpty) {
                                //   setState(() {
                                //     passErrorMessage =
                                //         "* Please enter your password";
                                //     perror = true;
                                //     _isLoading = false;
                                //   });
                                // } else {
                                //   setState(() {
                                //     perror = false;
                                //   });
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter your password'),
                                  ),
                                );
                              }
                            } else {
                              if (email == 'admin' && password == 'admin') {
                                //alowing admins to login without server connection
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const App()),
                                );
                              } else if (connectedToWifi == false) {
                                setState(() {
                                  _isLoading = false;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Please connect to the internet to sign in'),
                                  ),
                                );
                              } else {
                                try {
                                  //server authentication
                                  email = _emailController.text;
                                  password = _passwordController.text;

                                  final response = await http
                                      .post(
                                        Uri.parse(
                                            'http://$localhost:8000/token'), // changed from /authenticate to /token
                                        headers: <String, String>{
                                          'Content-Type':
                                              'application/json; charset=UTF-8',
                                        },
                                        body: jsonEncode(<String, String>{
                                          'username': email,
                                          'password': password,
                                        }),
                                      )
                                      .timeout(const Duration(seconds: 10));
                                  username_ = email;
                                  // print(int.parse(response.body));
                                  if (response.statusCode == 400) {
                                    //WE HAVE TO GO TO THE MEMBERSHIPP PAGEESSSOUYIGHFUIHBKJDHBUYDS
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Membership(
                                                  username:
                                                      "", //USERNAME TO BE GOT FROM BACKEND
                                                  index: 0,
                                                )));
                                  } else if (response.statusCode == 402) {
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const UserInfo()),
                                    );
                                  } else if (response.statusCode == 200) {
                                    Map<String, dynamic> responseBody =
                                        jsonDecode(response.body);
                                    token_ = responseBody['access_token'];
                                    await prefs.setString('tokenAPI', token_);
                                    logger.info(token_);
                                    isLoggedIn = true;
                                    await prefs.setBool('signedIn', isLoggedIn);
                                    //print(response.body);

                                    deleteListEntries();
                                    setLoginTime();
                                    setState(() {
                                      eerror = false;

                                      perror = false;
                                    });

                                    _signIn(email, password,
                                        jsonDecode(response.body)['ID']);
                                  } else {
                                    //incorrect username or password handling
                                    //for layal you can change this if you want or remove this comment if you think its good
                                    // setState(() {
                                    //   _isLoading = false;
                                    // });
                                    // setState(() {
                                    //   emailErrorMessage =
                                    //       "* Incorrect username or password";
                                    //   eerror = true;
                                    //   _isLoading = false;
                                    //   passErrorMessage =
                                    //       "* Incorrect username or password";
                                    //   perror = true;
                                    // });
                                    setState(() {
                                      _isLoading = false;
                                    });
                                    var responseBody =
                                        jsonDecode(response.body);
                                    var errorMessage = responseBody['detail'] ??
                                        'Unknown error';
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$errorMessage')),
                                    );
                                    print(errorMessage);
                                  }
                                } catch (e) {
                                  // ignore: avoid_print
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  print('Error: $e');
                                  logger.info(e);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'The server did not respond error : $e')),
                                  );
                                }
                              }
                            }
                          },
                          child: _isLoading
                              ? const CircularProgressIndicator()
                              : const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 249, 254),
                                    fontSize: 22,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                        const SizedBox(
                          height: 100,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Don’t have an account?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 22, 161, 170),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(
                              width: 2.5,
                            ),
                            InkWell(
                              onTap: () async {
                                _formKey.currentState?.reset();

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const SignUp();
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 22, 161, 170),
                                  fontSize: 15,
                                  fontFamily: 'InterBold',
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
