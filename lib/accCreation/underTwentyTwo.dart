import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UnderTwentyTwo extends StatefulWidget {
  @override
  _UnderTwentyTwoState createState() => _UnderTwentyTwoState();
}

class _UnderTwentyTwoState extends State<UnderTwentyTwo> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController birthDateController = TextEditingController();
  final TextEditingController motherNameController = TextEditingController();
  final TextEditingController fatherNameController = TextEditingController();

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
                      height: 40,
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
                    // Add more TextFormField widgets here as per your requirement
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
