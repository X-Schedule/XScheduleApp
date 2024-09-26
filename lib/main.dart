import 'package:flutter/material.dart';
import 'package:xchedule/display/themes.dart';

import 'display/home_page.dart';

/*
Main:
What the app runs on startup
 */

 //test

void main() {
  //Once app opened, builds the app itself
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Themes.blueTheme,
      //Gets rid of that pesky debug banner
      debugShowCheckedModeBanner: false,
      title: 'Xchedule',
      //HomePage Wrapped in DefaultTextStyle so that we don't need to specify EVERY TIME we display text
      home: const DefaultTextStyle(
        style: TextStyle(color: Colors.black, fontSize: 25, decoration: null),
        child: HomePage(),
      ),
    );
  }
}
