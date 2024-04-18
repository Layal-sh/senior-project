import 'package:flutter/material.dart';
import 'package:sugar_sense/Database/db.dart';
import 'package:sugar_sense/application/app.dart';
import 'package:sugar_sense/main.dart';
import 'package:url_launcher/url_launcher.dart';

class Articles extends StatefulWidget {
  const Articles({super.key});

  @override
  _ArticlesState createState() => _ArticlesState();
}

class _ArticlesState extends State<Articles> {
  @override
  void initState() {
    super.initState();
  }

  bool _isPressed = false;
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 25.0,
                right: 25,
                top: 30,
                bottom: 20,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Todays Read',
                    style: TextStyle(
                      fontSize: 27,
                      fontFamily: 'InriaSerifBold',
                      color: Color.fromARGB(255, 38, 20, 84),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isPressed = !_isPressed;
                      });
                    },
                    child: Icon(
                      _isPressed
                          ? Icons.notifications
                          : Icons.notifications_none_outlined,
                      size: 30,
                      color: const Color.fromARGB(255, 38, 20, 84),
                    ),
                  ),
                ],
              ),
            ),
            (filteredArticles.isEmpty || starred == null)
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.25,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: filteredArticles.length,
                        itemBuilder: (context, index) {
                          String? imageUrl =
                              filteredArticles[index]['thumbnail'];
                          String title = filteredArticles[index]['title'];
                          String url = filteredArticles[index]['link'];
                          String? date = filteredArticles[index]['date'];

                          return Padding(
                            padding: const EdgeInsets.only(left: 0.0),
                            child: SizedBox(
                              child: InkWell(
                                onTap: () => launch(url),
                                child: Card(
                                  color: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  surfaceTintColor: Colors.transparent,
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.circular(10.0),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color.fromARGB(
                                                      185, 77, 77, 77)
                                                  .withOpacity(0.5),
                                              spreadRadius: 1,
                                              blurRadius: 7,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(10.0),
                                            topRight: Radius.circular(10.0),
                                            bottomLeft: Radius.circular(10),
                                            bottomRight: Radius.circular(10),
                                          ),
                                          child: imageUrl != null
                                              ? Image.network(
                                                  imageUrl,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.5,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.15,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 8.0,
                                            left: 25,
                                            //right: 15,
                                          ),
                                          child: ShaderMask(
                                            shaderCallback: (Rect bounds) {
                                              return const LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: <Color>[
                                                  Colors.black,
                                                  Color.fromARGB(51, 0, 0, 0)
                                                ],
                                                stops: <double>[0.7, 1.0],
                                              ).createShader(bounds);
                                            },
                                            blendMode: BlendMode.dstIn,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.4,
                                                  child: Text(
                                                    title,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontFamily: 'InriaSerif',
                                                      color: Color.fromARGB(
                                                          255, 38, 20, 84),
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                IconButton(
                                                  icon: Icon(
                                                    starred![index]
                                                        ? Icons.bookmark_rounded
                                                        : Icons
                                                            .bookmark_border_rounded,
                                                    color: starred![index]
                                                        ? const Color.fromARGB(
                                                            255,
                                                            49,
                                                            205,
                                                            215) // Corrected color definition
                                                        : const Color.fromARGB(
                                                            255, 49, 205, 215),
                                                    size: 27,
                                                  ),
                                                  onPressed: () async {
                                                    logger.info("clicked");
                                                    DBHelper dbHelper =
                                                        DBHelper.instance;
                                                    var response;
                                                    if (starred![index]) {
                                                      response = await dbHelper
                                                          .deleteFavorite(url);
                                                      logger.info(response);
                                                    } else {
                                                      response = await dbHelper
                                                          .addFavorite(
                                                              url,
                                                              title,
                                                              imageUrl,
                                                              date);
                                                    }
                                                    logger.info(response);
                                                    setState(
                                                      () {
                                                        starred![index] =
                                                            !starred![index];
                                                      },
                                                    );
                                                  },
                                                ),
                                              ],
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
                        },
                      ),
                    ),
                  ),
            const Padding(
              padding: EdgeInsets.only(
                left: 25.0,
                bottom: 5,
              ),
              child: Text(
                'For You',
                style: TextStyle(
                  fontSize: 22,
                  fontFamily: 'InriaSerifBold',
                  color: Color.fromARGB(255, 38, 20, 84),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            (articles.isEmpty || starred == null)
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.only(left: 5.0),
                    child: SizedBox(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: restArticles.length,
                        itemBuilder: (context, index) {
                          String? imageUrl = restArticles[index]['thumbnail'];
                          String title = restArticles[index]['title'];
                          String url = restArticles[index]['link'];
                          String? date = restArticles[index]['date'];

                          return SizedBox(
                            height: imageUrl != null
                                ? MediaQuery.of(context).size.height * 0.13
                                : null,
                            child: InkWell(
                              onTap: () => launch(url),
                              child: Card(
                                color: Colors.transparent,
                                shadowColor: Colors.transparent,
                                surfaceTintColor: Colors.transparent,
                                clipBehavior: Clip.antiAlias,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    //bottom: 5.0,
                                    left: 10,
                                    right: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      imageUrl != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              child: Image.network(
                                                imageUrl,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.25,
                                                height:
                                                    120, // Adjust the height as needed
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Container(),
                                      const SizedBox(
                                          width: 10), // Add some spacing
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'InriaSerif',
                                                color: Color.fromARGB(
                                                    255, 38, 20, 84),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            if (date != null)
                                              SizedBox(
                                                child: Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.access_time,
                                                      size: 17,
                                                      color: Color.fromARGB(
                                                          255, 106, 106, 106),
                                                    ),
                                                    const SizedBox(
                                                      width: 7,
                                                    ),
                                                    Text(
                                                      date,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        color: Color.fromARGB(
                                                            255, 106, 106, 106),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          (starred![5 + index])
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                          color: starred![5 + index]
                                              ? const Color.fromARGB(
                                                  255, 49, 205, 215)
                                              : const Color.fromARGB(
                                                  255, 49, 205, 215),
                                          size: 25,
                                        ),
                                        onPressed: () async {
                                          logger.info("clicked");
                                          DBHelper dbHelper = DBHelper.instance;
                                          var response;
                                          if (starred![5 + index]) {
                                            response = await dbHelper
                                                .deleteFavorite(url);
                                            logger.info(response);
                                          } else {
                                            response =
                                                await dbHelper.addFavorite(
                                                    url, title, imageUrl, date);
                                          }
                                          logger.info(response);
                                          setState(
                                            () {
                                              starred![5 + index] =
                                                  !starred![5 + index];
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
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
