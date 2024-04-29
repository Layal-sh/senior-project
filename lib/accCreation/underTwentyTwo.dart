import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/main.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UnderTwentyTwo extends StatefulWidget {
  @override
  _UnderTwentyTwoState createState() => _UnderTwentyTwoState();
}

class _UnderTwentyTwoState extends State<UnderTwentyTwo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController doctorCodeController = TextEditingController();

  File? _frontIdImage;
  File? _backIdImage;
//final bytes = await _frontIdImage.readAsBytes();

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
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  //textDirection: TextDirection.ltr,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: addressController,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Address',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(189, 38, 20, 84),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: const Icon(
                          Icons.home_outlined,
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
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: birthDateController,
                      readOnly: true,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Birth Date',
                        labelStyle: const TextStyle(
                          color: Color.fromARGB(189, 38, 20, 84),
                          fontSize: 15,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                        prefixIcon: const Icon(
                          Icons.calendar_today,
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
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(1900),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          birthDateController.text =
                              DateFormat('yyyy-MM-dd').format(date);
                        }
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: doctorCodeController,
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
                    const Text(
                      'National ID:',
                      style: TextStyle(
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                _frontIdImage = File(pickedFile.path);
                              });
                            }
                          },
                          child: _frontIdImage == null
                              ? Container(
                                  width: 150,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(50, 38, 20, 84),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(Icons.add,
                                      size: 100,
                                      color: Color.fromARGB(255, 38, 20, 84)),
                                )
                              : Stack(
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      height: 200,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.file(_frontIdImage!,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Icon(Icons.edit,
                                          color: Color.fromARGB(
                                              255, 22, 161, 170)),
                                    ),
                                  ],
                                ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            final pickedFile = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                _backIdImage = File(pickedFile.path);
                              });
                            }
                          },
                          child: _backIdImage == null
                              ? Container(
                                  width: 150,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(50, 38, 20, 84),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Icon(Icons.add,
                                      size: 100,
                                      color: Color.fromARGB(255, 38, 20, 84)),
                                )
                              : Stack(
                                  children: [
                                    SizedBox(
                                      width: 150,
                                      height: 200,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.file(_backIdImage!,
                                            fit: BoxFit.cover),
                                      ),
                                    ),
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Icon(Icons.edit,
                                          color: Color.fromARGB(
                                              255, 22, 161, 170)),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 40,
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
                        if (birthDateController.text.isNotEmpty &&
                            addressController.text.isNotEmpty &&
                            doctorCodeController.text.isNotEmpty &&
                            _frontIdImage != null &&
                            _backIdImage != null) {
                          final bytes = await _frontIdImage!.readAsBytes();
                          final bytes2 = await _backIdImage!.readAsBytes();

                          final string = base64Encode(bytes);
                          final string2 = base64Encode(bytes2);

                          print(string);

                          final response = await http
                              .post(
                                Uri.parse('http://$localhost:8000/freeRequest'),
                                headers: <String, String>{
                                  'Content-Type':
                                      'application/json; charset=UTF-8',
                                },
                                body: jsonEncode(<String, dynamic>{
                                  'userId': pid_,
                                  'birthDate': birthDateController.text,
                                  'address': addressController.text,
                                  'doctorCode': doctorCodeController.text,
                                  'idCard1': string,
                                  'idCard2': string2,
                                }),
                              )
                              .timeout(const Duration(seconds: 10));

                          if (response.statusCode == 200) {
                            logger.info('Request sent successfully');
                            logger.info(response.body);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('All fields must be filled!'),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Submit',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 249, 254),
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
