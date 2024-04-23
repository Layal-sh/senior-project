import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/Database/variables.dart';
import 'package:sugar_sense/accCreation/membership.dart';
import 'package:sugar_sense/application/app.dart';
import 'package:sugar_sense/application/meals/meals.dart';
import 'package:sugar_sense/login/signup/login.dart';
import 'package:sugar_sense/main.dart';
import 'package:url_launcher/url_launcher.dart';

Timer? _timer;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ProfileState createState() => _ProfileState();
}

XFile? _selectedImage;

class _ProfileState extends State<Profile> {
  List<bool>? fav;

  /*Future<void> resizeFavList() async {
    List<Map> articles = await db.selectAllArticle();
    int length = articles.length;

    if (fav!.length > length) {
      fav?.length = length;
    } else {
      while (fav!.length < length) {
        fav?.add(true);
      }
    }
  }*/

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
    fav = [];
    //resizeFavList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Text(
              'Sugar',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 249, 254),
                fontSize: 21,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Sense',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 249, 254),
                fontSize: 21,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 20.0,
            left: 20,
            right: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(
                      width: min(MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.height) *
                          0.4,
                      height: min(MediaQuery.of(context).size.width,
                              MediaQuery.of(context).size.height) *
                          0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: (profilePicture_ != '')
                            ? Image.file(
                                File(profilePicture_),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: const Color.fromARGB(255, 45, 170, 178),
                                child: Center(
                                  child: Text(
                                    //textAlign: TextAlign.center,
                                    firstName_[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: min(
                                              MediaQuery.of(context).size.width,
                                              MediaQuery.of(context)
                                                  .size
                                                  .height) *
                                          0.15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      username_,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        color: const Color.fromARGB(255, 28, 42, 58),
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    phoneNumber_.isNotEmpty
                        ? Text(
                            phoneNumber_,
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.035,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          const editProfile(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        var begin = const Offset(0.0, 1.0);
                        var end = Offset.zero;
                        var curve = Curves.ease;

                        var tween = Tween(begin: begin, end: end)
                            .chain(CurveTween(curve: curve));

                        return SlideTransition(
                          position: animation.drive(tween),
                          child: child,
                        );
                      },
                    ),
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(255, 209, 209, 209),
                        width: 1.2,
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.11,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.manage_accounts_outlined,
                            size: MediaQuery.of(context).size.width * 0.07,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.035,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: MediaQuery.of(context).size.width * 0.03,
                        color: const Color.fromARGB(255, 84, 95, 107),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () async {
                  /*showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) {
                      return StatefulBuilder(builder:
                          (BuildContext context, StateSetter setState) {
                        return Scaffold(
                          body: Container(
                            height: MediaQuery.of(context).size.height,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 255, 249,
                                  254), // Set the desired color here
                              borderRadius: BorderRadius
                                  .zero, // This removes the round edges
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.09,
                                  color: const Color.fromARGB(255, 38, 20, 84),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 25.0,
                                        ),
                                        child: SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.04,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shadowColor: Colors.transparent,
                                              backgroundColor:
                                                  Colors.transparent,
                                              foregroundColor:
                                                  Colors.transparent,
                                              surfaceTintColor:
                                                  Colors.transparent,
                                              // background color
                                              side: const BorderSide(
                                                color: Color.fromARGB(
                                                    255, 38, 20, 84),
                                                width: 1,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    10), // Change this value as needed
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.arrow_back_ios_rounded,
                                                  color: const Color.fromARGB(
                                                      255, 255, 249, 254),
                                                  size: min(
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height) *
                                                      0.035,
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  'Profile',
                                                  style: TextStyle(
                                                    fontSize: min(
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width,
                                                            MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height) *
                                                        0.035,
                                                    color: Colors.white,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ),
                                      ),
                                      Center(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 25.0,
                                          ),
                                          child: Text(
                                            'Favorites',
                                            style: TextStyle(
                                              fontSize: min(
                                                      MediaQuery.of(context)
                                                          .size
                                                          .width,
                                                      MediaQuery.of(context)
                                                          .size
                                                          .height) *
                                                  0.05,
                                              color: Colors.white,
                                              fontFamily: 'Inter',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SingleChildScrollView(
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.height *
                                          0.025,
                                      left: 20,
                                      right: 20,
                                    ),
                                    child: Column(
                                      children: [
                                        FutureBuilder<List<Map>>(
                                          future: db.selectAllArticle(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<List<Map>>
                                                  snapshot) {
                                            if (snapshot.hasData) {
                                              return ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    snapshot.data!.length,
                                                itemBuilder:
                                                    (BuildContext context,
                                                        int index) {
                                                  Map articlee =
                                                      snapshot.data![index];
                                                  return SizedBox(
                                                    height: articlee[
                                                                'imageUrl'] !=
                                                            'null'
                                                        ? MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.13
                                                        : null,
                                                    child: InkWell(
                                                      onTap: () => launch(
                                                          articlee['url']),
                                                      child: Card(
                                                        color:
                                                            Colors.transparent,
                                                        shadowColor:
                                                            Colors.transparent,
                                                        surfaceTintColor:
                                                            Colors.transparent,
                                                        clipBehavior:
                                                            Clip.antiAlias,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                            left: 10,
                                                            right: 10,
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              articlee['imageUrl'] !=
                                                                      'null'
                                                                  ? ClipRRect(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                      child: Image
                                                                          .network(
                                                                        articlee[
                                                                            'imageUrl'],
                                                                        width: MediaQuery.of(context).size.width *
                                                                            0.25,
                                                                        height:
                                                                            120, // Adjust the height as needed
                                                                        fit: BoxFit
                                                                            .cover,
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                              const SizedBox(
                                                                  width:
                                                                      10), // Add some spacing
                                                              Expanded(
                                                                child: Column(
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      articlee[
                                                                          'title'],
                                                                      maxLines:
                                                                          3,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          const TextStyle(
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'InriaSerif',
                                                                        color: Color.fromARGB(
                                                                            255,
                                                                            38,
                                                                            20,
                                                                            84),
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                      ),
                                                                    ),
                                                                    if (articlee[
                                                                            'date'] !=
                                                                        'null')
                                                                      SizedBox(
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            const Icon(
                                                                              Icons.access_time,
                                                                              size: 17,
                                                                              color: Color.fromARGB(255, 106, 106, 106),
                                                                            ),
                                                                            const SizedBox(
                                                                              width: 7,
                                                                            ),
                                                                            Text(
                                                                              articlee['date'],
                                                                              overflow: TextOverflow.ellipsis,
                                                                              style: const TextStyle(
                                                                                color: Color.fromARGB(255, 106, 106, 106),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                              IconButton(
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .bookmark,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          49,
                                                                          205,
                                                                          215),
                                                                  size: 25,
                                                                ),
                                                                onPressed:
                                                                    () async {
                                                                  logger.info(
                                                                      "clicked");
                                                                  DBHelper
                                                                      dbHelper =
                                                                      DBHelper
                                                                          .instance;
                                                                  // ignore: prefer_typing_uninitialized_variables
                                                                  var response;
                                                                  response = await dbHelper
                                                                      .deleteFavorite(
                                                                          articlee[
                                                                              'url']);
                                                                  logger.info(
                                                                      response);

                                                                  setState(
                                                                    () {
                                                                      int indexx = finalList.indexWhere((article) =>
                                                                          article[
                                                                              'title'] ==
                                                                          articlee[
                                                                              'title']);
                                                                      if (indexx !=
                                                                          -1) {
                                                                        setState(
                                                                            () {
                                                                          starred![indexx] =
                                                                              !starred![indexx];
                                                                        });
                                                                      }
                                                                    },
                                                                  );
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                  'Error: ${snapshot.error}');
                                            } else if (!snapshot.hasData) {
                                              return Center(
                                                child: Column(
                                                  children: [
                                                    SizedBox(
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.4,
                                                    ),
                                                    const Text(
                                                      'You have no saved articles',
                                                    ),
                                                  ],
                                                ),
                                              );
                                            } else {
                                              return const CircularProgressIndicator();
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  );
                */
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.11,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bookmark_outline_rounded,
                            size: MediaQuery.of(context).size.width * 0.07,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),
                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'Favorites',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.035,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: MediaQuery.of(context).size.width * 0.03,
                        color: const Color.fromARGB(255, 84, 95, 107),
                      ), // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Membership(
                        username: username_,
                        index: 1,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.11,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.token_outlined,
                            size: MediaQuery.of(context).size.width * 0.07,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),

                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'Subscriptions',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.035,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: MediaQuery.of(context).size.width * 0.03,
                        color: const Color.fromARGB(255, 84, 95, 107),
                      ), // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useRootNavigator: true,
                    builder: (context) {
                      return SizedBox(
                        height: MediaQuery.of(context).size.height * 0.9,
                        child: Stack(
                          //mainAxisAlignment:MainAxisAlignment.spaceBetween,
                          children: [
                            ShaderMask(
                              shaderCallback: (Rect bounds) {
                                return const LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: <Color>[
                                    Colors.transparent,
                                    Colors.white
                                  ],
                                  stops: <double>[0.75, 0.85],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.dstOut,
                              child: SingleChildScrollView(
                                child: Container(
                                  padding: const EdgeInsets.only(
                                    left: 30,
                                    right: 30,
                                    top: 20,
                                    bottom: 10,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'AGREEMENT',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: Color.fromARGB(
                                              255, 173, 173, 173),
                                          fontWeight: FontWeight.normal,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                      const Text(
                                        'Terms of Service',
                                        style: TextStyle(
                                          fontSize: 32.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 20.0),
                                      const Text(
                                        '1. OUR SERVICES',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'The information provided when using the Services is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation or which would subject us to any registration requirement within such jurisdiction or country. Accordingly, those persons who choose to access the Services from other locations do so on their own initiative and are solely responsible for compliance with local laws, if and to the extent local laws are applicable.',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      const SizedBox(height: 10.0),
                                      const Text(
                                        '2. Use License',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text(
                                        'Subject to your compliance with these Legal Terms, including the "PROHIBITED ACTIVITIES" section below, we grant you a non-exclusive, non-transferable, revocable license to: access the Services; and download or print a copy of any portion of the Content to which you have properly gained access. solely for your personal, non-commercial use or internal business purpose. Except as set out in this section or elsewhere in our Legal Terms, no part of the Services and no Content or Marks may be copied, reproduced, aggregated, ',
                                        style: TextStyle(fontSize: 18.0),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.15,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  bottom: 40,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.5,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(
                                            255,
                                            49,
                                            205,
                                            215,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Change this value as needed
                                          ),
                                        ),
                                        child: const Text(
                                          'Close',
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                              255,
                                              255,
                                              249,
                                              254,
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.11,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.policy_outlined,
                            size: MediaQuery.of(context).size.width * 0.07,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),

                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.035,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  // Handle your tap event here...
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.11,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: MediaQuery.of(context).size.width * 0.07,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),

                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'User Manual',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.035,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  // Handle your tap event here...
                },
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color.fromARGB(
                            255, 209, 209, 209), // Specify your color here
                        width: 1.2, // Specify your border width here
                      ),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.11,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.help_outline,
                            size: MediaQuery.of(context).size.width * 0.07,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),

                          const SizedBox(
                            width: 10,
                          ), // This is the left icon
                          Text(
                            'Help and Support',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.035,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      // This is the right icon
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const Login(),
                    ),
                  );
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width * 0.11,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize:
                        MainAxisSize.min, // This will make the Row compact
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.logout_rounded,
                            size: MediaQuery.of(context).size.width * 0.07,
                            color: const Color.fromARGB(255, 28, 42, 58),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Log Out',
                            style: TextStyle(
                              fontSize: min(MediaQuery.of(context).size.width,
                                      MediaQuery.of(context).size.height) *
                                  0.035,
                              color: const Color.fromARGB(255, 84, 95, 107),
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ), // This is the text
                      // This is the right icon
                    ],
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

// ignore: camel_case_types
class editProfile extends StatefulWidget {
  const editProfile({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _editProfileState createState() => _editProfileState();
}

// ignore: camel_case_types
class _editProfileState extends State<editProfile> {
  late final TextEditingController _userController;
  late final TextEditingController _controllerEmail;
  late final TextEditingController _pnController;
  late final TextEditingController _controllerPass;
  late final TextEditingController _controllerVeryPass;
  void _pickImage(StateSetter setState) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = (await _picker.pickImage(source: ImageSource.gallery));

    // this allegedly only works on mobile but i cant test it :(
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final newPath =
          '${directory.path}/${DateTime.now().toIso8601String()}.jpg';
      final File newImage = await File(image.path).copy(newPath);

      setState(() {
        _selectedImage = XFile(newImage.path);
      });
    }
  }

  bool error = false;
  bool eerror = false;
  bool perror = false;
  String? phoneNumberErrorMessage;
  String? emailErrorMessage;
  String? usernameErrorMessage;
  @override
  void initState() {
    super.initState();
    _userController = TextEditingController(text: username_);
    _controllerEmail = TextEditingController(text: email_);
    _pnController = TextEditingController(text: phoneNumber_);
    _controllerPass = TextEditingController();
    _controllerVeryPass = TextEditingController();
    if (profilePicture_ != '') {
      _selectedImage = XFile(profilePicture_);
    }
    //favorites();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {});
      }
    });
  }

  bool show = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Edit Profile',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 249, 254),
                fontSize: 21,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 38, 20, 84),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.025,
                left: 20,
                right: 20,
                bottom: 10,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () => _pickImage(setState),
                            child: Stack(
                              children: [
                                SizedBox(
                                  width: min(MediaQuery.of(context).size.width,
                                          MediaQuery.of(context).size.height) *
                                      0.5,
                                  height: min(MediaQuery.of(context).size.width,
                                          MediaQuery.of(context).size.height) *
                                      0.5,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: _selectedImage != null
                                        ? Image.file(
                                            File(_selectedImage!.path),
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: const Color.fromARGB(
                                                255, 45, 170, 178),
                                            child: Center(
                                              child: Text(
                                                //textAlign: TextAlign.center,
                                                firstName_[0].toUpperCase(),
                                                style: TextStyle(
                                                  fontSize: min(
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                          MediaQuery.of(context)
                                                              .size
                                                              .height) *
                                                      0.2,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                                Positioned(
                                  left: 0,
                                  top: 20,
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _selectedImage = null;
                                      });
                                    },
                                    child: const Icon(
                                      Icons.remove_circle,
                                      size: 40,
                                      color: Color.fromARGB(255, 38, 20, 84),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 20,
                                  child: InkWell(
                                    onTap: () => _pickImage(setState),
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
                                        color:
                                            Color.fromARGB(255, 255, 255, 255),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    TextFormField(
                      controller: _userController,
                      keyboardType: TextInputType.name,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        //labelText: 'UserName',
                        hintText: username_,
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
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Color.fromARGB(255, 38, 20, 84),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 1.5,
                            color: Color.fromARGB(255, 38, 20, 84),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Color.fromARGB(255, 38, 20, 84),
                          ),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Color.fromARGB(255, 38, 20, 84),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      /*validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }

                        return usernameErrorMessage;
                      },
                      onChanged: (String? value) async {
                        if (value != null && value.isNotEmpty) {
                          int result = await userNameUpdate(value);
                          if (result == 0 || result == -1) {
                            setState(() {
                              usernameErrorMessage =
                                  "* Username already exists";
                            });
                          } else {
                            setState(() {
                              usernameErrorMessage = null;
                            });
                          }
                        }
                      },*/
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    error
                        ? Text(
                            usernameErrorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      height: 20,
                    ),
                    TextFormField(
                      controller: _controllerEmail,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 38, 20, 84),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: email_,
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
                            width: 1.5,
                            color: Color.fromARGB(255, 38, 20, 84),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            width: 1.5,
                            color: Color.fromARGB(255, 38, 20, 84),
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        errorBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Color.fromARGB(255, 38, 20, 84),
                          ),
                        ),
                        focusedErrorBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            width: 1.5,
                            color: Color.fromARGB(255, 38, 20, 84),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15)),
                        ),
                      ),
                      /*validator: (String? value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }

                        return emailErrorMessage;
                      },
                      onChanged: (String? value) async {
                        if (value != null && value.isNotEmpty) {
                          int result = await emailUpdate(value);
                          if (result == 2) {
                            setState(() {
                              emailErrorMessage = "* Invalid email";
                            });
                          } else if (result == 0 || result == -1) {
                            setState(() {
                              emailErrorMessage = "* Email already exists";
                            });
                          } else {
                            setState(() {
                              emailErrorMessage = null;
                            });
                          }
                        }
                      },*/
                    ),
                    const SizedBox(
                      height: 10,
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
                      height: 20,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _pnController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 38, 20, 84),
                              fontSize: 15,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              hintText: phoneNumber_ == ""
                                  ? 'Phone Number'
                                  : phoneNumber_,
                              labelStyle: const TextStyle(
                                color: Color.fromARGB(189, 38, 20, 84),
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                              prefixIcon: const Icon(
                                Icons.phone_android,
                                color: Color.fromARGB(255, 38, 20, 84),
                              ),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    height: 50, // Adjust the height as needed
                                    width: 1.5, // This creates a 'line'
                                    color:
                                        const Color.fromARGB(255, 38, 20, 84),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  const Text('+961'),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.07,
                                    child: Image.asset(
                                      'assets/lebanon.png',
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Color.fromARGB(255, 38, 20, 84),
                                ),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Color.fromARGB(255, 38, 20, 84),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                              errorBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Color.fromARGB(255, 38, 20, 84),
                                ),
                              ),
                              focusedErrorBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                  width: 1.5,
                                  color: Color.fromARGB(255, 38, 20, 84),
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(15)),
                              ),
                            ),
                            /*validator: (String? value) {
                              // if (value == null || value.isEmpty) {
                              //   return 'Please enter a phone number';
                              // }

                              return phoneNumberErrorMessage;
                            },
                            onChanged: (String? value) async {
                              if (value != null && value.isNotEmpty) {
                                int result = await phoneUpdate(value);
                                if (result == 2) {
                                  setState(() {
                                    phoneNumberErrorMessage =
                                        "* Invalid phone number";
                                  });
                                } else if (result == 0 || result == -1) {
                                  setState(() {
                                    phoneNumberErrorMessage =
                                        "* Phone number already exists";
                                  });
                                } else {
                                  setState(() {
                                    phoneNumberErrorMessage = null;
                                  });
                                }
                              }
                            },*/
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    perror
                        ? Text(
                            phoneNumberErrorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      height: 10,
                    ),
                    show == false
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    show = true;
                                  });
                                },
                                child: const Text(
                                  "Change Password",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 116, 116, 116),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(),
                    const SizedBox(
                      height: 10,
                    ),
                    show == true
                        ? Column(
                            children: [
                              TextFormField(
                                controller: _controllerPass,
                                keyboardType: TextInputType.visiblePassword,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 38, 20, 84),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Old password',
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Color.fromARGB(255, 38, 20, 84),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      width: 1.5,
                                      color: Color.fromARGB(255, 38, 20, 84),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  errorBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Color.fromARGB(255, 38, 20, 84),
                                    ),
                                  ),
                                  focusedErrorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Color.fromARGB(255, 38, 20, 84),
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                /*validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your email';
                                  }
            
                                  return emailErrorMessage;
                                },
                                onChanged: (String? value) async {
                                  if (value != null && value.isNotEmpty) {
                                    int result = await emailUpdate(value);
                                    if (result == 2) {
                                      setState(() {
                                        emailErrorMessage = "* Invalid email";
                                      });
                                    } else if (result == 0 || result == -1) {
                                      setState(() {
                                        emailErrorMessage =
                                            "* Email already exists";
                                      });
                                    } else {
                                      setState(() {
                                        emailErrorMessage = null;
                                      });
                                    }
                                  }
                                },*/
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: _controllerVeryPass,
                                keyboardType: TextInputType.visiblePassword,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 38, 20, 84),
                                  fontSize: 15,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'New Password',
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Color.fromARGB(255, 38, 20, 84),
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: const BorderSide(
                                      width: 1.5,
                                      color: Color.fromARGB(255, 38, 20, 84),
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  errorBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Color.fromARGB(255, 38, 20, 84),
                                    ),
                                  ),
                                  focusedErrorBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                      width: 1.5,
                                      color: Color.fromARGB(255, 38, 20, 84),
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15)),
                                  ),
                                ),
                                /*validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your new password';
                                  }
            
                                  return passErrorMessage;
                                },*/
                                /*onChanged: (String? value) async {
                                  if (value != null && value.isNotEmpty) {
                                    int result = await emailUpdate(value);
                                    if (result == 2) {
                                      setState(() {
                                        emailErrorMessage = "* Invalid email";
                                      });
                                    } else if (result == 0 || result == -1) {
                                      setState(() {
                                        emailErrorMessage =
                                            "* Email already exists";
                                      });
                                    } else {
                                      setState(() {
                                        emailErrorMessage = null;
                                      });
                                    }
                                  }
                                },*/
                              ),
                            ],
                          )
                        : Container(),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 38, 20, 84),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Change this value as needed
                          ),
                        ),
                        child: const Text(
                          'Accept',
                          style: TextStyle(
                            color: Color.fromARGB(
                              255,
                              255,
                              249,
                              254,
                            ),
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () async {
                          String uvalue = _userController.text;
                          int result = await userNameUpdate(uvalue);
                          String value = _controllerEmail.text;
                          int result2 = await emailUpdate(value);
                          String nvalue = _pnController.text;
                          int result3 = await phoneUpdate(nvalue);

                          String oldvalue = _controllerPass.text;
                          String newvalue = _controllerVeryPass.text;
                          int result4 =
                              await passwordUpdate(oldvalue, newvalue);
                          print(result4);

                          if (_formKey.currentState!.validate()) {
                            if (await isConnectedToWifi()) {
                              setState(() {
                                if (_selectedImage != null) {
                                  profilePicture_ = _selectedImage!.path;

                                  saveP();
                                } else {
                                  profilePicture_ = '';
                                  saveP();
                                }
                              });
                              if (uvalue.isNotEmpty) {
                                if (result == 0 || result == -1) {
                                  setState(() {
                                    usernameErrorMessage =
                                        "* Username already exists";
                                    error = true;
                                  });
                                } else {
                                  setState(() {
                                    usernameErrorMessage = null;
                                    error = false;
                                    username_ = _userController.text;
                                  });
                                }
                              }
                              if (value.isNotEmpty) {
                                if (result2 == 2) {
                                  setState(() {
                                    emailErrorMessage = "* Invalid email";
                                    eerror = true;
                                  });
                                } else if (result2 == 0 || result2 == -1) {
                                  setState(() {
                                    emailErrorMessage =
                                        "* Email already exists";
                                    eerror = true;
                                  });
                                } else {
                                  setState(() {
                                    emailErrorMessage = null;
                                    eerror = false;
                                    email_ = _controllerEmail.text;
                                  });
                                }
                              }

                              if (nvalue.isNotEmpty) {
                                int result = await phoneUpdate(value);
                                if (result == 2) {
                                  setState(() {
                                    phoneNumberErrorMessage =
                                        "* Invalid phone number";
                                    perror = true;
                                  });
                                } else if (result == 0 || result == -1) {
                                  setState(() {
                                    phoneNumberErrorMessage =
                                        "* Phone number already exists";
                                    perror = true;
                                  });
                                } else {
                                  setState(() {
                                    phoneNumberErrorMessage = null;
                                    perror = false;

                                    phoneNumber_ = _pnController.text;
                                  });
                                }
                              }
                              if (result == 1 && result2 == 1 && result3 == 1) {
                                Navigator.of(context).pop();
                              }
                            } else {
                              showDialog(
                                // ignore: use_build_context_synchronously
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('No Internet'),
                                    content: const Text(
                                        'You are not connected to the internet.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                          //   setState(() {
                          //     acc = true;
                          //     if (isValidEmail(
                          //         _controllerEmail.text)) {
                          //       if (_selectedImage != null) {
                          //         profilePicture_ =
                          //             _selectedImage!.path;

                          //         saveP();
                          //       } else {
                          //         profilePicture_ = '';
                          //         saveP();
                          //       }
                          //       if (_userController
                          //           .text.isNotEmpty) {
                          //         username_ =
                          //             _userController.text;
                          //         saveU();
                          //       }
                          //       if (_controllerEmail
                          //           .text.isNotEmpty) {
                          //         email_ =
                          //             _controllerEmail.text;
                          //         saveE();
                          //       }
                          //       if (_pnController
                          //           .text.isNotEmpty) {
                          //         phoneNumber_ =
                          //             _pnController.text;
                          //         saveN();
                          //       }
                          //       Navigator.of(context).pop();
                          //     } else {
                          //       _controllerEmail.value =
                          //           TextEditingValue(
                          //               text: email_);
                          //       showDialog(
                          //         context: context,
                          //         builder:
                          //             (BuildContext context) {
                          //           return AlertDialog(
                          //             title: const Text(
                          //                 'Invalid Email'),
                          //             content: const Text(
                          //                 'Please enter a valid email'),
                          //             actions: <Widget>[
                          //               TextButton(
                          //                 child: const Text(
                          //                     'Close'),
                          //                 onPressed: () {
                          //                   Navigator.of(
                          //                           context)
                          //                       .pop();
                          //                 },
                          //               ),
                          //             ],
                          //           );
                          //         },
                          //       );
                          //     }
                          //   });
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.06,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          //primary: Color.fromARGB(255, 255, 255, 255), // background color
                          side: const BorderSide(
                            color: Color.fromARGB(255, 38, 20, 84),
                            width: 1,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10), // Change this value as needed
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Color.fromARGB(255, 38, 20, 84),
                            fontSize: 20,
                          ),
                        ),
                        onPressed: () async {
                          setState(() {
                            if (profilePicture_ != '') {
                              _selectedImage = XFile(profilePicture_);
                            }
                          });
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
