// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/application/membership.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'dart:convert';

bool isValidEmail(String email) {
  final RegExp regex =
      RegExp(r'^[a-zA-Z0-9.a-zA-Z0-9._%-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$');
  return regex.hasMatch(email);
}

bool isValidPassword(String password) {
  // Check if password is at least 8 characters long
  if (password.length < 8) {
    return false;
  }

  // Check if password contains at least one letter
  final RegExp hasLetter = RegExp(r'[a-zA-Z]');
  if (!hasLetter.hasMatch(password)) {
    return false;
  }

  // Check if password contains at least one number
  final RegExp hasNumber = RegExp(r'\d');
  if (!hasNumber.hasMatch(password)) {
    return false;
  }

  // If all checks pass, the password is valid
  return true;
}

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodeDoctorID = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final FocusNode _focusNodeConfirmPassword = FocusNode();
  final TextEditingController _controllerFirstname = TextEditingController();
  final TextEditingController _controllerLastname = TextEditingController();
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerDoctorID = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConFirmPassword =
      TextEditingController();

  //final Box _boxAccounts = Hive.box("accounts");
  bool _obscurePassword = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/signup.png"), // replace with your image
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Row(
                        children: [
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color.fromARGB(255, 38, 20, 84),
                            size: 25,
                            weight: 100,
                          ),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Color.fromARGB(255, 38, 20, 84),
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 14,
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          textDirection: TextDirection.ltr,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Welcome!',
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
                              'Sign Up',
                              style: TextStyle(
                                color: Color.fromARGB(255, 38, 20, 84),
                                fontSize: 30,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.3,
                                  child: TextFormField(
                                    controller: _controllerFirstname,
                                    keyboardType: TextInputType.name,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 38, 20, 84),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'First Name *',
                                      labelStyle: const TextStyle(
                                        color: Color.fromARGB(189, 38, 20, 84),
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      /*prefixIcon: const Icon(
                                        Icons.person_2_outlined,
                                        color: Color.fromARGB(255, 38, 20, 84),
                                      ),*/
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        borderSide: BorderSide(
                                          width: 2,
                                          color:
                                              Color.fromARGB(255, 38, 20, 84),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          width: 2,
                                          color:
                                              Color.fromARGB(255, 38, 20, 84),
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter first name.";
                                      } //else if (_boxAccounts.containsKey(value)) {
                                      //return "Username is already registered.";
                                      //}

                                      return null;
                                    },
                                    onEditingComplete: () =>
                                        _focusNodeEmail.requestFocus(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.3,
                                  child: TextFormField(
                                    controller: _controllerLastname,
                                    keyboardType: TextInputType.name,
                                    style: const TextStyle(
                                      color: Color.fromARGB(255, 38, 20, 84),
                                      fontSize: 15,
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      labelText: 'Last Name *',
                                      labelStyle: const TextStyle(
                                        color: Color.fromARGB(189, 38, 20, 84),
                                        fontSize: 15,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w600,
                                      ),
                                      /*prefixIcon: const Icon(
                                        Icons.person_2_outlined,
                                        color: Color.fromARGB(255, 38, 20, 84),
                                      ),*/
                                      focusedBorder: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(15)),
                                        borderSide: BorderSide(
                                          width: 2,
                                          color:
                                              Color.fromARGB(255, 38, 20, 84),
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                          width: 2,
                                          color:
                                              Color.fromARGB(255, 38, 20, 84),
                                        ),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Please enter last name.";
                                      } //else if (_boxAccounts.containsKey(value)) {
                                      //return "Username is already registered.";
                                      //}

                                      return null;
                                    },
                                    onEditingComplete: () =>
                                        _focusNodeEmail.requestFocus(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _controllerUsername,
                              keyboardType: TextInputType.name,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 38, 20, 84),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                labelText: 'UserName *',
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(189, 38, 20, 84),
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
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
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter username.";
                                } //else if (_boxAccounts.containsKey(value)) {
                                //return "Username is already registered.";
                                //}

                                return null;
                              },
                              onEditingComplete: () =>
                                  _focusNodeEmail.requestFocus(),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _controllerEmail,
                              focusNode: _focusNodeEmail,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 38, 20, 84),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Email *',
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(189, 38, 20, 84),
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
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
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter email.";
                                } else if (!(value.contains('@') &&
                                    value.contains('.'))) {
                                  return "Invalid email";
                                }
                                return null;
                              },
                              onEditingComplete: () =>
                                  _focusNodePassword.requestFocus(),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _controllerDoctorID,
                              focusNode: _focusNodeDoctorID,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 38, 20, 84),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Doctor ID',
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(189, 38, 20, 84),
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                                prefixIcon: const Icon(
                                  Icons.emoji_emotions_outlined,
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
                              validator: (String? value) {
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _controllerPassword,
                              obscureText: _obscurePassword,
                              focusNode: _focusNodePassword,
                              keyboardType: TextInputType.visiblePassword,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 38, 20, 84),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Password *',
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(189, 38, 20, 84),
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
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
                                  color:
                                      const Color.fromARGB(255, 107, 100, 126),
                                  icon: _obscurePassword
                                      ? const Icon(
                                          Icons.visibility_off_outlined)
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
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter password.";
                                } else if (value.length < 8) {
                                  return "Password must be at least 8 character.";
                                }
                                return null;
                              },
                              onEditingComplete: () =>
                                  _focusNodePassword.requestFocus(),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: _controllerConFirmPassword,
                              obscureText: _obscurePassword,
                              focusNode: _focusNodeConfirmPassword,
                              keyboardType: TextInputType.visiblePassword,
                              style: const TextStyle(
                                color: Color.fromARGB(255, 38, 20, 84),
                                fontSize: 15,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Confirm Password *',
                                labelStyle: const TextStyle(
                                  color: Color.fromARGB(189, 38, 20, 84),
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
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
                                  color:
                                      const Color.fromARGB(255, 107, 100, 126),
                                  icon: _obscurePassword
                                      ? const Icon(
                                          Icons.visibility_off_outlined)
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
                              validator: (String? value) {
                                if (value == null || value.isEmpty) {
                                  return "Please enter password.";
                                } else if (value != _controllerPassword.text) {
                                  return "Password doesn't match.";
                                }
                                return null;
                              },
                              onEditingComplete: () =>
                                  _focusNodeConfirmPassword.requestFocus(),
                            ),
                            const SizedBox(
                              height: 20,
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
                                //if (_formKey.currentState?.validate() ?? false) {
                                //  _boxAccounts.put(
                                //    _controllerUsername.text,
                                //    _controllerConFirmPassword.text,
                                //  );

                                //  ScaffoldMessenger.of(context).showSnackBar(
                                //    SnackBar(
                                //      width: 200,
                                //      backgroundColor:
                                //          Theme.of(context).colorScheme.secondary,
                                //      shape: RoundedRectangleBorder(
                                //        borderRadius: BorderRadius.circular(10),
                                //      ),
                                //      behavior: SnackBarBehavior.floating,
                                //      content: const Text("Registered Successfully"),
                                //    ),
                                //  );

                                //  _formKey.currentState?.reset();

                                //  Navigator.pop(context);
                                //}
                                DBHelper dbHelper = DBHelper.instance;
                                dbHelper.initialDb();
                                String fname = _controllerFirstname.text;
                                String lname = _controllerLastname.text;
                                String username = _controllerUsername.text;
                                String email = _controllerEmail.text;
                                String password = _controllerPassword.text;
                                String confirmPassword =
                                    _controllerConFirmPassword.text;

                                if (username.isEmpty ||
                                    email.isEmpty ||
                                    password.isEmpty ||
                                    confirmPassword.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'All fields with * must be filled')),
                                  );
                                } else if (!isValidEmail(email)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('The email is not valid')),
                                  );
                                } else if (password != confirmPassword) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content:
                                            Text('The passwords do not match')),
                                  );
                                } else if (!isValidPassword(password)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Password must contains 8 characters including 1 number and 1 letter')),
                                  );
                                } else {
                                  try {
                                    //server authentication
                                    final response = await http
                                        .post(
                                          Uri.parse(
                                              'http://127.0.0.1:8000/register'),
                                          headers: <String, String>{
                                            'Content-Type':
                                                'application/json; charset=UTF-8',
                                          },
                                          body: jsonEncode(<String, String>{
                                            'firstName': fname,
                                            'lastName': lname,
                                            'username': username,
                                            'email': email,
                                            'password': password,
                                            'confirmPassword': confirmPassword,
                                          }),
                                        )
                                        .timeout(const Duration(seconds: 10));
                                    if (response.statusCode == 200) {
                                      //await dbHelper.syncMeals();
                                      //List<Map> m=dbHelper.selectAllMeals();
                                      //m.forEach(print);

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const Membership()),
                                      );

                                      //Navigator.push(
                                      //context,
                                      //MaterialPageRoute(
                                      //builder: (context) => const App()),
                                      //);
                                    } else {
                                      // ignore: avoid_print
                                      print(response.body);
                                      var responseBody =
                                          jsonDecode(response.body);
                                      var errorMessage =
                                          responseBody['detail'] ??
                                              'Unknown error';
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text('$errorMessage')),
                                      );
                                    }
                                  } catch (e) {
                                    // ignore: avoid_print
                                    print('Error: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'The server did not respond')),
                                    );
                                  }
                                }
                                //Navigator.push(
                                //context,
                                //MaterialPageRoute(builder: (context) => Membership()),
                                //);
                              },
                              child: const Text(
                                "Sign Up",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 249, 254),
                                  fontSize: 22,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account?',
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
                                  onTap: () {
                                    _formKey.currentState?.reset();

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const Login();
                                        },
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Sign in',
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
