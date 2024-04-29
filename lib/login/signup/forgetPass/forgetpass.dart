// ignore_for_file: use_build_context_synchronously, unused_local_variable, non_constant_identifier_names, unnecessary_import

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:sugar_sense/login/signup/login.dart';
import 'package:sugar_sense/login/signup/signup.dart';
import 'package:sugar_sense/main.dart';
import 'package:http/http.dart' as http;

class ForgetPass extends StatefulWidget {
  const ForgetPass({super.key});

  @override
  State<ForgetPass> createState() => _ForgetPassState();
}

String email = "";

class _ForgetPassState extends State<ForgetPass> {
  final TextEditingController _controllerEmail = TextEditingController();

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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: true,
            title: const Row(
              children: [],
            ),
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 255, 255, 255),
            )),
        body: Padding(
          padding: EdgeInsets.only(
            left: 40.0,
            right: 40,
            top: MediaQuery.of(context).size.height * 0.1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  'assets/lock.png',
                  width: MediaQuery.of(context).size.width * 0.2,
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              SizedBox(
                //width: MediaQuery.of(context).size.width * 0.3,
                child: Text(
                  'Forget Password',
                  //textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontSize: MediaQuery.of(context).size.width * 0.05,
                    fontFamily: 'Ruda-Bold',
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                'Provide your accounts\' email for which you want to reset your password.',
                //textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: MediaQuery.of(context).size.width * 0.03,
                  fontFamily: 'Ruda',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.07,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color.fromARGB(255, 38, 20, 84),
                    width: 0.7,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    bottomLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                ),
                child: TextFormField(
                  controller: _controllerEmail,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(
                    color: const Color.fromARGB(255, 38, 20, 84),
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Email',
                    labelStyle: TextStyle(
                      color: Color.fromARGB(189, 38, 20, 84),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                    prefixIcon: Icon(
                      Icons.email_outlined,
                      color: Color.fromARGB(255, 38, 20, 84),
                    ),
                    border: InputBorder.none,
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter your email.";
                    } else if (!(value.contains('@') && value.contains('.'))) {
                      return "Invalid email";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 38, 20, 84),
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    email = _controllerEmail.text;
                    if (email == "" ||
                        !email.contains('@') ||
                        !email.contains('.')) {
                      //show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid Email'),
                        ),
                      );
                    } else {
                      //call the forgetPass route in the api
                      final response = await http.get(Uri.parse(
                          'http://$localhost:8000/forgotPassword/$email'));
                      if (response.statusCode == 200) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    EmailCode(_controllerEmail.text)));
                      } else {
                        //show error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Email Not Found'),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    'Next',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailCode extends StatefulWidget {
  final String email;

  const EmailCode(this.email, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EmailCodeState createState() => _EmailCodeState();
}

class _EmailCodeState extends State<EmailCode> {
  Duration _duration = const Duration(seconds: 30);
  Timer? _timer;
  List focusNodes = [];
  List econtrollers = [];
  @override
  void initState() {
    super.initState();
    econtrollers = List.generate(6, (index) => TextEditingController());
    focusNodes = List.generate(6, (index) => FocusNode());
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_duration.inSeconds > 0) {
          _duration = _duration - const Duration(seconds: 1);
        } else {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: true,
            title: const Row(
              children: [],
            ),
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 255, 255, 255),
            )),
        body: Padding(
          padding: EdgeInsets.only(
            left: 40.0,
            right: 40,
            top: MediaQuery.of(context).size.height * 0.1,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verefication Code',
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: MediaQuery.of(context).size.width * 0.045,
                  fontFamily: 'Ruda-Bold',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                'Please Check your email for a verification code',
                //textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                  fontFamily: 'Ruda',
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 55,
                    child: TextField(
                      controller: econtrollers[index],
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        hintText: "*",
                        hintStyle: TextStyle(
                          color: const Color.fromARGB(255, 159, 159, 159),
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 38, 20, 84),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: _duration.inSeconds != 0
                    ? Text(
                        'Resend code in ${_duration.inSeconds}',
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 0, 0),
                          fontSize: MediaQuery.of(context).size.width * 0.03,
                          fontFamily: 'Ruda',
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          final response = await http.get(Uri.parse(
                              'http://$localhost:8000/forgotPassword/$email'));
                          setState(() {
                            _duration = const Duration(seconds: 30);
                            startTimer();
                          });
                        },
                        child: Text(
                          'Resend code',
                          style: TextStyle(
                            color: const Color.fromARGB(255, 44, 177, 186),
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                            fontFamily: 'Ruda',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
              ),
              const SizedBox(
                height: 30,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.07,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 38, 20, 84),
                    minimumSize: const Size.fromHeight(55),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    String code = "";
                    for (int i = 0; i < 6; i++) {
                      String currentLetter = econtrollers[i].text;
                      if (currentLetter == "") {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter the code'),
                          ),
                        );
                        return;
                      } else {
                        code += econtrollers[i].text;
                      }
                    }
                    final response = await http.get(
                        Uri.parse('http://$localhost:8000/checkCode/$code'));
                    if (response.statusCode == 200) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => PassCode(widget.email)));
                    } else if (response.statusCode == 402) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code Expired'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid Code'),
                        ),
                      );
                    }
                  },
                  child: Text(
                    'Verify',
                    style: TextStyle(
                      color: const Color.fromARGB(255, 255, 255, 255),
                      fontSize: MediaQuery.of(context).size.width * 0.045,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PassCode extends StatefulWidget {
  final String email;

  const PassCode(this.email, {super.key});

  @override
  // ignore: library_private_types_in_public_api
  _PassCodeState createState() => _PassCodeState();
}

class _PassCodeState extends State<PassCode> {
  final TextEditingController _NewPassController = TextEditingController();
  final TextEditingController _ConfirmPassController = TextEditingController();
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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            automaticallyImplyLeading: true,
            title: const Row(
              children: [],
            ),
            iconTheme: const IconThemeData(
              color: Color.fromARGB(255, 255, 255, 255),
            )),
        body: Center(
          child: Padding(
            padding: EdgeInsets.only(
              left: 40.0,
              right: 40,
              top: MediaQuery.of(context).size.height * 0.2,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enter New Password',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 38, 20, 84),
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                    fontFamily: 'Ruda-Bold',
                    //fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _NewPassController,
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
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
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
                ),
                const SizedBox(
                  height: 30,
                ),
                Text(
                  'Confirm Password',
                  style: TextStyle(
                    color: const Color.fromARGB(255, 38, 20, 84),
                    fontSize: MediaQuery.of(context).size.width * 0.045,
                    fontFamily: 'Ruda-Bold',
                    //fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _ConfirmPassController,
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
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
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
                    } else if (value != _NewPassController.text) {
                      return "Password doesn't match.";
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.07,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 38, 20, 84),
                      minimumSize: const Size.fromHeight(55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () async {
                      String password = _NewPassController.text;
                      String confirmPassword = _ConfirmPassController.text;
                      if (password != "" && confirmPassword != "") {
                        if (isValidPassword(password)) {
                          if (password == confirmPassword) {
                            final response = await http.get(Uri.parse(
                                'http://$localhost:8000/updatePassword/$password'));
                            if (response.statusCode == 200) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const Login()));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Password Reset Successfully'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Error Resetting Password'),
                                ),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Passwords do not match'),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Password must be at least 8 characters and contains at least one number'),
                            ),
                          );
                        }
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Both fields are required'),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255),
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
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
