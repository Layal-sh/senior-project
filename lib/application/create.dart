import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/application/meals.dart';

class CreateMeal extends StatefulWidget {
  const CreateMeal({super.key});

  @override
  State<CreateMeal> createState() => _CreateMealState();
}

class _CreateMealState extends State<CreateMeal> {
  PickedFile? _selectedImage;
  void _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final PickedFile? image =
        (await _picker.pickImage(source: ImageSource.gallery)) as PickedFile?;

    setState(() {
      _selectedImage = image;
    });
  }

  DBHelper dbHelper = DBHelper.instance;
  List<Map> allMeals = [];
  List<int> selectedMeals = [];

  @override
  void initState() {
    super.initState();
    loadMeals();
  }

  void loadMeals() async {
    allMeals = await dbHelper.selectAllMeals();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 15,
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      child: const Icon(
                        Icons.arrow_back,
                        color: Color.fromARGB(255, 38, 20, 84),
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        //dbHelper.createEntry(pid, glucose, insulin, date, selectedMeals);
                      },
                      child: const Text(
                        'Create',
                        style: TextStyle(
                          color: Color.fromARGB(255, 38, 20, 84),
                          fontSize: 22,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  Container(
                    width: 175,
                    height: 175,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: _selectedImage != null
                          ? Image.file(
                              File(_selectedImage!.path),
                              width: 200,
                              height: 200,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.camera_alt,
                              size: 50,
                              color: Colors.grey[800],
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 7,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 38, 20, 84),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(15),
                            topRight: Radius.circular(15),
                            bottomLeft: Radius.circular(7),
                            bottomRight: Radius.circular(15),
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              height: MediaQuery.of(context).size.height - 280,
              color: const Color.fromARGB(255, 231, 231, 231),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Name: ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 38, 20, 84),
                      fontSize: 17,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    //controller: _nameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 38, 20, 84),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 38, 20, 84),
                          width: 1.5,
                        ),
                      ),
                      hintText: 'Enter meal name',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Ingredients: ',
                    style: TextStyle(
                      color: Color.fromARGB(255, 38, 20, 84),
                      fontSize: 17,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  selectedMeals.isEmpty
                      ? Container()
                      : Expanded(
                          child: ListView.builder(
                            itemCount: selectedMeals.length,
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(allMeals[index]['mealName']),
                                  const Text('quantity'),
                                  const Text('unit'),
                                  IconButton(
                                    icon: const Icon(Icons.close),
                                    onPressed: () {
                                      setState(() {
                                        //selectedMeals.removeAt(index);
                                      });
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        color: const Color.fromARGB(255, 38, 20, 84),
                        iconSize: 30,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Meals()),
                          );
                        },
                      ),
                      const Text(
                        'Add Ingredients',
                        style: TextStyle(
                          color: Color.fromARGB(255, 38, 20, 84),
                          fontSize: 17,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w900,
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
    );
  }
}
