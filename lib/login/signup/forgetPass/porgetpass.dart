import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ForgetPass extends StatefulWidget {
  const ForgetPass({super.key});

  @override
  State<ForgetPass> createState() => _ForgetPassState();
}

class _ForgetPassState extends State<ForgetPass> {
  final TextEditingController _controllerEmail = TextEditingController();
  List<FocusNode> focusNodes = [];
  List<TextEditingController> econtrollers = [];
  @override
  void initState() {
    super.initState();
    econtrollers = List.generate(6, (index) => TextEditingController());
    focusNodes = List.generate(6, (index) => FocusNode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Row(
          children: [],
        ),
        //backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 40.0,
          right: 40,
          top: MediaQuery.of(context).size.height * 0.1,
        ),
        child: Column(
          children: [
            Image.asset(
              'assets/lock.png',
              width: MediaQuery.of(context).size.width * 0.2,
            ),
            const SizedBox(
              height: 35,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.3,
              child: Text(
                'Forget Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontFamily: 'Ruda-Bold',
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Text(
              'Provide your accounts\' email for which you want to reset your password.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontFamily: 'Ruda',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 30,
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
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => emailCode(_controllerEmail.text)));
                },
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
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
    );
  }

  Widget emailCode(String email) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        title: const Row(
          children: [],
        ),
        //backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 40.0,
          right: 40,
          top: MediaQuery.of(context).size.height * 0.1,
        ),
        child: Column(
          children: [
            Text(
              'A verefication code was sent to your email',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
                fontSize: MediaQuery.of(context).size.width * 0.04,
                fontFamily: 'Ruda',
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return Container(
                  width: 55,
                  child: TextField(
                    controller: econtrollers[index],
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    focusNode: focusNodes[index],
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      if (value.length == 1) {
                        if (index < 5) {
                          FocusScope.of(context)
                              .requestFocus(focusNodes[index + 1]);
                        }
                      }
                    },
                    decoration: InputDecoration(
                      hintText: "0",
                      hintStyle: TextStyle(
                        color: Color.fromARGB(255, 195, 195, 195),
                      ),
                      counterText: "",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                            10.0), // Set the border radius here
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
