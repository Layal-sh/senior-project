import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/app.dart';
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
  SqlDb sqlDB = SqlDb();
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
        backgroundColor: Colors.transparent,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 200,
              ),
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
                      decoration: InputDecoration(
                        labelText: 'UserName or Email',
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
                    const SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                          color: const Color.fromARGB(255, 107, 100, 126),
                          icon: _obscurePassword
                              ? const Icon(Icons.visibility_off_outlined)
                              : const Icon(Icons.visibility_outlined),
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
                      //validator: (String? value) {
                      //  if (value == null || value.isEmpty) {
                      //    return "Please enter password.";
                      //  } else if (value !=_boxAccounts.get(_controllerUsername.text)) {
                      //    return "Wrong password.";
                      //  }

                      //  return null;
                      //},
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
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
                    const SizedBox(
                      height: 25,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () async {
                        String email = _emailController.text;
                        String password = _passwordController.text;

                        final response = await http.post(
                          Uri.parse('http://localhost:8000/authenticate'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode(<String, String>{
                            'email': email,
                            'password': password,
                          }),
                        );

                        if (response.statusCode == 200) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const App()),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Invalid username or password')),
                          );
                        }
                      },
                      child: const Text(
                        "Sign In",
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 249, 254),
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 150,
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
                          onTap: () {
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
                              color: const Color.fromARGB(255, 22, 161, 170),
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
    );
  }
}
