import 'package:flutter/material.dart';
import 'package:sugar_sense/Database/db.dart';
import 'login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  SqlDb sqldb = SqlDb();
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
        backgroundColor: Colors.transparent,
        body: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 70,
              ),
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
                      height: 20,
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
                      height: 30,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 2.3,
                          child: TextFormField(
                            controller: _controllerFirstname,
                            keyboardType: TextInputType.name,
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
                          width: MediaQuery.of(context).size.width / 2.3,
                          child: TextFormField(
                            controller: _controllerLastname,
                            keyboardType: TextInputType.name,
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
                          return "Please enter username.";
                        } //else if (_boxAccounts.containsKey(value)) {
                        //return "Username is already registered.";
                        //}

                        return null;
                      },
                      onEditingComplete: () => _focusNodeEmail.requestFocus(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _controllerEmail,
                      focusNode: _focusNodeEmail,
                      keyboardType: TextInputType.emailAddress,
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
                        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
                        minimumSize: const Size.fromHeight(55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
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
      ),
    );
  }
}
